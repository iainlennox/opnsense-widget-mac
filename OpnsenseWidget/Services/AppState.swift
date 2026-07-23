import Foundation
import SwiftUI
import Network

@Observable
final class AppState {
    var config = ConfigManager.load()
    let api = OpnsenseApiClient()

    init() {
        configure()
        triggerLocalNetworkPermission()
    }

    private func triggerLocalNetworkPermission() {
        // Several known triggers for the macOS 15+ Local Network TCC prompt
        _ = ProcessInfo.processInfo.hostName

        guard let url = URL(string: config.baseUrl), let host = url.host() else { return }
        let port = NWEndpoint.Port(rawValue: UInt16(url.port ?? 443)) ?? 443
        let conn = NWConnection(host: NWEndpoint.Host(host), port: port, using: .tcp)
        conn.start(queue: .global())
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            conn.cancel()
        }
    }
    var allInterfaces: [InterfaceDisplay] = []
    var previousTraffic: [String: InterfaceTraffic] = [:]
    var previousTrafficTime: Date = .now
    var statusText: String = "Not connected"
    var statusColor: Color = .gray
    var refreshTime: String = ""
    var showSettings: Bool = false
    var showAbout: Bool = false
    var showWindow: Bool = false

    var visibleInterfaces: [InterfaceDisplay] {
        allInterfaces
            .filter { !$0.isHidden }
            .sorted { $0.order < $1.order }
    }

    func configure() {
        api.configure(baseUrl: config.baseUrl, apiKey: config.apiKey, apiSecret: config.apiSecret)
    }

    func refresh() async {
        guard api.isConfigured else { return }
        statusText = "Fetching interfaces..."
        refreshTime = Self.timeFormatter.string(from: .now)

        do {
            let interfaces = try await api.getInterfaceOverview()
            mergeInterfaces(interfaces)
            applyInterfaceConfig()

            let up = visibleInterfaces.filter(\.isUp).count
            let total = visibleInterfaces.count
            statusText = "\(up)/\(total) interfaces up"
            statusColor = up == total ? Color(red: 0.65, green: 0.89, blue: 0.63) : Color(red: 0.95, green: 0.54, blue: 0.66)
        } catch {
            statusText = "Error: \(error.localizedDescription)"
            statusColor = Color(red: 0.95, green: 0.54, blue: 0.66)
        }
    }

    func pollBandwidth() async {
        guard api.isConfigured else { return }
        do {
            let rawTraffic = try await api.getTraffic()
            let now = Date()

            for iface in allInterfaces {
                let current = matchTrafficEntry(rawTraffic, name: iface.name)
                let prev = matchTrafficEntry(previousTraffic, name: iface.name)

                if let current, let prev {
                    let elapsed = now.timeIntervalSince(previousTrafficTime)
                    if elapsed > 0 {
                        let inBps = Double(current.inBytes - prev.inBytes) * 8 / elapsed
                        let outBps = Double(current.outBytes - prev.outBytes) * 8 / elapsed
                        iface.bandwidthIn = formatBandwidth(inBps)
                        iface.bandwidthOut = formatBandwidth(outBps)
                        iface.addBandwidthSample(inBps: inBps, outBps: outBps)
                    }
                }
            }

            previousTraffic = rawTraffic
            previousTrafficTime = now
        } catch {
            statusText = "BW error: \(error.localizedDescription)"
            statusColor = Color(red: 0.95, green: 0.54, blue: 0.66)
        }
    }

    func moveUp(_ iface: InterfaceDisplay) {
        guard let idx = allInterfaces.firstIndex(where: { $0.id == iface.id }), idx > 0 else { return }
        allInterfaces.swapAt(idx, idx - 1)
        saveLayout()
        applyInterfaceConfig()
    }

    func moveDown(_ iface: InterfaceDisplay) {
        guard let idx = allInterfaces.firstIndex(where: { $0.id == iface.id }),
              idx < allInterfaces.count - 1 else { return }
        allInterfaces.swapAt(idx, idx + 1)
        saveLayout()
        applyInterfaceConfig()
    }

    func toggleVisibility(_ iface: InterfaceDisplay) {
        iface.isHidden.toggle()
        setOrCreateConfig(deviceName: iface.name) { cfg in
            cfg.isHidden = iface.isHidden
        }
        ConfigManager.save(config)
    }

    func commitRename(_ iface: InterfaceDisplay) {
        iface.isEditing = false
        setOrCreateConfig(deviceName: iface.name) { cfg in
            cfg.customName = iface.customName.isEmpty ? nil : iface.customName
        }
        ConfigManager.save(config)
    }

    private func mergeInterfaces(_ fresh: [InterfaceDisplay]) {
        var existing = Dictionary(uniqueKeysWithValues: allInterfaces.map { ($0.name, $0) })
        for freshIface in fresh {
            if let existingIface = existing[freshIface.name] {
                existingIface.description = freshIface.description
                existingIface.status = freshIface.status
                existingIface.ipAddress = freshIface.ipAddress
                existingIface.macAddress = freshIface.macAddress
                existingIface.linkSpeed = freshIface.linkSpeed
            } else {
                existing[freshIface.name] = freshIface
            }
        }
        allInterfaces = Array(existing.values)
    }

    private func matchTrafficEntry(_ traffic: [String: InterfaceTraffic], name: String) -> InterfaceTraffic? {
        if let entry = traffic[name] { return entry }
        for (_, t) in traffic {
            if t.device == name || t.name == name { return t }
        }
        return nil
    }

    private func applyInterfaceConfig() {
        for iface in allInterfaces {
            if let idx = config.interfaces.firstIndex(where: { $0.deviceName == iface.name }) {
                let cfg = config.interfaces[idx]
                iface.customName = cfg.customName ?? ""
                iface.isHidden = cfg.isHidden
                iface.order = cfg.order
            } else {
                let newCfg = InterfaceConfig(deviceName: iface.name, order: config.interfaces.count)
                config.interfaces.append(newCfg)
                iface.order = newCfg.order
            }
            iface.blurIpAddress = config.blurIpAddress
        }
    }

    private func setOrCreateConfig(deviceName: String, mutate: (inout InterfaceConfig) -> Void) {
        if let idx = config.interfaces.firstIndex(where: { $0.deviceName == deviceName }) {
            mutate(&config.interfaces[idx])
        } else {
            var cfg = InterfaceConfig(deviceName: deviceName, order: config.interfaces.count)
            mutate(&cfg)
            config.interfaces.append(cfg)
        }
    }

    private func saveLayout() {
        for (i, iface) in allInterfaces.enumerated() {
            if let idx = config.interfaces.firstIndex(where: { $0.deviceName == iface.name }) {
                config.interfaces[idx].order = i
            }
        }
        ConfigManager.save(config)
    }

    static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private func formatBandwidth(_ bps: Double) -> String {
        if bps >= 1_000_000_000 { return String(format: "%.1f Gbps", bps / 1_000_000_000) }
        if bps >= 1_000_000 { return String(format: "%.1f Mbps", bps / 1_000_000) }
        if bps >= 1_000 { return String(format: "%.0f Kbps", bps / 1_000) }
        return "\(Int(bps)) bps"
    }
}
