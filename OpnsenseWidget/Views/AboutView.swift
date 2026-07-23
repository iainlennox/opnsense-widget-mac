import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("\u{2B21}")
                .font(.system(size: 48))
                .foregroundStyle(Color(red: 0.54, green: 0.71, blue: 0.98))
            Text("OPNsense Widget")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.80, green: 0.84, blue: 0.96))
            Text("macOS Menu Bar App")
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))
            Divider().background(Color(red: 0.19, green: 0.20, blue: 0.27))
            Text("By Iain Lennox")
                .font(.caption)
                .foregroundStyle(Color(red: 0.34, green: 0.35, blue: 0.42))
            Text("Lennox Technology")
                .font(.caption)
                .foregroundStyle(Color(red: 0.34, green: 0.35, blue: 0.42))
            Button("OK") { dismiss() }
                .keyboardShortcut(.defaultAction)
        }
        .padding(24)
        .frame(width: 300)
        .background(Color(red: 0.12, green: 0.12, blue: 0.17))
    }
}
