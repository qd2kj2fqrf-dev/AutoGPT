import SwiftUI
import Integrations_and_automations

struct DashboardView: View {
    @State private var dashboardData = DashboardData()
    @State private var isRefreshing = false
    @State private var selectedTab = 0

    private let apiClient = APIClient()

    // Theme colors
    private let backgroundColor = Color(hex: "#0a0a0a")
    private let cardBackground = Color(hex: "#141414")
    private let orangeAccent = Color(hex: "#f97316")
    private let greenAccent = Color(hex: "#22c55e")
    private let textPrimary = Color.white
    private let textSecondary = Color.white.opacity(0.7)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    statsOverview
                    fuelOperationsCard
                    autoOperationsCard

                    NavigationLink(destination: IntegrationsView(services: dashboardData.services)) {
                        integrationStatusCard
                    }
                    .buttonStyle(.plain)

                    refreshSection
                }
                .padding(20)
            }
        }
        .task {
            await refreshData()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("JRD PetroWise")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(textPrimary)

                Text("Operations Dashboard")
                    .font(.system(size: 14))
                    .foregroundColor(textSecondary)
            }

            Spacer()

            if let lastRefresh = dashboardData.lastRefresh {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Last Updated")
                        .font(.system(size: 10))
                        .foregroundColor(textSecondary)
                    Text(lastRefresh, style: .time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(orangeAccent)
                }
            }
        }
    }

    // MARK: - Stats Overview

    private var statsOverview: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Fuel Revenue",
                value: formatCurrency(dashboardData.fuelSummary.totalRevenue),
                subtitle: "\(String(format: "%.0f", dashboardData.fuelSummary.totalGallonsSold)) gal",
                color: orangeAccent
            )

            statCard(
                title: "Auto Revenue",
                value: formatCurrency(dashboardData.autoSummary.totalRevenue),
                subtitle: "\(dashboardData.autoSummary.completedToday) completed",
                color: greenAccent
            )

            statCard(
                title: "Services",
                value: "\(dashboardData.services.filter { $0.status == .online }.count)/\(dashboardData.services.count)",
                subtitle: "Online",
                color: greenAccent
            )
        }
    }

    private func statCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(textSecondary)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Fuel Operations

    private var fuelOperationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fuelpump.fill")
                    .foregroundColor(orangeAccent)
                Text("Fuel Operations")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textPrimary)
                Spacer()
                Text("Holiday #3851")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            if dashboardData.fuelSummary.fuelGrades.isEmpty {
                emptyState(message: "No fuel data available")
            } else {
                ForEach(dashboardData.fuelSummary.fuelGrades) { grade in
                    fuelGradeRow(grade: grade)
                }
            }

            HStack {
                Text("Total")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textPrimary)
                Spacer()
                Text(formatCurrency(dashboardData.fuelSummary.totalRevenue))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(orangeAccent)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(16)
    }

    private func fuelGradeRow(grade: FuelGrade) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(grade.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textPrimary)
                Text("\(String(format: "%.1f", grade.gallonsSold)) gal @ $\(String(format: "%.2f", grade.pricePerGallon))")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
            }
            Spacer()
            Text(formatCurrency(grade.revenue))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textPrimary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Auto Operations

    private var autoOperationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(greenAccent)
                Text("Auto Operations")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textPrimary)
                Spacer()
                Text("Maplewood Auto")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            HStack(spacing: 24) {
                autoStatPill(value: "\(dashboardData.autoSummary.totalWorkOrders)", label: "Total Orders")
                autoStatPill(value: "\(dashboardData.autoSummary.completedToday)", label: "Today")
                autoStatPill(value: "\(dashboardData.autoSummary.pendingOrders)", label: "Pending")
            }

            if !dashboardData.autoSummary.topServices.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Services")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textSecondary)
                        .textCase(.uppercase)

                    ForEach(dashboardData.autoSummary.topServices) { service in
                        HStack {
                            Text(service.name)
                                .font(.system(size: 13))
                                .foregroundColor(textPrimary)
                            Spacer()
                            Text("\(service.count)x")
                                .font(.system(size: 12))
                                .foregroundColor(textSecondary)
                            Text(formatCurrency(service.revenue))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(greenAccent)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(16)
    }

    private func autoStatPill(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(greenAccent)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(textSecondary)
        }
    }

    // MARK: - Integration Status

    private var integrationStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(orangeAccent)
                Text("Integration Status")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(textSecondary)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            if dashboardData.services.isEmpty {
                emptyState(message: "No services discovered")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(dashboardData.services.prefix(6)) { service in
                        serviceStatusPill(service: service)
                    }
                }

                if dashboardData.services.count > 6 {
                    Text("+\(dashboardData.services.count - 6) more services")
                        .font(.system(size: 11))
                        .foregroundColor(textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(16)
    }

    private func serviceStatusPill(service: DiscoveredService) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor(for: service.status))
                .frame(width: 8, height: 8)

            Text(service.name)
                .font(.system(size: 12))
                .foregroundColor(textPrimary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
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

    // MARK: - Refresh Section

    private var refreshSection: some View {
        HStack {
            Button(action: {
                Task {
                    await refreshData()
                }
            }) {
                HStack(spacing: 8) {
                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Refresh APIs")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(orangeAccent)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(isRefreshing)

            Spacer()

            if let error = dashboardData.error {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Empty State

    private func emptyState(message: String) -> some View {
        Text(message)
            .font(.system(size: 13))
            .foregroundColor(textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func refreshData() async {
        isRefreshing = true
        dashboardData.error = nil

        do {
            dashboardData = try await apiClient.refreshAll()
        } catch {
            // Use mock data if API fails
            dashboardData.fuelSummary = APIClient.mockFuelSummary()
            dashboardData.autoSummary = APIClient.mockAutoSummary()
            dashboardData.services = APIClient.mockServices()
            dashboardData.lastRefresh = Date()
            dashboardData.error = "Using mock data (backend offline)"
        }

        isRefreshing = false
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    DashboardView()
        .frame(width: 400, height: 800)
}
