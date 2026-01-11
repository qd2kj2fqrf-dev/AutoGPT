// AutoTab.swift
// Auto service operations - work orders, customers, services

import SwiftUI

struct AutoTab: View {
    @EnvironmentObject var appState: AppState
    @State private var workOrders: [WorkOrder] = []
    @State private var customers: [Customer] = []
    @State private var selectedStatus: WorkOrderStatus? = nil
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var showNewWorkOrder = false
    @State private var showNewCustomer = false

    var filteredOrders: [WorkOrder] {
        var result = workOrders

        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.vehicle.localizedCaseInsensitiveContains(searchText) ||
                $0.customerName.localizedCaseInsensitiveContains(searchText) ||
                $0.serviceDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Status Filter
                    StatusFilterBar(selection: $selectedStatus)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Search
                    SearchBar(text: $searchText)
                        .padding()

                    // Work Orders List
                    if filteredOrders.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "wrench.and.screwdriver",
                            title: "No Work Orders",
                            message: searchText.isEmpty ? "Create a new work order to get started" : "No results found"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredOrders) { order in
                                    NavigationLink {
                                        WorkOrderDetailView(order: order)
                                    } label: {
                                        WorkOrderCard(order: order)
                                    }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await loadData()
                        }
                    }
                }

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.petroOrange)
                }
            }
            .navigationTitle("Auto Service")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.petroBackground, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Button {
                            showNewWorkOrder = true
                        } label: {
                            Label("New Work Order", systemImage: "doc.badge.plus")
                        }

                        Button {
                            showNewCustomer = true
                        } label: {
                            Label("New Customer", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.petroOrange)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showNewWorkOrder) {
                NewWorkOrderView()
            }
            .sheet(isPresented: $showNewCustomer) {
                NewCustomerView()
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
            async let ordersTask = appState.apiClient.fetchAllWorkOrders()
            async let customersTask = appState.apiClient.fetchCustomers()

            let (orders, custs) = try await (ordersTask, customersTask)
            workOrders = orders
            customers = custs
        } catch {
            appState.showErrorAlert(error.localizedDescription)
        }
    }
}

// MARK: - Status Filter Bar
struct StatusFilterBar: View {
    @Binding var selection: WorkOrderStatus?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selection == nil) {
                    selection = nil
                }

                ForEach(WorkOrderStatus.allCases, id: \.self) { status in
                    FilterChip(
                        title: status.rawValue,
                        color: status.color,
                        isSelected: selection == status
                    ) {
                        selection = status
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    var color: Color = Color.petroOrange
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(isSelected ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.petroCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color : Color.petroBorder, lineWidth: 1)
                )
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)

            TextField("Search orders, vehicles, customers...", text: $text)
                .foregroundStyle(.white)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.petroCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.petroBorder, lineWidth: 1)
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Work Order Card
struct WorkOrderCard: View {
    let order: WorkOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(order.priority.color)
                    .frame(width: 10, height: 10)

                Text(order.orderNumber)
                    .font(.caption.bold())
                    .foregroundStyle(Color.petroOrange)

                Spacer()

