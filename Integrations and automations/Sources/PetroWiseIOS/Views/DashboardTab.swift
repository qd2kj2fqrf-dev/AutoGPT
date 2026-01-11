// DashboardTab.swift
// Main dashboard view with fuel summary, work orders, and quick actions

import SwiftUI

struct DashboardTab: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogFuel = false
    @State private var showLogService = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Today's Fuel Summary Card
                        FuelSummaryCard(summary: appState.fuelSummary)

                        // Pending Work Orders Card
                        WorkOrdersCard(orders: appState.pendingWorkOrders)

                        // Quick Actions
                        QuickActionsCard(
                            onLogFuel: { showLogFuel = true },
                            onLogService: { showLogService = true }
                        )

                        // Recent Activity
                        RecentActivityCard(transactions: appState.recentTransactions)
                    }
                    .padding()
                }
                .refreshable {
                    await appState.refreshDashboard()
                }

                if appState.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.petroOrange)
                }
            }
            .navigationTitle("Dashboard")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.petroBackground, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await appState.refreshDashboard()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(Color.petroOrange)
                    }
                }
            }
            .sheet(isPresented: $showLogFuel) {
                LogFuelView()
            }
            .sheet(isPresented: $showLogService) {
                LogServiceView()
            }
            .onAppear {
                Task {
                    await appState.refreshDashboard()
                }
            }
        }
    }
}

