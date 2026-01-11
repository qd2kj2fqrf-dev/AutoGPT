// APIClient.swift
// Backend API client for PetroWise iOS

import Foundation

// MARK: - API Client
@MainActor
public class APIClient: ObservableObject {
    @Published var baseURL: String

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init() {
        self.baseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://api.jrdcompanies.com"

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Health Check
    func healthCheck() async throws -> Bool {
        let url = URL(string: "\(baseURL)/health")!
        let (_, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        return httpResponse.statusCode == 200
    }

    // MARK: - Fuel Operations
    func fetchFuelSummary() async throws -> FuelSummary {
        // Try API first, fall back to mock data for demo
        do {
            return try await get("/api/fuel/summary")
        } catch {
            // Return mock data for development
            return FuelSummary.mockData()
        }
    }

    func fetchFuelTransactions(range: TimeRange) async throws -> [FuelTransaction] {
        do {
            return try await get("/api/fuel/transactions?days=\(range.days)")
        } catch {
            return FuelTransaction.mockData()
        }
    }

    func fetchFuelInventory() async throws -> FuelInventory {
        do {
            return try await get("/api/fuel/inventory")
        } catch {
            return FuelInventory.mockData()
        }
    }

    func logFuelTransaction(fuelType: String, gallons: Double, pricePerGallon: Double, pumpNumber: Int) async throws {
        let body: [String: Any] = [
            "fuelType": fuelType,
            "gallons": gallons,
            "pricePerGallon": pricePerGallon,
            "pumpNumber": pumpNumber,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        try await post("/api/fuel/transactions", body: body)
    }

    func logFuelDelivery(fuelType: String, gallons: Double, invoiceNumber: String, date: Date) async throws {
        let body: [String: Any] = [
            "fuelType": fuelType,
            "gallons": gallons,
            "invoiceNumber": invoiceNumber,
            "deliveryDate": ISO8601DateFormatter().string(from: date)
        ]
        try await post("/api/fuel/deliveries", body: body)
    }

    func updateFuelPrices(regular: Double, midgrade: Double, premium: Double, diesel: Double) async throws {
        let body: [String: Any] = [
            "regular": regular,
            "midgrade": midgrade,
            "premium": premium,
            "diesel": diesel,
            "effectiveDate": ISO8601DateFormatter().string(from: Date())
        ]
        try await post("/api/fuel/prices", body: body)
    }

    // MARK: - Work Orders
    func fetchPendingWorkOrders() async throws -> [WorkOrder] {
        do {
            return try await get("/api/auto/workorders?status=pending,inProgress")
        } catch {
            return WorkOrder.mockData()
        }
    }

    func fetchAllWorkOrders() async throws -> [WorkOrder] {
        do {
            return try await get("/api/auto/workorders")
        } catch {
            return WorkOrder.mockData()
        }
    }

    func createWorkOrder(vehicle: String, serviceType: String, notes: String, estimatedCost: Double) async throws {
        let body: [String: Any] = [
            "vehicle": vehicle,
            "serviceType": serviceType,
            "notes": notes,
            "estimatedCost": estimatedCost,
            "priority": "normal"
        ]
        try await post("/api/auto/workorders", body: body)
    }

    func updateWorkOrderStatus(orderId: String, status: WorkOrderStatus) async throws {
        let body: [String: Any] = [
            "status": status.rawValue
        ]
        try await patch("/api/auto/workorders/\(orderId)", body: body)
    }

    // MARK: - Customers
    func fetchCustomers() async throws -> [Customer] {
        do {
            return try await get("/api/auto/customers")
        } catch {
            return Customer.mockData()
        }
    }

    func createCustomer(firstName: String, lastName: String, phone: String, email: String, address: String) async throws {
        let body: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phone": phone,
            "email": email,
            "address": address
        ]
        try await post("/api/auto/customers", body: body)
    }

    // MARK: - HTTP Methods
    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = URL(string: "\(baseURL)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }

    private func post(_ path: String, body: [String: Any]) async throws {
        let url = URL(string: "\(baseURL)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    private func patch(_ path: String, body: [String: Any]) async throws {
        let url = URL(string: "\(baseURL)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Cache Service
public class CacheService {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    public init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("PetroWise")

        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Fuel Summary
    func saveFuelSummary(_ summary: FuelSummary) {
        save(summary, to: "fuel_summary.json")
    }

    func loadFuelSummary() -> FuelSummary? {
        load(from: "fuel_summary.json")
    }

    // MARK: - Work Orders
    func saveWorkOrders(_ orders: [WorkOrder]) {
        save(orders, to: "work_orders.json")
    }

    func loadWorkOrders() -> [WorkOrder]? {
        load(from: "work_orders.json")
    }

    // MARK: - Transactions
    func saveTransactions(_ transactions: [FuelTransaction]) {
        save(transactions, to: "transactions.json")
    }

    func loadTransactions() -> [FuelTransaction]? {
        load(from: "transactions.json")
    }

    // MARK: - Generic Save/Load
    private func save<T: Encodable>(_ object: T, to filename: String) {
        let url = cacheDirectory.appendingPathComponent(filename)
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: url)
        } catch {
            print("Cache save error: \(error)")
        }
    }

    private func load<T: Decodable>(from filename: String) -> T? {
        let url = cacheDirectory.appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - Clear Cache
    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func calculateSize() -> Int {
        var size = 0
        if let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += fileSize ?? 0
                }
            }
        }
        return size
    }
}
