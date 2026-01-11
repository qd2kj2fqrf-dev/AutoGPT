// FuelTab.swift
// Fuel operations management - transactions, inventory, pricing

import SwiftUI
import Charts

struct FuelTab: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeRange: TimeRange = .today
    @State private var transactions: [FuelTransaction] = []
    @State private var inventory: FuelInventory?
    @State private var isLoading = false
    @State private var showAddDelivery = false
    @State private var showPriceUpdate = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Time Range Picker
                        TimeRangePicker(selection: $selectedTimeRange)
                            .onChange(of: selectedTimeRange) { _, _ in
                                Task { await loadData() }
                            }

                        // Fuel Inventory Card
                        FuelInventoryCard(inventory: inventory)

                        // Sales Chart
                        FuelSalesChart(transactions: transactions, timeRange: selectedTimeRange)

                        // Transactions List
                        FuelTransactionsCard(transactions: transactions)

                        // Action Buttons
                        FuelActionsCard(
                            onAddDelivery: { showAddDelivery = true },
                            onUpdatePrices: { showPriceUpdate = true }
                        )
                    }
                    .padding()
                }
                .refreshable {
                    await loadData()
                }

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.petroOrange)
                }
            }
            .navigationTitle("Fuel")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.petroBackground, for: .navigationBar)
            #endif
            .sheet(isPresented: $showAddDelivery) {
                AddDeliveryView()
            }
            .sheet(isPresented: $showPriceUpdate) {
                UpdatePricesView()
            }
            .onAppear {
                Task { await loadData() }
            }
        }
    }

    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let transactionsTask = appState.apiClient.fetchFuelTransactions(range: selectedTimeRange)
            async let inventoryTask = appState.apiClient.fetchFuelInventory()

            let (txns, inv) = try await (transactionsTask, inventoryTask)
            transactions = txns
            inventory = inv
        } catch {
            appState.showErrorAlert(error.localizedDescription)
        }
    }
}

// MARK: - Time Range
enum TimeRange: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
    case custom = "Custom"

    var days: Int {
        switch self {
        case .today: return 1
        case .week: return 7
        case .month: return 30
        case .custom: return 30
        }
    }
}

struct TimeRangePicker: View {
    @Binding var selection: TimeRange

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases.filter { $0 != .custom }, id: \.self) { range in
                Button {
                    selection = range
                } label: {
                    Text(range.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(selection == range ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selection == range ? Color.petroOrange : Color.petroCard)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Fuel Inventory Card
struct FuelInventoryCard: View {
    let inventory: FuelInventory?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "cylinder.fill")
                    .foregroundStyle(Color.petroOrange)
                Text("Tank Inventory")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if let inv = inventory {
                    Text("Updated \(inv.lastUpdated, style: .relative)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }

            if let inventory = inventory {
                VStack(spacing: 16) {
                    TankLevelRow(name: "Regular", level: inventory.regularLevel, capacity: inventory.regularCapacity)
                    TankLevelRow(name: "Midgrade", level: inventory.midgradeLevel, capacity: inventory.midgradeCapacity)
                    TankLevelRow(name: "Premium", level: inventory.premiumLevel, capacity: inventory.premiumCapacity)
                    TankLevelRow(name: "Diesel", level: inventory.dieselLevel, capacity: inventory.dieselCapacity)
                }
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "cylinder")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                        Text("Loading inventory...")
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .padding()
        .background(Color.petroCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.petroBorder, lineWidth: 1)
        )
    }
}

struct TankLevelRow: View {
    let name: String
    let level: Double
    let capacity: Double

    var percentage: Double {
        guard capacity > 0 else { return 0 }
        return level / capacity
    }

    var levelColor: Color {
        if percentage < 0.2 { return .red }
        if percentage < 0.4 { return .orange }
        return Color.petroGreen
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .foregroundStyle(.white)
                Spacer()
                Text(String(format: "%.0f / %.0f gal", level, capacity))
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text(String(format: "%.0f%%", percentage * 100))
                    .font(.caption.bold())
                    .foregroundStyle(levelColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.petroBorder)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(levelColor)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Fuel Sales Chart
struct FuelSalesChart: View {
    let transactions: [FuelTransaction]
    let timeRange: TimeRange

    var chartData: [(date: Date, gallons: Double)] {
        let calendar = Calendar.current
        var grouped: [Date: Double] = [:]

        for txn in transactions {
            let day = calendar.startOfDay(for: txn.timestamp)
            grouped[day, default: 0] += txn.gallons
        }

        return grouped.map { ($0.key, $0.value) }.sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.petroOrange)
                Text("Sales Trend")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            if chartData.isEmpty {
                HStack {
                    Spacer()
                    Text("No sales data")
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .frame(height: 150)
            } else {
                Chart(chartData, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Gallons", item.gallons)
                    )
                    .foregroundStyle(Color.petroOrange)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Gallons", item.gallons)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.petroOrange.opacity(0.3), Color.petroOrange.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.petroBorder)
                        AxisValueLabel()
                            .foregroundStyle(.gray)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.petroBorder)
                        AxisValueLabel()
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color.petroCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.petroBorder, lineWidth: 1)
        )
    }
}

// MARK: - Fuel Transactions Card
struct FuelTransactionsCard: View {
    let transactions: [FuelTransaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundStyle(Color.petroOrange)
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(transactions.count) total")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            if transactions.isEmpty {
                HStack {
                    Spacer()
                    Text("No transactions")
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .padding(.vertical)
            } else {
                ForEach(transactions.prefix(10)) { txn in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(txn.fuelType)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                            Text("Pump \(txn.pumpNumber) - \(txn.timestamp, style: .time)")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "$%.2f", txn.total))
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.petroGreen)
                            Text(String(format: "%.2f gal", txn.gallons))
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.vertical, 4)

                    if txn.id != transactions.prefix(10).last?.id {
                        Divider()
                            .background(Color.petroBorder)
                    }
                }
            }
        }
        .padding()
        .background(Color.petroCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.petroBorder, lineWidth: 1)
        )
    }
}

