import SwiftUI

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @Bindable var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider().background(Color(red: 0.19, green: 0.20, blue: 0.27))
            interfaceList
            Divider().background(Color(red: 0.19, green: 0.20, blue: 0.27))
            statusBar
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.17))
        .frame(width: 360)
    }

    private var titleBar: some View {
        HStack(spacing: 6) {
            Text("\u{2B21}")
                .font(.title2)
                .foregroundStyle(Color(red: 0.54, green: 0.71, blue: 0.98))
            Text("OPNsense Widget")
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.80, green: 0.84, blue: 0.96))
            Spacer()
            Text(state.refreshTime)
                .font(.caption)
                .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))
            Button {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(red: 0.09, green: 0.09, blue: 0.13))
    }

    private var interfaceList: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(state.visibleInterfaces) { iface in
                    InterfaceCardView(state: state, iface: iface)
                }
            }
            .padding(8)
        }
    }

    private var statusBar: some View {
        HStack {
            Text("Lennox Technology")
                .font(.caption)
                .foregroundStyle(Color(red: 0.34, green: 0.35, blue: 0.42))
                .onTapGesture {
                    openWindow(id: "about")
                    NSApp.activate(ignoringOtherApps: true)
                }
            Spacer()
            Text(state.statusText)
                .font(.caption)
                .foregroundStyle(state.statusColor)
            Button {
                openWindow(id: "about")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))
            }
            .buttonStyle(.plain)
            Button("Refresh") {
                Task { await state.refresh() }
            }
            .buttonStyle(.plain)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(red: 0.27, green: 0.28, blue: 0.35))
            .foregroundStyle(Color(red: 0.80, green: 0.84, blue: 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(red: 0.09, green: 0.09, blue: 0.13))
    }
}
