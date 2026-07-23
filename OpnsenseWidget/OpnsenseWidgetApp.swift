import SwiftUI

@main
struct OpnsenseWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var state = AppState()
    @State private var refreshTimer: Timer?
    @State private var bandwidthTimer: Timer?

    var body: some Scene {
        MenuBarExtra("OPNsense Widget", systemImage: "shield.lefthalf.filled") {
            ShowWidgetButton(state: state)
            Divider()
            Button("Refresh") {
                Task { await state.refresh() }
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }

        Window("OPNsense Widget", id: "main") {
            ContentView(state: state)
                .onAppear {
                    startTimers()
                    Task { await state.refresh() }
                }
                .onDisappear {
                    stopTimers()
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 360, height: 500)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: true))

        Window("Settings", id: "settings") {
            SettingsView(state: state)
        }
        .windowResizability(.contentSize)

        Window("About", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }

    private func startTimers() {
        stopTimers()
        let interval = TimeInterval(state.config.refreshIntervalSeconds)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { await state.refresh() }
        }
        bandwidthTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { await state.pollBandwidth() }
        }
    }

    private func stopTimers() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        bandwidthTimer?.invalidate()
        bandwidthTimer = nil
    }
}

struct ShowWidgetButton: View {
    @Environment(\.openWindow) private var openWindow
    let state: AppState

    var body: some View {
        Button("Show Widget") {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "main")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let mainWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "main" }) {
                mainWindow.close()
            }
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
