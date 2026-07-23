import Foundation

class OpnsenseApiClient {
    private let session: URLSession
    private var baseUrl: String = ""
    private var apiKey: String = ""
    private var apiSecret: String = ""

    var isConfigured: Bool {
        !baseUrl.isEmpty && !apiKey.isEmpty && !apiSecret.isEmpty
    }

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config, delegate: InsecureSessionDelegate(), delegateQueue: nil)
    }

    func configure(baseUrl: String, apiKey: String, apiSecret: String) {
        self.baseUrl = baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.apiKey = apiKey
        self.apiSecret = apiSecret
    }

    private func sendRequest(path: String) async throws -> (Data, URLResponse) {
        let url = URL(string: "\(baseUrl)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let auth = "\(apiKey):\(apiSecret)"
        guard let authData = auth.data(using: .utf8) else {
            throw ApiError.authEncodeFailed
        }
        let base64 = authData.base64EncodedString()
        request.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        if httpResponse.statusCode == 401 {
            let body = String(data: data, encoding: .utf8)?.prefix(500) ?? "no body"
            throw ApiError.unauthorized(body: String(body))
        }
        if httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8)?.prefix(500) ?? "no body"
            throw ApiError.httpError(statusCode: httpResponse.statusCode, body: String(body))
        }
        return (data, response)
    }

    func getInterfaceOverview() async throws -> [InterfaceDisplay] {
        guard isConfigured else { throw ApiError.notConfigured }
        let (data, _) = try await sendRequest(path: "/api/interfaces/overview/interfacesInfo")
        let response: InterfacesInfoResponse
        do {
            response = try JSONDecoder().decode(InterfacesInfoResponse.self, from: data)
        } catch {
            let preview = String(data: data, encoding: .utf8)?.prefix(2000) ?? "no data"
            throw ApiError.decodeError(endpoint: "/api/interfaces/overview/interfacesInfo", raw: String(preview), underlying: error)
        }

        return response.rows.map { row in
            let iface = InterfaceDisplay()
            iface.name = row.device
            iface.description = row.description
            iface.status = row.status
            iface.ipAddress = row.ipv4?.first?.ipaddr ?? row.addr4
            iface.macAddress = row.macaddr
            iface.linkSpeed = row.media
            return iface
        }
    }

    func getTraffic() async throws -> [String: InterfaceTraffic] {
        guard isConfigured else { throw ApiError.notConfigured }
        let (data, _) = try await sendRequest(path: "/api/diagnostics/traffic/interface")
        let response: TrafficResponse
        do {
            response = try JSONDecoder().decode(TrafficResponse.self, from: data)
        } catch {
            let preview = String(data: data, encoding: .utf8)?.prefix(2000) ?? "no data"
            throw ApiError.decodeError(endpoint: "/api/diagnostics/traffic/interface", raw: String(preview), underlying: error)
        }
        return response.interfaces
    }
}

enum ApiError: LocalizedError {
    case notConfigured
    case authEncodeFailed
    case invalidResponse
    case unauthorized(body: String)
    case httpError(statusCode: Int, body: String)
    case decodeError(endpoint: String, raw: String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured: "API client is not configured"
        case .authEncodeFailed: "Failed to encode API credentials"
        case .invalidResponse: "Invalid response from server"
        case .unauthorized: "401 Unauthorized — check your API key/secret"
        case .httpError(let statusCode, let body):
            "HTTP \(statusCode)\n\(body)"
        case .decodeError(let endpoint, let raw, let underlying):
            "Decode error from \(endpoint): \(underlying.localizedDescription)\nRaw: \(raw)"
        }
    }
}

private class InsecureSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
