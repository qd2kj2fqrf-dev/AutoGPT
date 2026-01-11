// PetroWiseWidgets.swift
// Home Screen widgets for quick stats

import SwiftUI
import WidgetKit

// MARK: - Widget Entry
struct PetroWiseEntry: TimelineEntry {
    let date: Date
    let fuelSummary: FuelSummary?
    let pendingOrderCount: Int
}

// MARK: - Widget Provider
struct PetroWiseProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetroWiseEntry {
        PetroWiseEntry(
            date: Date(),
            fuelSummary: FuelSummary.mockData(),
            pendingOrderCount: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PetroWiseEntry) -> Void) {
        let entry = PetroWiseEntry(
            date: Date(),
            fuelSummary: loadCachedFuelSummary(),
            pendingOrderCount: loadCachedOrderCount()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetroWiseEntry>) -> Void) {
        let entry = PetroWiseEntry(
            date: Date(),
            fuelSummary: loadCachedFuelSummary(),
            pendingOrderCount: loadCachedOrderCount()
        )

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCachedFuelSummary() -> FuelSummary? {
        // Load from shared UserDefaults (app group)
        guard let data = UserDefaults(suiteName: "group.com.jrdcompanies.petrowise")?.data(forKey: "fuelSummary"),
              let summary = try? JSONDecoder().decode(FuelSummary.self, from: data) else {
            return FuelSummary.mockData()
        }
        return summary
    }

    private func loadCachedOrderCount() -> Int {
        UserDefaults(suiteName: "group.com.jrdcompanies.petrowise")?.integer(forKey: "pendingOrderCount") ?? 0
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: PetroWiseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "fuelpump.fill")
                    .foregroundStyle(Color.petroOrange)
                Text("PetroWise")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }

            Spacer()

            if let summary = entry.fuelSummary {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.0f gal", summary.totalGallons))
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text(String(format: "$%.0f", summary.totalRevenue))
                        .font(.headline)
                        .foregroundStyle(Color.petroGreen)

                    Text("Today")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            } else {
                Text("No data")
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color.petroBackground)
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: PetroWiseEntry

    var body: some View {
        HStack(spacing: 16) {
            // Fuel Stats
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "fuelpump.fill")
                        .foregroundStyle(Color.petroOrange)
                    Text("Fuel Today")
                        .font(.caption.bold())
                        .foregroundStyle(.gray)
                }

                if let summary = entry.fuelSummary {
                    Text(String(format: "%.0f", summary.totalGallons))
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    + Text(" gal")
                        .font(.caption)
                        .foregroundStyle(.gray)

                    Text(String(format: "$%.2f", summary.totalRevenue))
                        .font(.headline)
                        .foregroundStyle(Color.petroGreen)

                    Text("\(summary.transactionCount) transactions")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .background(Color.petroBorder)

            // Work Orders
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "wrench.fill")
                        .foregroundStyle(Color.petroOrange)
                    Text("Work Orders")
                        .font(.caption.bold())
                        .foregroundStyle(.gray)
                }

                Text("\(entry.pendingOrderCount)")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                + Text(" pending")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Text("Tap to view")
                    .font(.caption2)
                    .foregroundStyle(Color.petroOrange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.petroBackground)
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: PetroWiseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "fuelpump.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.petroOrange)

                VStack(alignment: .leading) {
                    Text("PetroWise")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Holiday #3851")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Spacer()

                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Divider()
                .background(Color.petroBorder)

            // Fuel Summary
            if let summary = entry.fuelSummary {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Fuel Sales")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)

                    HStack(spacing: 20) {
                        StatBox(
                            title: "Gallons",
                            value: String(format: "%.0f", summary.totalGallons),
                            color: .blue
                        )

                        StatBox(
                            title: "Revenue",
                            value: String(format: "$%.0f", summary.totalRevenue),
                            color: Color.petroGreen
                        )

                        StatBox(
                            title: "Trans",
                            value: "\(summary.transactionCount)",
                            color: Color.petroOrange
                        )
                    }
                }
            }

            Divider()
                .background(Color.petroBorder)

            // Work Orders
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pending Work Orders")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)

                    Text("\(entry.pendingOrderCount) orders waiting")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(entry.pendingOrderCount > 0 ? Color.petroOrange : Color.petroGreen)
                        .frame(width: 40, height: 40)

                    Text("\(entry.pendingOrderCount)")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            // Quick Actions
            HStack(spacing: 12) {
                QuickActionWidget(icon: "fuelpump", label: "Log Fuel")
                QuickActionWidget(icon: "wrench", label: "New Order")
                QuickActionWidget(icon: "chart.bar", label: "Reports")
            }
        }
        .padding()
        .background(Color.petroBackground)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct QuickActionWidget: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.petroOrange)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.petroCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Widget Definition
struct PetroWiseWidget: Widget {
    let kind: String = "PetroWiseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetroWiseProvider()) { entry in
            Group {
                switch WidgetFamily.systemSmall {
                default:
                    SmallWidgetView(entry: entry)
                }
            }
            .containerBackground(Color.petroBackground, for: .widget)
        }
        .configurationDisplayName("PetroWise")
        .description("Quick view of fuel sales and work orders")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle
// Note: Widget bundle should be in a separate widget extension target
// This is the widget configuration that would be used in the extension
struct PetroWiseWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetroWiseWidget()
    }
}

// MARK: - Preview Provider
#if DEBUG
struct PetroWiseWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallWidgetView(entry: PetroWiseEntry(
                date: Date(),
                fuelSummary: FuelSummary.mockData(),
                pendingOrderCount: 3
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small")

            MediumWidgetView(entry: PetroWiseEntry(
                date: Date(),
                fuelSummary: FuelSummary.mockData(),
                pendingOrderCount: 3
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")

            LargeWidgetView(entry: PetroWiseEntry(
                date: Date(),
                fuelSummary: FuelSummary.mockData(),
                pendingOrderCount: 3
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large")
        }
    }
}
#endif