                StatusBadge(status: order.status)
            }

            Text(order.vehicle)
                .font(.headline)
                .foregroundStyle(.white)

            Text(order.serviceDescription)
                .font(.subheadline)
                .foregroundStyle(.gray)
                .lineLimit(2)

            Divider()
                .background(Color.petroBorder)

            HStack {
                Label(order.customerName, systemImage: "person")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Spacer()

                Text(order.estimatedCompletion, style: .date)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            if order.estimatedCost > 0 {
                HStack {
                    Text("Estimated:")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(String(format: "$%.2f", order.estimatedCost))
                        .font(.caption.bold())
                        .foregroundStyle(Color.petroGreen)
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

struct StatusBadge: View {
    let status: WorkOrderStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color)
            .clipShape(Capsule())
    }
}

// MARK: - Work Order Detail View
struct WorkOrderDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let order: WorkOrder

    @State private var status: WorkOrderStatus
    @State private var notes = ""
    @State private var laborHours = ""
    @State private var partsCost = ""
    @State private var showAddPart = false

    init(order: WorkOrder) {
        self.order = order
        _status = State(initialValue: order.status)
    }

    var body: some View {
        ZStack {
            Color.petroBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(order.orderNumber)
                                .font(.caption.bold())
                                .foregroundStyle(Color.petroOrange)
                            Spacer()
                            StatusBadge(status: status)
                        }

                        Text(order.vehicle)
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Divider()
                            .background(Color.petroBorder)

                        InfoRow(label: "Customer", value: order.customerName)
                        InfoRow(label: "Service", value: order.serviceDescription)
                        InfoRow(label: "Created", value: order.createdAt.formatted())
                        InfoRow(label: "Due", value: order.estimatedCompletion.formatted(date: .abbreviated, time: .omitted))
                    }
                    .padding()
                    .background(Color.petroCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Status Update
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Update Status")
                            .font(.headline)
                            .foregroundStyle(.white)

                        HStack(spacing: 8) {
                            ForEach(WorkOrderStatus.allCases, id: \.self) { s in
                                Button {
                                    status = s
                                    updateStatus()
                                } label: {
                                    Text(s.rawValue)
                                        .font(.caption.bold())
                                        .foregroundStyle(status == s ? .white : .gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(status == s ? s.color : Color.petroCard)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.petroCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Labor & Parts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Labor & Parts")
                            .font(.headline)
                            .foregroundStyle(.white)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Labor Hours")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                TextField("0.0", text: $laborHours)
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                    .padding(8)
                                    .background(Color.petroBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Parts Cost")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                TextField("$0.00", text: $partsCost)
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                    .padding(8)
                                    .background(Color.petroBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }

                        Button {
                            showAddPart = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Part")
                            }
                            .foregroundStyle(Color.petroOrange)
                        }
                    }
                    .padding()
                    .background(Color.petroCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundStyle(.white)

                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color.petroBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding()
                    .background(Color.petroCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Cost Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cost Summary")
                            .font(.headline)
                            .foregroundStyle(.white)

                        HStack {
                            Text("Estimated")
                            Spacer()
                            Text(String(format: "$%.2f", order.estimatedCost))
                                .foregroundStyle(.gray)
                        }

                        HStack {
                            Text("Labor")
                            Spacer()
                            Text(String(format: "$%.2f", (Double(laborHours) ?? 0) * 95)) // $95/hr
                                .foregroundStyle(.gray)
                        }

                        HStack {
                            Text("Parts")
                            Spacer()
                            Text(String(format: "$%.2f", Double(partsCost) ?? 0))
                                .foregroundStyle(.gray)
                        }

                        Divider()
                            .background(Color.petroBorder)

                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            let labor = (Double(laborHours) ?? 0) * 95
                            let parts = Double(partsCost) ?? 0
                            Text(String(format: "$%.2f", labor + parts))
                                .font(.headline)
                                .foregroundStyle(Color.petroGreen)
                        }
                    }
                    .padding()
                    .background(Color.petroCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Complete Button
                    if status != .completed {
                        Button {
                            status = .completed
                            updateStatus()
                        } label: {
                            Text("Mark as Complete")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.petroGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(order.orderNumber)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showAddPart) {
            AddPartView()
        }
    }

    private func updateStatus() {
        Task {
            do {
                try await appState.apiClient.updateWorkOrderStatus(orderId: order.id, status: status)
            } catch {
                appState.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.gray)
            Spacer()
            Text(value)
                .foregroundStyle(.white)
        }
        .font(.subheadline)
    }
}

// MARK: - New Work Order View
struct NewWorkOrderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var customerName = ""
    @State private var vehicle = ""
    @State private var serviceDescription = ""
    @State private var estimatedCost = ""
    @State private var priority: WorkOrderPriority = .normal
    @State private var dueDate = Date().addingTimeInterval(86400 * 3) // 3 days

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                Form {
                    Section("Customer") {
                        TextField("Customer Name", text: $customerName)
                            .listRowBackground(Color.petroCard)
                    }

                    Section("Vehicle") {
                        TextField("Year Make Model", text: $vehicle)
                            .listRowBackground(Color.petroCard)
                    }

                    Section("Service") {
                        TextField("Service Description", text: $serviceDescription, axis: .vertical)
                            .lineLimit(3...6)
                            .listRowBackground(Color.petroCard)

                        TextField("Estimated Cost", text: $estimatedCost)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .listRowBackground(Color.petroCard)

                        Picker("Priority", selection: $priority) {
                            ForEach(WorkOrderPriority.allCases, id: \.self) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        .listRowBackground(Color.petroCard)

                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                            .listRowBackground(Color.petroCard)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Work Order")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createWorkOrder() }
                        .foregroundStyle(Color.petroOrange)
                        .disabled(customerName.isEmpty || vehicle.isEmpty)
                }
            }
        }
    }

    private func createWorkOrder() {
        Task {
            do {
                try await appState.apiClient.createWorkOrder(
                    vehicle: vehicle,
                    serviceType: serviceDescription,
                    notes: "",
                    estimatedCost: Double(estimatedCost) ?? 0
                )
                dismiss()
            } catch {
                appState.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

// MARK: - New Customer View
struct NewCustomerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                Form {
                    Section("Name") {
                        TextField("First Name", text: $firstName)
                            .listRowBackground(Color.petroCard)
                        TextField("Last Name", text: $lastName)
                            .listRowBackground(Color.petroCard)
                    }

                    Section("Contact") {
                        TextField("Phone", text: $phone)
                            #if os(iOS)
                            .keyboardType(.phonePad)
                            #endif
                            .listRowBackground(Color.petroCard)
                        TextField("Email", text: $email)
                            #if os(iOS)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            #endif
                            .listRowBackground(Color.petroCard)
                    }

                    Section("Address") {
                        TextField("Address", text: $address, axis: .vertical)
                            .lineLimit(2...4)
                            .listRowBackground(Color.petroCard)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Customer")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCustomer() }
                        .foregroundStyle(Color.petroOrange)
                        .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }

    private func saveCustomer() {
        Task {
            do {
                try await appState.apiClient.createCustomer(
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone,
                    email: email,
                    address: address
                )
                dismiss()
            } catch {
                appState.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

// MARK: - Add Part View
struct AddPartView: View {
    @Environment(\.dismiss) var dismiss

    @State private var partNumber = ""
    @State private var description = ""
    @State private var cost = ""
    @State private var quantity = "1"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                Form {
                    Section("Part Details") {
                        TextField("Part Number", text: $partNumber)
                            .listRowBackground(Color.petroCard)
                        TextField("Description", text: $description)
                            .listRowBackground(Color.petroCard)
                        TextField("Cost", text: $cost)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .listRowBackground(Color.petroCard)
                        Stepper("Quantity: \(quantity)", value: Binding(
                            get: { Int(quantity) ?? 1 },
                            set: { quantity = "\($0)" }
                        ), in: 1...99)
                        .listRowBackground(Color.petroCard)
                    }

                    Section {
                        if let c = Double(cost), let q = Int(quantity) {
                            HStack {
                                Text("Subtotal")
                                Spacer()
                                Text(String(format: "$%.2f", c * Double(q)))
                                    .foregroundStyle(Color.petroGreen)
                            }

                            HStack {
                                Text("With 60% Markup")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text(String(format: "$%.2f", c * Double(q) * 1.6))
                                    .font(.headline)
                                    .foregroundStyle(Color.petroOrange)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Part")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { dismiss() }
                        .foregroundStyle(Color.petroOrange)
                }
            }
        }
    }
}

#Preview {
    AutoTab()
        .environmentObject(AppState())
}