// MARK: - Fuel Actions Card
struct FuelActionsCard: View {
    let onAddDelivery: () -> Void
    let onUpdatePrices: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(Color.petroOrange)
                Text("Management")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            HStack(spacing: 16) {
                Button(action: onAddDelivery) {
                    VStack(spacing: 8) {
                        Image(systemName: "truck.box.fill")
                            .font(.title2)
                        Text("Add Delivery")
                            .font(.caption.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }

                Button(action: onUpdatePrices) {
                    VStack(spacing: 8) {
                        Image(systemName: "dollarsign.arrow.circlepath")
                            .font(.title2)
                        Text("Update Prices")
                            .font(.caption.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(Color.petroOrange.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.petroOrange, lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(Color.petroCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.petroBorder, lineWidth: 1)
        )
    }
}

// MARK: - Add Delivery View
struct AddDeliveryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var fuelType = "Regular"
    @State private var gallons = ""
    @State private var invoiceNumber = ""
    @State private var deliveryDate = Date()

    let fuelTypes = ["Regular", "Midgrade", "Premium", "Diesel"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                Form {
                    Section("Delivery Details") {
                        Picker("Fuel Type", selection: $fuelType) {
                            ForEach(fuelTypes, id: \.self) { Text($0) }
                        }
                        .listRowBackground(Color.petroCard)

                        TextField("Gallons Delivered", text: $gallons)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .listRowBackground(Color.petroCard)

                        TextField("Invoice Number", text: $invoiceNumber)
                            .listRowBackground(Color.petroCard)

                        DatePicker("Delivery Date", selection: $deliveryDate, displayedComponents: .date)
                            .listRowBackground(Color.petroCard)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Delivery")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveDelivery() }
                        .foregroundStyle(Color.petroOrange)
                        .disabled(gallons.isEmpty)
                }
            }
        }
    }

    private func saveDelivery() {
        guard let gal = Double(gallons) else { return }
        Task {
            do {
                try await appState.apiClient.logFuelDelivery(
                    fuelType: fuelType,
                    gallons: gal,
                    invoiceNumber: invoiceNumber,
                    date: deliveryDate
                )
                dismiss()
            } catch {
                appState.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

// MARK: - Update Prices View
struct UpdatePricesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var regularPrice = ""
    @State private var midgradePrice = ""
    @State private var premiumPrice = ""
    @State private var dieselPrice = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                Form {
                    Section("Current Prices (per gallon)") {
                        PriceField(label: "Regular", price: $regularPrice)
                        PriceField(label: "Midgrade", price: $midgradePrice)
                        PriceField(label: "Premium", price: $premiumPrice)
                        PriceField(label: "Diesel", price: $dieselPrice)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Update Prices")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") { updatePrices() }
                        .foregroundStyle(Color.petroOrange)
                }
            }
            .onAppear { loadCurrentPrices() }
        }
    }

    private func loadCurrentPrices() {
        if let summary = appState.fuelSummary {
            regularPrice = String(format: "%.3f", summary.regularPrice)
            midgradePrice = String(format: "%.3f", summary.midgradePrice)
            premiumPrice = String(format: "%.3f", summary.premiumPrice)
            dieselPrice = String(format: "%.3f", summary.dieselPrice)
        }
    }

    private func updatePrices() {
        Task {
            do {
                try await appState.apiClient.updateFuelPrices(
                    regular: Double(regularPrice) ?? 0,
                    midgrade: Double(midgradePrice) ?? 0,
                    premium: Double(premiumPrice) ?? 0,
                    diesel: Double(dieselPrice) ?? 0
                )
                dismiss()
            } catch {
                appState.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

struct PriceField: View {
    let label: String
    @Binding var price: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("$")
                .foregroundStyle(.gray)
            TextField("0.000", text: $price)
                #if os(iOS)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                #endif
                .frame(width: 80)
        }
        .listRowBackground(Color.petroCard)
    }
}

#Preview {
    FuelTab()
        .environmentObject(AppState())
}
