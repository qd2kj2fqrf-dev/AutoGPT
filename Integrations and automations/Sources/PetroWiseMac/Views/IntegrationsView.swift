import SwiftUI
import Integrations_and_automations

struct IntegrationsView: View {
    let services: [DiscoveredService]

    @State private var searchText = ""
    @State private var filterStatus: ServiceStatus?

    // Theme colors
    private let backgroundColor = Color(hex: "#0a0a0a")
    private let cardBackground = Color(hex: "#141414")
    private let orangeAccent = Color(hex: "#f97316")
    private let greenAccent = Color(hex: "#22c55e")
    private let textPrimary = Color.white
    private let textSecondary = Color.white.opacity(0.7)

    private var filteredServices: [DiscoveredService] {
        var result = services

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }

        return result
    }

    private var onlineCount: Int {
        services.filter { $0.status == .online }.count
    }

    private var offlineCount: Int {
        services.filter { $0.status == .offline }.count
    }

    private var degradedCount: Int {
        services.filter { $0.status == .degraded }.count
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                statusSummary
                searchAndFilter
                servicesList
            }
        }
        .navigationTitle("Discovered Services")
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "network")
                    .font(.system(size: 24))
                    .foregroundColor(orangeAccent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Integration Status")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(textPrimary)

                    Text("\(services.count) services discovered")
                        .font(.system(size: 13))
                        .foregroundColor(textSecondary)
                }

                Spacer()
            }
        }
        .padding(20)
        .background(cardBackground)
    }

    // MARK: - Status Summary

    private var statusSummary: some View {
        HStack(spacing: 16) {
            statusBadge(count: onlineCount, status: .online)
            statusBadge(count: degradedCount, status: .degraded)
            statusBadge(count: offlineCount, status: .offline)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func statusBadge(count: Int, status: ServiceStatus) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor(for: status))
                .frame(width: 10, height: 10)

            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textPrimary)

            Text(status.displayName)
                .font(.system(size: 12))
                .foregroundColor(textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(cardBackground)
        .cornerRadius(10)
        .onTapGesture {
            if filterStatus == status {
                filterStatus = nil
            } else {
                filterStatus = status
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(filterStatus == status ? statusColor(for: status) : Color.clear, lineWidth: 2)
        )
    }

    // MARK: - Search and Filter

    private var searchAndFilter: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(textSecondary)

                TextField("Search services...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(textPrimary)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(cardBackground)
            .cornerRadius(10)

            if filterStatus != nil {
                Button(action: { filterStatus = nil }) {
                    Text("Clear")
                        .font(.system(size: 12))
                        .foregroundColor(orangeAccent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Services List

    private var servicesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredServices) { service in
                    serviceCard(service: service)
                }

                if filteredServices.isEmpty {
                    emptyState
                }
            }
            .padding(20)
        }
    }

    private func serviceCard(service: DiscoveredService) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(statusColor(for: service.status))
                    .frame(width: 12, height: 12)

                Text(service.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textPrimary)

                Spacer()

                Text(service.status.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(statusColor(for: service.status))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor(for: service.status).opacity(0.15))
                    .cornerRadius(6)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            VStack(alignment: .leading, spacing: 8) {
                infoRow(label: "Endpoint", value: service.endpoint)

                if let responseTime = service.responseTime {
                    infoRow(label: "Response Time", value: "\(responseTime)ms", valueColor: responseTimeColor(responseTime))
                }

                if let lastChecked = service.lastChecked {
                    infoRow(label: "Last Checked", value: formatTime(lastChecked))
                }
            }
        }
        .padding(16)
        .background(cardBackground)
        .cornerRadius(12)
    }

    private func infoRow(label: String, value: String, valueColor: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(valueColor ?? textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(textSecondary)

            Text("No services found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textPrimary)

            Text("Try adjusting your search or filter")
                .font(.system(size: 13))
                .foregroundColor(textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Helpers

    private func statusColor(for status: ServiceStatus) -> Color {
        switch status {
        case .online: return greenAccent
        case .offline: return Color.red
        case .degraded: return Color.yellow
        case .unknown: return Color.gray
        }
    }

    private func responseTimeColor(_ ms: Int) -> Color {
        switch ms {
        case 0..<200: return greenAccent
        case 200..<500: return Color.yellow
        default: return Color.red
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    IntegrationsView(services: APIClient.mockServices())
        .frame(width: 400, height: 600)
}
