import SwiftUI

struct InterfaceCardView: View {
    @Bindable var state: AppState
    @Bindable var iface: InterfaceDisplay

    var body: some View {
        HStack(spacing: 6) {
            VStack(spacing: 2) {
                Button { state.moveUp(iface) } label: {
                    Image(systemName: "chevron.up")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .disabled(state.visibleInterfaces.first?.id == iface.id)

                Button { state.moveDown(iface) } label: {
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .disabled(state.visibleInterfaces.last?.id == iface.id)
            }
            .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))
            .frame(width: 16)

            Circle()
                .fill(iface.isUp ? Color(red: 0.65, green: 0.89, blue: 0.63) : Color(red: 0.95, green: 0.54, blue: 0.66))
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if iface.isEditing {
                        TextField("Name", text: Binding(
                            get: { iface.customName },
                            set: { iface.customName = $0 }
                        ), onCommit: { state.commitRename(iface) })
                        .textFieldStyle(.plain)
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color(red: 0.80, green: 0.84, blue: 0.96))
                        .padding(2)
                        .background(Color(red: 0.19, green: 0.20, blue: 0.27))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    } else {
                        Text(iface.displayName)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(red: 0.80, green: 0.84, blue: 0.96))
                    }
                    Spacer()
                    Button { iface.isEditing = true } label: {
                        Image(systemName: "pencil")
                            .font(.caption2)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))
                }

                Text(iface.description)
                    .font(.caption2)
                    .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 1) {
                        if iface.blurIpAddress {
                            Text(iface.ipAddress)
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.65, green: 0.68, blue: 0.78))
                                .blur(radius: 6)
                        } else {
                            Text(iface.ipAddress)
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.65, green: 0.68, blue: 0.78))
                        }
                        Text(iface.macAddress)
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.34, green: 0.35, blue: 0.42))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(iface.displaySpeed)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(red: 0.65, green: 0.68, blue: 0.78))
                        Text(iface.status)
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.65, green: 0.89, blue: 0.63))
                    }
                }

                HStack(alignment: .top) {
                    HStack(spacing: 2) {
                        Text("\u{2193}")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.54, green: 0.71, blue: 0.98))
                        Text(iface.bandwidthIn)
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.65, green: 0.68, blue: 0.78))
                        Text("\u{2191}")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.98, green: 0.70, blue: 0.53))
                            .padding(.leading, 4)
                        Text(iface.bandwidthOut)
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.65, green: 0.68, blue: 0.78))
                    }
                }

                BandwidthGraphView(
                    inHistory: iface.inHistory,
                    outHistory: iface.outHistory,
                    scale: iface.scale
                )
                .frame(height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(red: 0.19, green: 0.20, blue: 0.27), lineWidth: 1)
                )
            }

            Button {
                state.toggleVisibility(iface)
            } label: {
                Text(iface.isHidden ? "Show" : "Hide")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(red: 0.42, green: 0.44, blue: 0.52))
        }
        .padding(8)
        .background(Color(red: 0.09, green: 0.09, blue: 0.13))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(red: 0.19, green: 0.20, blue: 0.27), lineWidth: 1)
        )
    }
}
