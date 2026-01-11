import Foundation

actor APIClient {
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: String = "http://localhost:3001") {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Fuel Operations

    func fetchFuelSummary() async throws -> FuelOperationsSummary {
        let url = try buildURL(path: "/api/fuel/summary")
        return try await fetch(url: url)
    }

    // MARK: - Auto Operations

    func fetchAutoSummary() async throws -> AutoOperationsSummary {
        let url = try buildURL(path: "/api/auto/summary")
        return try await fetch(url: url)
    }

    // MARK: - Services Discovery

    func fetchServices() async throws -> [DiscoveredService] {
        let url = try buildURL(path: "/api/services")
        return try await fetch(url: url)
    }

    // MARK: - Health Check

    func healthCheck() async throws -> Bool {
        let url = try buildURL(path: "/api/health")
        let (_, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        return httpResponse.statusCode == 200
    }

    // MARK: - Refresh All

    func refreshAll() async throws -> DashboardData {
        var data = DashboardData()
        data.isLoading = true

        async let fuelTask = fetchFuelSummaryOrDefault()
        async let autoTask = fetchAutoSummaryOrDefault()
        async let servicesTask = fetchServicesOrDefault()

        let (fuel, auto, services) = await (fuelTask, autoTask, servicesTask)

        data.fuelSummary = fuel
        data.autoSummary = auto
        data.services = services
        data.lastRefresh = Date()
        data.isLoading = false

        return data
    }

    // MARK: - Private Helpers

    private func buildURL(path: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        return url
    }

    private func fetch<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func fetchFuelSummaryOrDefault() async -> FuelOperationsSummary {
        do {
            return try await fetchFuelSummary()
        } catch {
            return FuelOperationsSummary()
        }
    }

    private func fetchAutoSummaryOrDefault() async -> AutoOperationsSummary {
        do {
            return try await fetchAutoSummary()
        } catch {
            return AutoOperationsSummary()
        }
    }

    private func fetchServicesOrDefault() async -> [DiscoveredService] {
        do {
            return try await fetchServices()
        } catch {
            return []
        }
    }
}

// MARK: - Mock Data for Development

extension APIClient {
    static func mockFuelSummary() -> FuelOperationsSummary {
        FuelOperationsSummary(
            totalGallonsSold: 12450.5,
            totalRevenue: 42892.75,
            fuelGrades: [
                FuelGrade(name: "Regular 87", gallonsSold: 7200, revenue: 24480, pricePerGallon: 3.40),
                FuelGrade(name: "Plus 89", gallonsSold: 2800, revenue: 10080, pricePerGallon: 3.60),
                FuelGrade(name: "Premium 91", gallonsSold: 2450.5, revenue: 8332.75, pricePerGallon: 3.40)
            ],
            lastUpdated: Date()
        )
    }

    static func mockAutoSummary() -> AutoOperationsSummary {
        AutoOperationsSummary(
            totalWorkOrders: 47,
            completedToday: 8,
            pendingOrders: 12,
            totalRevenue: 15680.50,
            topServices: [
                ServiceSummary(name: "Oil Change", count: 15, revenue: 1125),
                ServiceSummary(name: "Brake Service", count: 8, revenue: 3200),
                ServiceSummary(name: "Tire Rotation", count: 12, revenue: 480)
            ],
            lastUpdated: Date()
        )
    }

    static func mockServices() -> [DiscoveredService] {
        [
            DiscoveredService(name: "PetroNet", status: .online, endpoint: "https://petronetprodtem.circlek.com", lastChecked: Date(), responseTime: 245),
            DiscoveredService(name: "QBO Direct", status: .online, endpoint: "https://quickbooks.api.intuit.com", lastChecked: Date(), responseTime: 180),
            DiscoveredService(name: "SimpleFIN", status: .online, endpoint: "https://beta-bridge.simplefin.org", lastChecked: Date(), responseTime: 320),
            DiscoveredService(name: "CardPointe", status: .online, endpoint: "https://api.cardpointe.com", lastChecked: Date(), responseTime: 150),
            DiscoveredService(name: "Mitchell1", status: .degraded, endpoint: "http://192.168.0.16", lastChecked: Date(), responseTime: 890),
            DiscoveredService(name: "MS Graph", status: .online, endpoint: "https://graph.microsoft.com", lastChecked: Date(), responseTime: 95)
        ]
    }
}
