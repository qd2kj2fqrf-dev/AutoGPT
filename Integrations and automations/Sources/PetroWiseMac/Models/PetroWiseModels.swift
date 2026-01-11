import Foundation

// MARK: - API Response Models

struct FuelOperationsSummary: Codable, Sendable {
    let totalGallonsSold: Double
    let totalRevenue: Double
    let fuelGrades: [FuelGrade]
    let lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case totalGallonsSold = "total_gallons_sold"
        case totalRevenue = "total_revenue"
        case fuelGrades = "fuel_grades"
        case lastUpdated = "last_updated"
    }

    init(totalGallonsSold: Double = 0, totalRevenue: Double = 0, fuelGrades: [FuelGrade] = [], lastUpdated: Date? = nil) {
        self.totalGallonsSold = totalGallonsSold
        self.totalRevenue = totalRevenue
        self.fuelGrades = fuelGrades
        self.lastUpdated = lastUpdated
    }
}

struct FuelGrade: Codable, Sendable, Identifiable {
    var id: String { name }
    let name: String
    let gallonsSold: Double
    let revenue: Double
    let pricePerGallon: Double

    enum CodingKeys: String, CodingKey {
        case name
        case gallonsSold = "gallons_sold"
        case revenue
        case pricePerGallon = "price_per_gallon"
    }
}

struct AutoOperationsSummary: Codable, Sendable {
    let totalWorkOrders: Int
    let completedToday: Int
    let pendingOrders: Int
    let totalRevenue: Double
    let topServices: [ServiceSummary]
    let lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case totalWorkOrders = "total_work_orders"
        case completedToday = "completed_today"
        case pendingOrders = "pending_orders"
        case totalRevenue = "total_revenue"
        case topServices = "top_services"
        case lastUpdated = "last_updated"
    }

    init(totalWorkOrders: Int = 0, completedToday: Int = 0, pendingOrders: Int = 0, totalRevenue: Double = 0, topServices: [ServiceSummary] = [], lastUpdated: Date? = nil) {
        self.totalWorkOrders = totalWorkOrders
        self.completedToday = completedToday
        self.pendingOrders = pendingOrders
        self.totalRevenue = totalRevenue
        self.topServices = topServices
        self.lastUpdated = lastUpdated
    }
}

struct ServiceSummary: Codable, Sendable, Identifiable {
    var id: String { name }
    let name: String
    let count: Int
    let revenue: Double
}

struct DiscoveredService: Codable, Sendable, Identifiable {
    var id: String { name }
    let name: String
    let status: ServiceStatus
    let endpoint: String
    let lastChecked: Date?
    let responseTime: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case status
        case endpoint
        case lastChecked = "last_checked"
        case responseTime = "response_time"
    }
}

enum ServiceStatus: String, Codable, Sendable {
    case online
    case offline
    case degraded
    case unknown

    var displayName: String {
        switch self {
        case .online: return "Online"
        case .offline: return "Offline"
        case .degraded: return "Degraded"
        case .unknown: return "Unknown"
        }
    }
}

struct DashboardData: Sendable {
    var fuelSummary: FuelOperationsSummary
    var autoSummary: AutoOperationsSummary
    var services: [DiscoveredService]
    var lastRefresh: Date?
    var isLoading: Bool
    var error: String?

    init() {
        self.fuelSummary = FuelOperationsSummary()
        self.autoSummary = AutoOperationsSummary()
        self.services = []
        self.lastRefresh = nil
        self.isLoading = false
        self.error = nil
    }
}

// MARK: - API Error

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unknown:
            return "Unknown error"
        }
    }
}
