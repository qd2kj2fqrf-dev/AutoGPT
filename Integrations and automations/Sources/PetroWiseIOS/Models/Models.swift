// Models.swift
// Data models for PetroWise iOS

import Foundation
import SwiftUI

// MARK: - Fuel Summary
public struct FuelSummary: Codable, Sendable {
    public let date: Date
    public let totalGallons: Double
    public let totalRevenue: Double
    public let transactionCount: Int

    public let regularGallons: Double
    public let regularPrice: Double
    public let midgradeGallons: Double
    public let midgradePrice: Double
    public let premiumGallons: Double
    public let premiumPrice: Double
    public let dieselGallons: Double
    public let dieselPrice: Double

    public static func mockData() -> FuelSummary {
        FuelSummary(
            date: Date(),
            totalGallons: 2847.5,
            totalRevenue: 9234.67,
            transactionCount: 156,
            regularGallons: 1523.2,
            regularPrice: 2.999,
            midgradeGallons: 342.8,
            midgradePrice: 3.299,
            premiumGallons: 521.5,
            premiumPrice: 3.599,
            dieselGallons: 460.0,
            dieselPrice: 3.499
        )
    }
}

// MARK: - Fuel Transaction
public struct FuelTransaction: Codable, Identifiable, Sendable {
    public let id: String
    public let timestamp: Date
    public let fuelType: String
    public let gallons: Double
    public let pricePerGallon: Double
    public let total: Double
    public let pumpNumber: Int
    public let paymentMethod: String

    public static func mockData() -> [FuelTransaction] {
        let types = ["Regular", "Midgrade", "Premium", "Diesel"]
        let payments = ["Credit", "Debit", "Cash"]

        return (0..<20).map { i in
            let gallons = Double.random(in: 5...25)
            let price = Double.random(in: 2.99...3.99)
            return FuelTransaction(
                id: UUID().uuidString,
                timestamp: Date().addingTimeInterval(Double(-i * 1800)),
                fuelType: types.randomElement()!,
                gallons: gallons,
                pricePerGallon: price,
                total: gallons * price,
                pumpNumber: Int.random(in: 1...8),
                paymentMethod: payments.randomElement()!
            )
        }
    }
}

// MARK: - Fuel Inventory
public struct FuelInventory: Codable, Sendable {
    public let lastUpdated: Date

    public let regularLevel: Double
    public let regularCapacity: Double
    public let midgradeLevel: Double
    public let midgradeCapacity: Double
    public let premiumLevel: Double
    public let premiumCapacity: Double
    public let dieselLevel: Double
    public let dieselCapacity: Double

    public static func mockData() -> FuelInventory {
        FuelInventory(
            lastUpdated: Date(),
            regularLevel: 6500,
            regularCapacity: 10000,
            midgradeLevel: 2800,
            midgradeCapacity: 5000,
            premiumLevel: 3200,
            premiumCapacity: 5000,
            dieselLevel: 4100,
            dieselCapacity: 8000
        )
    }
}

// MARK: - Work Order
public struct WorkOrder: Codable, Identifiable, Sendable {
    public let id: String
    public let orderNumber: String
    public let customerName: String
    public let vehicle: String
    public let serviceDescription: String
    public let status: WorkOrderStatus
    public let priority: WorkOrderPriority
    public let estimatedCost: Double
    public let createdAt: Date
    public let estimatedCompletion: Date

