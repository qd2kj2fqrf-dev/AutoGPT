// MainTabView.swift
// Tab-based navigation for PetroWise iOS

import SwiftUI
#if os(iOS)
import UIKit
#endif

public struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    public init() {}

    public var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardTab()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)

            FuelTab()
                .tabItem {
                    Label(Tab.fuel.rawValue, systemImage: Tab.fuel.icon)
                }
                .tag(Tab.fuel)

            AutoTab()
                .tabItem {
                    Label(Tab.auto.rawValue, systemImage: Tab.auto.icon)
                }
                .tag(Tab.auto)

            SettingsTab()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.petroOrange)
        .onAppear {
            #if os(iOS)
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.petroBackground)

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            #endif
        }
        .alert("Error", isPresented: $appState.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(appState.errorMessage ?? "Unknown error")
        }
    }
}

// MARK: - Settings Tab
struct SettingsTab: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService
    @AppStorage("apiBaseURL") private var apiBaseURL = "https://api.jrdcompanies.com"
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableOfflineMode") private var enableOfflineMode = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.petroBackground
                    .ignoresSafeArea()

                List {
                    // Account Section
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.petroOrange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("JRD Operations")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("Holiday #3851")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .listRowBackground(Color.petroCard)
                    }

                    // Server Settings
                    Section("Server") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("API Base URL")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            TextField("https://api.example.com", text: $apiBaseURL)
                                .textFieldStyle(.plain)
                                #if os(iOS)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                #endif
                                .foregroundStyle(.white)
                        }
                        .listRowBackground(Color.petroCard)

                        Button {
                            Task {
                                await testConnection()
                            }
                        } label: {
                            HStack {
                                Text("Test Connection")
                                Spacer()
                                Image(systemName: "antenna.radiowaves.left.and.right")
                            }
                        }
                        .foregroundStyle(Color.petroOrange)
                        .listRowBackground(Color.petroCard)
                    }

                    // Preferences
                    Section("Preferences") {
                        Toggle("Push Notifications", isOn: $enableNotifications)
                            .tint(Color.petroOrange)
                            .listRowBackground(Color.petroCard)

                        Toggle("Offline Mode", isOn: $enableOfflineMode)
                            .tint(Color.petroOrange)
                            .listRowBackground(Color.petroCard)

                        NavigationLink {
                            CacheManagementView()
                        } label: {
                            HStack {
                                Text("Cache Management")
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.petroCard)
                    }

                    // Security
                    Section("Security") {
                        HStack {
                            Text("Authentication")
                            Spacer()
                            Text(authService.biometricType == .faceID ? "Face ID" : "Touch ID")
                                .foregroundStyle(.gray)
                        }
                        .listRowBackground(Color.petroCard)

                        Button("Sign Out") {
                            authService.signOut()
                        }
                        .foregroundStyle(.red)
                        .listRowBackground(Color.petroCard)
                    }

                    // About
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.gray)
                        }
                        .listRowBackground(Color.petroCard)

                        HStack {
                            Text("Build")
                            Spacer()
                            Text("2026.01.11")
                                .foregroundStyle(.gray)
                        }
                        .listRowBackground(Color.petroCard)

                        Link(destination: URL(string: "https://jrdcompanies.com")!) {
                            HStack {
                                Text("JRD Companies")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                            }
                        }
                        .foregroundStyle(Color.petroOrange)
                        .listRowBackground(Color.petroCard)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.petroBackground, for: .navigationBar)
            #endif
        }
    }

    private func testConnection() async {
        do {
            let _ = try await appState.apiClient.healthCheck()
            appState.showErrorAlert("Connection successful!")
        } catch {
            appState.showErrorAlert("Connection failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Cache Management View
struct CacheManagementView: View {
    @EnvironmentObject var appState: AppState
    @State private var cacheSize: String = "Calculating..."

    var body: some View {
        ZStack {
            Color.petroBackground
                .ignoresSafeArea()

            List {
                Section {
                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text(cacheSize)
                            .foregroundStyle(.gray)
                    }
                    .listRowBackground(Color.petroCard)

                    Button("Clear Cache") {
                        appState.cacheService.clearAll()
                        cacheSize = "0 KB"
                    }
                    .foregroundStyle(.red)
                    .listRowBackground(Color.petroCard)
                }

                Section("Cached Data") {
                    CacheRow(title: "Fuel Summary", hasData: appState.fuelSummary != nil)
                    CacheRow(title: "Work Orders", count: appState.pendingWorkOrders.count)
                    CacheRow(title: "Transactions", count: appState.recentTransactions.count)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Cache")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            calculateCacheSize()
        }
    }

    private func calculateCacheSize() {
        let size = appState.cacheService.calculateSize()
        if size < 1024 {
            cacheSize = "\(size) B"
        } else if size < 1024 * 1024 {
            cacheSize = String(format: "%.1f KB", Double(size) / 1024)
        } else {
            cacheSize = String(format: "%.1f MB", Double(size) / (1024 * 1024))
        }
    }
}

struct CacheRow: View {
    let title: String
    var hasData: Bool = false
    var count: Int = 0

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if hasData || count > 0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.petroGreen)
                if count > 0 {
                    Text("\(count)")
                        .foregroundStyle(.gray)
                }
            } else {
                Text("No data")
                    .foregroundStyle(.gray)
            }
        }
        .listRowBackground(Color.petroCard)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AuthService())
}
