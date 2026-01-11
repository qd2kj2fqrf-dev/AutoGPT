import SwiftUI
import Integrations_and_automations

@main
struct PetroWiseMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Theme colors
    private let backgroundColor = Color(hex: "#0a0a0a")

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DashboardView()
            }
            .frame(minWidth: 420, idealWidth: 480, maxWidth: 600, minHeight: 700, idealHeight: 900, maxHeight: 1200)
            .background(backgroundColor)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About PetroWise") {
                    NSApplication.shared.orderFrontStandardAboutPanel(options: [
                        NSApplication.AboutPanelOptionKey.applicationName: "JRD PetroWise",
                        NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                        NSApplication.AboutPanelOptionKey.credits: NSAttributedString(string: "Operations dashboard for JRD Companies")
                    ])
                }
            }
            CommandGroup(replacing: .newItem) { }
        }

        MenuBarExtra("PetroWise", systemImage: "fuelpump.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app appearance
        NSApp.appearance = NSAppearance(named: .darkAqua)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in menu bar
    }
}

// MARK: - Menu Bar View

struct MenuBarView: View {
    @State private var fuelSummary = APIClient.mockFuelSummary()
    @State private var autoSummary = APIClient.mockAutoSummary()
    @State private var services = APIClient.mockServices()
    @State private var isRefreshing = false
    @State private var lastRefresh: Date?

    private let apiClient = APIClient()

    // Theme colors
    private let backgroundColor = Color(hex: "#0a0a0a")
    private let cardBackground = Color(hex: "#141414")
    private let orangeAccent = Color(hex: "#f97316")
    private let greenAccent = Color(hex: "#22c55e")
    private let textPrimary = Color.white
    private let textSecondary = Color.white.opacity(0.7)

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "fuelpump.fill")
                    .foregroundColor(orangeAccent)
                Text("JRD PetroWise")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textPrimary)
                Spacer()
                if isRefreshing {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: orangeAccent))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Divider()
                .background(Color.white.opacity(0.1))

            // Quick Stats
            VStack(spacing: 12) {
                quickStatRow(
                    icon: "fuelpump",
                    title: "Fuel Revenue",
                    value: formatCurrency(fuelSummary.totalRevenue),
                    subtitle: "Holiday #3851",
                    color: orangeAccent
                )

                quickStatRow(
                    icon: "wrench.and.screwdriver",
                    title: "Auto Revenue",
                    value: formatCurrency(autoSummary.totalRevenue),
                    subtitle: "Maplewood Auto",
                    color: greenAccent
                )

                quickStatRow(
                    icon: "network",
                    title: "Services Online",
                    value: "\(services.filter { $0.status == .online }.count)/\(services.count)",
                    subtitle: "Integrations",
                    color: greenAccent
                )
            }
            .padding(.horizontal, 16)

            Divider()
                .background(Color.white.opacity(0.1))

            // Service Status
            VStack(alignment: .leading, spacing: 8) {
                Text("Service Status")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(textSecondary)
                    .textCase(.uppercase)

                ForEach(services.prefix(4)) { service in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(statusColor(for: service.status))
                            .frame(width: 6, height: 6)

                        Text(service.name)
                            .font(.system(size: 12))
                            .foregroundColor(textPrimary)

                        Spacer()

                        if let responseTime = service.responseTime {
                            Text("\(responseTime)ms")
                                .font(.system(size: 10))
                                .foregroundColor(textSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Divider()
                .background(Color.white.opacity(0.1))

            // Actions
            VStack(spacing: 8) {
                Button(action: refreshData) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                        Spacer()
                        if let lastRefresh = lastRefresh {
                            Text(lastRefresh, style: .time)
                                .font(.system(size: 10))
                                .foregroundColor(textSecondary)
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(cardBackground)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button(action: openMainWindow) {
                    HStack {
                        Image(systemName: "rectangle.expand.vertical")
                        Text("Open Dashboard")
                        Spacer()
                        Text("Cmd+O")
                            .font(.system(size: 10))
                            .foregroundColor(textSecondary)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(cardBackground)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("o", modifiers: .command)

                Divider()
                    .background(Color.white.opacity(0.1))

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit PetroWise")
                        Spacer()
                        Text("Cmd+Q")
                            .font(.system(size: 10))
                            .foregroundColor(textSecondary)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(width: 280)
        .background(backgroundColor)
        .task {
            refreshData()
        }
    }

    private func quickStatRow(icon: String, title: String, value: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }

            Spacer()

            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(textSecondary)
        }
        .padding(10)
        .background(cardBackground)
        .cornerRadius(8)
    }

    private func statusColor(for status: ServiceStatus) -> Color {
        switch status {
        case .online: return greenAccent
        case .offline: return Color.red
        case .degraded: return Color.yellow
        case .unknown: return Color.gray
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    private func refreshData() {
        isRefreshing = true

        Task {
            do {
                let data = try await apiClient.refreshAll()
                await MainActor.run {
                    fuelSummary = data.fuelSummary
                    autoSummary = data.autoSummary
                    services = data.services
                    lastRefresh = Date()
                    isRefreshing = false
                }
            } catch {
                // Keep mock data on error
                await MainActor.run {
                    lastRefresh = Date()
                    isRefreshing = false
                }
            }
        }
    }

    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title.contains("PetroWise") || $0.contentView != nil }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // Open new window if none exists
            for window in NSApp.windows {
                if window.contentView != nil && !window.isKind(of: NSPanel.self) {
                    window.makeKeyAndOrderFront(nil)
                    break
                }
            }
        }
    }
}

#Preview("Menu Bar") {
    MenuBarView()
        .frame(width: 280, height: 500)
}
