// PetroWiseIOSApp.swift
// Main entry point for PetroWise iOS application
// JRD PetroWise - Fuel & Auto Service Management

import SwiftUI

// MARK: - App Entry Point
@main
public struct PetroWiseIOSApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authService = AuthService()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(authService)
                    .preferredColorScheme(.dark)
            } else {
                AuthenticationView()
                    .environmentObject(authService)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

// MARK: - App State
@MainActor
public class AppState: ObservableObject {
    @Published var selectedTab: Tab = .dashboard
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    // Cached data
    @Published var fuelSummary: FuelSummary?
    @Published var pendingWorkOrders: [WorkOrder] = []
    @Published var recentTransactions: [FuelTransaction] = []

    let apiClient: APIClient
    let cacheService: CacheService

    public init() {
        self.apiClient = APIClient()
        self.cacheService = CacheService()

        // Load cached data on init
        Task {
            await loadCachedData()
        }
    }

    func loadCachedData() async {
        if let cached = cacheService.loadFuelSummary() {
            fuelSummary = cached
        }
        if let cached = cacheService.loadWorkOrders() {
            pendingWorkOrders = cached
        }
    }

    func refreshDashboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let summaryTask = apiClient.fetchFuelSummary()
            async let ordersTask = apiClient.fetchPendingWorkOrders()

            let (summary, orders) = try await (summaryTask, ordersTask)

            fuelSummary = summary
            pendingWorkOrders = orders

            // Cache for offline
            cacheService.saveFuelSummary(summary)
            cacheService.saveWorkOrders(orders)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Tab Enum
public enum Tab: String, CaseIterable {
    case dashboard = "Dashboard"
    case fuel = "Fuel"
    case auto = "Auto"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.bottom.50percent"
        case .fuel: return "fuelpump.fill"
        case .auto: return "car.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isAuthenticating = false
    @State private var showManualLogin = false

    var body: some View {
        ZStack {
            Color.petroBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                VStack(spacing: 16) {
                    Image(systemName: "fuelpump.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.petroOrange)

                    Text("PetroWise")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)

                    Text("JRD Operations")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }

                Spacer()

                // Auth button
                VStack(spacing: 20) {
                    if authService.biometricType != .none {
                        Button {
                            Task {
                                isAuthenticating = true
                                await authService.authenticate()
                                isAuthenticating = false
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if isAuthenticating {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: authService.biometricType == .faceID ? "faceid" : "touchid")
                                        .font(.title2)
                                }
                                Text(authService.biometricType == .faceID ? "Sign in with Face ID" : "Sign in with Touch ID")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.petroOrange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isAuthenticating)
                    }

                    Button("Use Passcode Instead") {
                        showManualLogin = true
                    }
                    .foregroundStyle(.gray)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showManualLogin) {
            PasscodeView()
                .environmentObject(authService)
        }
        .onAppear {
            // Auto-prompt for biometrics
            if authService.biometricType != .none {
                Task {
                    await authService.authenticate()
                }
            }
        }
    }
}

// MARK: - Passcode View
struct PasscodeView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var passcode = ""
    @State private var showError = false

    private let correctPasscode = "3851" // Holiday store number

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Text("Enter Passcode")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    // Passcode dots
                    HStack(spacing: 20) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < passcode.count ? Color.petroOrange : Color.gray.opacity(0.3))
                                .frame(width: 16, height: 16)
                        }
                    }

                    if showError {
                        Text("Incorrect passcode")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }

                    // Number pad
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(1...9, id: \.self) { num in
                            PasscodeButton(number: "\(num)") {
                                appendDigit("\(num)")
                            }
                        }

                        Spacer()

                        PasscodeButton(number: "0") {
                            appendDigit("0")
                        }

                        Button {
                            if !passcode.isEmpty {
                                passcode.removeLast()
                            }
                        } label: {
                            Image(systemName: "delete.left")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 70, height: 70)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
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
            }
        }
    }

    private func appendDigit(_ digit: String) {
        guard passcode.count < 4 else { return }
        passcode += digit

        if passcode.count == 4 {
            if passcode == correctPasscode {
                authService.manualAuthenticate()
                dismiss()
            } else {
                showError = true
                passcode = ""

                // Haptic feedback
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                #endif
            }
        }
    }
}

struct PasscodeButton: View {
    let number: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

// MARK: - Color Extensions
public extension Color {
    static let petroBackground = Color(red: 10/255, green: 10/255, blue: 10/255)     // #0a0a0a
    static let petroOrange = Color(red: 249/255, green: 115/255, blue: 22/255)       // #f97316
    static let petroGreen = Color(red: 34/255, green: 197/255, blue: 94/255)         // #22c55e
    static let petroCard = Color(red: 24/255, green: 24/255, blue: 27/255)           // #18181b
    static let petroBorder = Color(red: 39/255, green: 39/255, blue: 42/255)         // #27272a
}

// MARK: - Preview
#Preview {
    AuthenticationView()
        .environmentObject(AuthService())
}
