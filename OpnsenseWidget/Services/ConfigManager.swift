import Foundation

struct InterfaceConfig: Codable {
    var deviceName: String = ""
    var customName: String? = nil
    var isHidden: Bool = false
    var order: Int = 0
}

struct AppConfig: Codable {
    var baseUrl: String = "https://192.168.1.1"
    var apiKey: String = ""
    var apiSecret: String = ""
    var refreshIntervalSeconds: Int = 5
    var windowX: CGFloat = 100
    var windowY: CGFloat = 100
    var blurIpAddress: Bool = false
    var interfaces: [InterfaceConfig] = []
}

enum ConfigManager {
    private static var configURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("OpnsenseWidget")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("config.json")
    }

    static func load() -> AppConfig {
        guard FileManager.default.fileExists(atPath: configURL.path),
              let data = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(AppConfig.self, from: data)
        else {
            return AppConfig()
        }
        return config
    }

    static func save(_ config: AppConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        try? data.write(to: configURL, options: .atomic)
    }
}
