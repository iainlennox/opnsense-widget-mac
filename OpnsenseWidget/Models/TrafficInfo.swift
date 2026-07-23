import Foundation

struct TrafficResponse: Decodable {
    let interfaces: [String: InterfaceTraffic]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        // Try common top-level keys used by OPNsense
        let keysToTry = ["interfaces", "traffic", "statistics"]
        var result: [String: InterfaceTraffic]?
        for key in keysToTry {
            if let key = AnyCodingKey(stringValue: key),
               let value = try? container.decode([String: InterfaceTraffic].self, forKey: key) {
                result = value
                break
            }
        }
        guard let interfaces = result else {
            throw DecodingError.keyNotFound(
                AnyCodingKey(stringValue: "interfaces")!,
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "None of \(keysToTry) found in response"))
        }
        self.interfaces = interfaces
    }
}

struct InterfaceTraffic: Decodable {
    let device: String
    let name: String
    let bytesReceived: String
    let bytesTransmitted: String

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        device = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "device")!)) ?? ""
        name = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "name")!)) ?? ""

        let rxKeys = ["bytes received", "ibytes", "inbytes", "rxbytes", "in_bytes", "rx_bytes"]
        let txKeys = ["bytes transmitted", "obytes", "outbytes", "txbytes", "out_bytes", "tx_bytes"]

        var rx: String?
        for key in rxKeys {
            if let ck = AnyCodingKey(stringValue: key),
               let v = try? container.decode(String.self, forKey: ck) {
                rx = v; break
            }
            if let ck = AnyCodingKey(stringValue: key),
               let v = try? container.decode(Int64.self, forKey: ck) {
                rx = String(v); break
            }
        }
        bytesReceived = rx ?? "0"

        var tx: String?
        for key in txKeys {
            if let ck = AnyCodingKey(stringValue: key),
               let v = try? container.decode(String.self, forKey: ck) {
                tx = v; break
            }
            if let ck = AnyCodingKey(stringValue: key),
               let v = try? container.decode(Int64.self, forKey: ck) {
                tx = String(v); break
            }
        }
        bytesTransmitted = tx ?? "0"
    }

    var inBytes: Int64 { Int64(bytesReceived) ?? 0 }
    var outBytes: Int64 { Int64(bytesTransmitted) ?? 0 }
}

private struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue; stringValue = "\(intValue)" }
}
