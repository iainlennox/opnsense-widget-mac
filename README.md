# OPNsense Widget

A macOS menu bar application that monitors OPNsense firewall interfaces in real time.

Sits in the menu bar and displays interface status (link speed, IP, MAC, up/down) and bandwidth usage in a compact window with a dark theme.

## Features

- Real-time interface monitoring via OPNsense API
- Real-time bandwidth usage with per-interface graph
- Menu bar integration with popover window
- Show/hide individual interfaces
- Reorder interfaces with up/down buttons
- Rename interfaces with custom labels
- Bandwidth display (auto-formatted, e.g. 1 Gbps, 10 Mbps)
- Auto-refresh on configurable interval
- Remembers window position and interface layout

## Requirements

- macOS 15+ (Sonoma or later)
- [Xcode 27+](https://developer.apple.com/xcode/)
- OPNsense firewall with API access enabled

## Setup

1. In OPNsense, go to **System > Access > Users** and edit your user
2. Add an API key under the **API keys** section
3. Launch the app, click the gear icon, and enter:
   - Base URL (e.g. `https://192.168.1.1`)
   - API Key
   - API Secret
   - Refresh interval (default 5 seconds)

## Build

```shell
xcodebuild -scheme OpnsenseWidget -project OpnsenseWidget.xcodeproj build
```

## Usage

- The app starts as a menu bar icon (shield icon)
- Click **Show Widget** from the menu to open the interface window
- Each interface card shows: name, description, IP address, MAC address, link speed, status, and bandwidth graph
- Use the ▲/▼ buttons to reorder interfaces
- Click the pencil icon to rename an interface
- Click **Hide** to remove an interface from the list
- The app runs as a menu bar accessory — close the window to hide it; use **Quit** from the menu to exit

## Screenshots

<img width="360" alt="Opnsense Widget" src="https://github.com/user-attachments/assets/019d5aea-6624-4310-9ecf-7ced7b574325" />

## Author

**Iain Lennox** — [iain@lennoxfamily.net](mailto:iain@lennoxfamily.net)

Lennox Technology

---

*Made with ❤️ in Scotland*
