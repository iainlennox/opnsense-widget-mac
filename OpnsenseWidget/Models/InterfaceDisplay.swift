import Foundation
import SwiftUI

@Observable
final class InterfaceDisplay: Identifiable {
    let id = UUID()
    var name: String = ""
    var description: String = ""
    var status: String = ""
    var ipAddress: String = ""
    var macAddress: String = ""
    var customName: String = ""
    var isEditing: Bool = false
    var isHidden: Bool = false
    var blurIpAddress: Bool = false
    var order: Int = 0
    var bandwidthIn: String = ""
    var bandwidthOut: String = ""
    var linkSpeed: String = ""
    var inHistory: [Double] = []
    var outHistory: [Double] = []
    var scale: Double = 1

    var isUp: Bool {
        status.lowercased() == "up"
    }

    var displayName: String {
        customName.isEmpty ? name : customName
    }

    var displaySpeed: String {
        guard !linkSpeed.isEmpty else { return "" }
        let digits = String(linkSpeed.prefix { $0.isNumber })
        guard let speed = Int(digits) else { return linkSpeed }
        let suffix = linkSpeed.dropFirst(digits.count).trimmingCharacters(in: .whitespaces)

        var mbps = speed
        if suffix.lowercased().hasPrefix("g") {
            mbps = speed * 1000
        } else if suffix.lowercased().hasPrefix("k") {
            mbps = speed / 1000
        }

        if mbps >= 1000 {
            let gb = Double(mbps) / 1000.0
            return gb == Double(Int(gb)) ? "\(Int(gb)) GB" : String(format: "%.1f GB", gb)
        }
        return "\(mbps) MB"
    }

    func addBandwidthSample(inBps: Double, outBps: Double) {
        inHistory.append(inBps)
        if inHistory.count > 60 { inHistory.removeFirst() }
        outHistory.append(outBps)
        if outHistory.count > 60 { outHistory.removeFirst() }

        let currentMax = max(inHistory.max() ?? 0, outHistory.max() ?? 0)
        if currentMax > scale {
            scale = currentMax
        } else {
            scale = scale * 0.9 + currentMax * 0.1
        }
    }
}
