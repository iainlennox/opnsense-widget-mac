import Foundation

struct InterfacesInfoResponse: Decodable {
    let total: Int
    let rows: [InterfaceInfoRow]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        rows = (try? container.decode([InterfaceInfoRow].self, forKey: AnyCodingKey(stringValue: "rows")!)) ?? []
        total = (try? container.decode(Int.self, forKey: AnyCodingKey(stringValue: "total")!)) ?? rows.count
    }
}

struct InterfaceInfoRow: Decodable {
    let device: String
    let description: String
    let status: String
    let macaddr: String
    let addr4: String
    let ipv4: [IpEntry]?
    let media: String

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        device = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "device")!)) ?? ""
        description = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "description")!)) ?? ""
        status = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "status")!)) ?? ""
        macaddr = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "macaddr")!)) ?? ""
        addr4 = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "addr4")!)) ?? ""
        ipv4 = try? container.decode([IpEntry].self, forKey: AnyCodingKey(stringValue: "ipv4")!)
        media = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "media")!)) ?? ""
    }
}

struct IpEntry: Decodable {
    let ipaddr: String
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        ipaddr = (try? container.decode(String.self, forKey: AnyCodingKey(stringValue: "ipaddr")!)) ?? ""
    }
}

private struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue; stringValue = "\(intValue)" }
}