// MARK: - Fuel Summary Card
struct FuelSummaryCard: View {
    let summary: FuelSummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fuelpump.fill")
                    .foregroundStyle(Color.petroOrange)
                Text("Today's Fuel Summary")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            if let summary = summary {
                HStack(spacing: 20) {
                    SummaryItem(
                        title: "Gallons Sold",
                        value: String(format: "%.0f", summary.totalGallons),
                        icon: "drop.fill",
                        color: .blue
                    )

                    SummaryItem(
                        title: "Revenue",
                        value: String(format: "$%.2f", summary.totalRevenue),
                        icon: "dollarsign.circle.fill",
                        color: Color.petroGreen
                    )

                    SummaryItem(
                        title: "Transactions",
                        value: "\(summary.transactionCount)",
                        icon: "arrow.left.arrow.right",
                        color: Color.petroOrange
                    )
                }

                // Fuel Type Breakdown
                Divider()
                    .background(Color.petroBorder)

                VStack(spacing: 12) {
                    FuelTypeRow(name: "Regular", gallons: summary.regularGallons, price: summary.regularPrice)
                    FuelTypeRow(name: "Midgrade", gallons: summary.midgradeGallons, price: summary.midgradePrice)
                    FuelTypeRow(name: "Premium", gallons: summary.premiumGallons, price: summary.premiumPrice)
                    FuelTypeRow(name: "Diesel", gallons: summary.dieselGallons, price: summary.dieselPrice)
                }
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                        Text("No data available")
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

struct SummaryItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FuelTypeRow: View {
    let name: String
    let gallons: Double
    let price: Double

    var body: some View {
        HStack {
            Text(name)
                .foregroundStyle(.gray)
            Spacer()
            Text(String(format: "%.0f gal", gallons))
                .foregroundStyle(.white)
            Text("@")
                .foregroundStyle(.gray)
            Text(String(format: "$%.3f", price))
                .foregroundStyle(Color.petroOrange)
        }
        .font(.caption)
    }
}

// MARK: - Work Orders Card
struct WorkOrdersCard: View {
    let orders: [WorkOrder]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundStyle(Color.petroOrange)
                Text("Pending Work Orders")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if !orders.isEmpty {
                    Text("\(orders.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.petroOrange)
                        .clipShape(Capsule())
                }
            }

            if orders.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color.petroGreen)
                        Text("No pending work orders")
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical)
            } else {
                ForEach(orders.prefix(3)) { order in
                    WorkOrderRow(order: order)
                }

                if orders.count > 3 {
                    NavigationLink {
                        WorkOrdersListView(orders: orders)
                    } label: {
                        Text("View all \(orders.count) orders")
                            .font(.caption)
                            .foregroundStyle(Color.petroOrange)
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

struct WorkOrderRow: View {
    let order: WorkOrder

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(order.priority.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(order.vehicle)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(order.serviceDescription)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(order.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(order.status.color)
                Text(order.estimatedCompletion, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    let onLogFuel: () -> Void
    let onLogService: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color.petroOrange)
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Log Fuel",
                    icon: "fuelpump.fill",
                    color: Color.petroOrange,
                    action: onLogFuel
                )

                QuickActionButton(
                    title: "Log Service",
                    icon: "wrench.fill",
                    color: Color.petroGreen,
                    action: onLogService
                )
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

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .foregroundStyle(.white)
            .background(color.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 1)
            )
        }
    }
}

// MARK: - Recent Activity Card
struct RecentActivityCard: View {
    let transactions: [FuelTransaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color.petroOrange)
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            if transactions.isEmpty {
                HStack {
                    Spacer()
                    Text("No recent transactions")
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .padding(.vertical)
            } else {
                ForEach(transactions.prefix(5)) { transaction in
                    TransactionRow(transaction: transaction)
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

struct TransactionRow: View {
    let transaction: FuelTransaction

    var body: some View {
        HStack {
            Image(systemName: "fuelpump")
                .foregroundStyle(Color.petroOrange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.fuelType)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Text(String(format: "%.2f gal @ $%.3f", transaction.gallons, transaction.pricePerGallon))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", transaction.total))
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.petroGreen)
                Text(transaction.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Work Orders List View
struct WorkOrdersListView: View {
    let orders: [WorkOrder]

    var body: some View {
        ZStack {
            Color.petroBackground
                .ignoresSafeArea()

            List(orders) { order in
                WorkOrderRow(order: order)
                    .listRowBackground(Color.petroCard)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Work Orders")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Log Fuel View
struct LogFuelView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var fuelType = "Regular"
    @State private var gallons = ""
    @State private var pricePerGallon = ""
    @State private var pumpNumber = "1"

    let fuelTypes = ["Regular", "Midgrade", "Premium", "Diesel"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                Form {
                    Section("Fuel Details") {
                        Picker("Fuel Type", selection: $fuelType) {
                            ForEach(fuelTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .listRowBackground(Color.petroCard)

                        TextField("Gallons", text: $gallons)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .listRowBackground(Color.petroCard)

                        TextField("Price per Gallon", text: $pricePerGallon)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .listRowBackground(Color.petroCard)

                        Picker("Pump Number", selection: $pumpNumber) {
                            ForEach(1...8, id: \.self) { num in
                                Text("Pump \(num)").tag("\(num)")
                            }
                        }
                        .listRowBackground(Color.petroCard)
                    }

                    Section {
                        if let gal = Double(gallons), let price = Double(pricePerGallon) {
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f", gal * price))
                                    .font(.title2.bold())
                                    .foregroundStyle(Color.petroGreen)
                            }
                            .listRowBackground(Color.petroCard)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Log Fuel Sale")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.gray)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFuelTransaction()
                    }
                    .foregroundStyle(Color.petroOrange)
                    .disabled(gallons.isEmpty || pricePerGallon.isEmpty)
                }
            }
        }
    }

    private func saveFuelTransaction() {
        guard let gal = Double(gallons), let price = Double(pricePerGallon) else { return }

        Task {
            do {
                try await appState.apiClient.logFuelTransaction(
                    fuelType: fuelType,
                    gallons: gal,
                    pricePerGallon: price,
                    pumpNumber: Int(pumpNumber) ?? 1
                )
                await appState.refreshDashboard()
                dismiss()
            } catch {
                appState.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

// MARK: - Log Service View
struct LogServiceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var vehicleDescription = ""
    @State private var serviceType = "Oil Change"
    @State private var notes = ""
    @State private var estimatedCost = ""

    let serviceTypes = ["Oil Change", "Tire Rotation", "Brake Service", "Battery", "Diagnostic", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                Form {
                    Section("Vehicle") {
                        TextField("Vehicle (Year Make Model)", text: $vehicleDescription)
                            .listRowBackground(Color.petroCard)
                    }

                    Section("Service") {
                        Picker("Service Type", selection: $serviceType) {
                            ForEach(serviceTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .listRowBackground(Color.petroCard)

                        TextField("Estimated Cost", text: $estimatedCost)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .listRowBackground(Color.petroCard)
                    }

                    Section("Notes") {
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .listRowBackground(Color.petroCard)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Log Service")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.gray)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createWorkOrder()
                    }
                    .foregroundStyle(Color.petroOrange)
                    .disabled(vehicleDescription.isEmpty)
                }
            }
        }
    }

    private func createWorkOrder() {
        Task {
            do {
                try await appState.apiClient.createWorkOrder(
                    vehicle: vehicleDescription,
                    serviceType: serviceType,
                    notes: notes,
                    estimatedCost: Double(estimatedCost) ?? 0
                )
                await appState.refreshDashboard()
                dismiss()
            } catch {
                appState.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

#Preview {
    DashboardTab()
        .environmentObject(AppState())
}
