import SwiftUI

struct SettingsView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var baseUrl: String
    @State private var apiKey: String
    @State private var apiSecret: String
    @State private var refreshInterval: String
    @State private var blurIp: Bool

    init(state: AppState) {
        self.state = state
        _baseUrl = State(initialValue: state.config.baseUrl)
        _apiKey = State(initialValue: state.config.apiKey)
        _apiSecret = State(initialValue: state.config.apiSecret)
        _refreshInterval = State(initialValue: String(state.config.refreshIntervalSeconds))
        _blurIp = State(initialValue: state.config.blurIpAddress)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.headline)
                .foregroundStyle(Color(red: 0.80, green: 0.84, blue: 0.96))

            Form {
                TextField("Base URL", text: $baseUrl)
                    .textFieldStyle(.roundedBorder)
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                SecureField("API Secret", text: $apiSecret)
                    .textFieldStyle(.roundedBorder)
                TextField("Refresh Interval (seconds)", text: $refreshInterval)
                    .textFieldStyle(.roundedBorder)
                Toggle("Blur IP Addresses", isOn: $blurIp)
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Save") {
                    state.config.baseUrl = baseUrl.trimmingCharacters(in: .whitespaces)
                    state.config.apiKey = apiKey.trimmingCharacters(in: .whitespaces)
                    state.config.apiSecret = apiSecret
                    state.config.refreshIntervalSeconds = Int(refreshInterval) ?? 5
                    state.config.blurIpAddress = blurIp
                    ConfigManager.save(state.config)
                    state.configure()
                    Task { await state.refresh() }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 400)
        .background(Color(red: 0.12, green: 0.12, blue: 0.17))
    }
}