    public static func mockData() -> [WorkOrder] {
        [
            WorkOrder(
                id: "1",
                orderNumber: "WO-2026-001",
                customerName: "John Smith",
                vehicle: "2019 Ford F-150",
                serviceDescription: "Oil change and tire rotation",
                status: .inProgress,
                priority: .normal,
                estimatedCost: 125.00,
                createdAt: Date().addingTimeInterval(-86400),
                estimatedCompletion: Date().addingTimeInterval(3600)
            ),
            WorkOrder(
                id: "2",
                orderNumber: "WO-2026-002",
                customerName: "Sarah Johnson",
                vehicle: "2021 Toyota Camry",
                serviceDescription: "Brake pad replacement front and rear",
                status: .pending,
                priority: .high,
                estimatedCost: 450.00,
                createdAt: Date().addingTimeInterval(-43200),
                estimatedCompletion: Date().addingTimeInterval(86400)
            ),
            WorkOrder(
                id: "3",
                orderNumber: "WO-2026-003",
                customerName: "Mike Williams",
                vehicle: "2018 Honda Accord",
                serviceDescription: "Check engine light diagnostic - P0420 code",
                status: .pending,
                priority: .normal,
                estimatedCost: 150.00,
                createdAt: Date().addingTimeInterval(-21600),
                estimatedCompletion: Date().addingTimeInterval(172800)
            ),
            WorkOrder(
                id: "4",
                orderNumber: "WO-2026-004",
                customerName: "Lisa Davis",
                vehicle: "2020 Chevy Equinox",
                serviceDescription: "Battery replacement and electrical system check",
                status: .completed,
                priority: .urgent,
                estimatedCost: 225.00,
                createdAt: Date().addingTimeInterval(-172800),
                estimatedCompletion: Date().addingTimeInterval(-86400)
            )
        ]
    }
}

// MARK: - Work Order Status
public enum WorkOrderStatus: String, Codable, CaseIterable, Sendable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"

    public var color: Color {
        switch self {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return Color.petroGreen
        case .cancelled: return .gray
        }
    }
}

// MARK: - Work Order Priority
public enum WorkOrderPriority: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    case urgent = "Urgent"

    public var color: Color {
        switch self {
        case .low: return .gray
        case .normal: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

// MARK: - Customer
public struct Customer: Codable, Identifiable, Sendable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let phone: String
    public let email: String
    public let address: String
    public let vehicleCount: Int
    public let totalSpent: Double
    public let lastVisit: Date?

    public var fullName: String {
        "\(firstName) \(lastName)"
    }

    public static func mockData() -> [Customer] {
        [
            Customer(
                id: "1",
                firstName: "John",
                lastName: "Smith",
                phone: "651-555-1234",
                email: "john.smith@email.com",
                address: "123 Main St, Maplewood MN 55119",
                vehicleCount: 2,
                totalSpent: 1250.00,
                lastVisit: Date().addingTimeInterval(-86400)
            ),
            Customer(
                id: "2",
                firstName: "Sarah",
                lastName: "Johnson",
                phone: "651-555-5678",
                email: "sarah.j@email.com",
                address: "456 Oak Ave, St Paul MN 55106",
                vehicleCount: 1,
                totalSpent: 450.00,
                lastVisit: Date().addingTimeInterval(-43200)
            ),
            Customer(
                id: "3",
                firstName: "Mike",
                lastName: "Williams",
                phone: "612-555-9012",
                email: "mwilliams@email.com",
                address: "789 Elm St, Minneapolis MN 55401",
                vehicleCount: 3,
                totalSpent: 2100.00,
                lastVisit: Date().addingTimeInterval(-21600)
            )
        ]
    }
}

// MARK: - Vehicle
public struct Vehicle: Codable, Identifiable, Sendable {
    public let id: String
    public let customerId: String
    public let year: Int
    public let make: String
    public let model: String
    public let vin: String
    public let licensePlate: String
    public let mileage: Int

    public var displayName: String {
        "\(year) \(make) \(model)"
    }
}

// MARK: - Part
public struct Part: Codable, Identifiable, Sendable {
    public let id: String
    public let partNumber: String
    public let description: String
    public let cost: Double
    public let markup: Double
    public let quantity: Int

    public var retailPrice: Double {
        cost * (1 + markup)
    }

    public var subtotal: Double {
        retailPrice * Double(quantity)
    }
}

// MARK: - Service Type
public struct ServiceType: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let estimatedHours: Double
    public let laborRate: Double

    public var estimatedLaborCost: Double {
        estimatedHours * laborRate
    }
}
