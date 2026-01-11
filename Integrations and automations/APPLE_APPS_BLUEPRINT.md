# MACOS + iOS APPLICATIONS (SwiftUI Native)
## Integrations & Automations Studio - Apple Platforms

---

## 🏗️ SHARED ARCHITECTURE (macOS + iOS)

```
IntegrationsStudio-Apple/
│
├── Shared/                                    # Code shared across platforms
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Flow.swift
│   │   ├── Node.swift
│   │   ├── Integration.swift
│   │   └── ExecutionLog.swift
│   │
│   ├── Services/
│   │   ├── APIService.swift                  # HTTP + URLSession
│   │   ├── AuthService.swift                 # Token management
│   │   ├── StorageService.swift              # Keychain
│   │   ├── WebSocketService.swift            # Real-time
│   │   ├── NotificationService.swift
│   │   └── KeychainService.swift
│   │
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   ├── FlowsViewModel.swift
│   │   ├── IntegrationViewModel.swift
│   │   ├── ExecutionViewModel.swift
│   │   └── SettingsViewModel.swift
│   │
│   └── Network/
│       ├── APIClient.swift
│       ├── APIModels.swift
│       └── URLSessionConfiguration.swift
│
├── macOS/                                     # macOS-specific code
│   ├── Views/
│   │   ├── MacMainView.swift
│   │   ├── FlowsListView.swift
│   │   ├── FlowDetailView.swift
│   │   ├── IntegrationsView.swift
│   │   ├── SettingsView.swift
│   │   ├── Components/
│   │   │   ├── FlowNodeComponent.swift
│   │   │   ├── MenuBar.swift
│   │   │   └── Sidebar.swift
│   │   └── Modals/
│   │       ├── NewFlowSheet.swift
│   │       └── PreferencesWindow.swift
│   │
│   ├── Managers/
│   │   ├── MenuManager.swift                 # App menu
│   │   ├── HotKeyManager.swift               # Keyboard shortcuts
│   │   └── WindowManager.swift               # Window coordination
│   │
│   └── IntegrationsStudioMac.swift            # macOS entry point
│
├── iOS/                                       # iOS-specific code
│   ├── Views/
│   │   ├── iOSMainView.swift
│   │   ├── FlowsTabView.swift
│   │   ├── IntegrationsTabView.swift
│   │   ├── ExecutionTabView.swift
│   │   ├── SettingsTabView.swift
│   │   ├── Components/
│   │   │   ├── FlowCard.swift
│   │   │   ├── NodeSheet.swift
│   │   │   └── MetricsView.swift
│   │   └── Sheets/
│   │       ├── NewFlowSheet.swift
│   │       ├── IntegrationDetailSheet.swift
│   │       └── ExecutionDetailSheet.swift
│   │
│   ├── Managers/
│   │   ├── PushNotificationManager.swift
│   │   ├── ShortcutManager.swift
│   │   ├── WidgetManager.swift                # Home screen widgets
│   │   └── SheetManager.swift                # Bottom sheet coordination
│   │
│   └── IntegrationsStudioiOS.swift            # iOS entry point
│
└── Package.swift                              # Swift Package definition
```

---

## 📦 PACKAGE.SWIFT

```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "IntegrationsStudio",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    dependencies: [
        .package(
            url: "https://github.com/SwiftyJSON/SwiftyJSON.git",
            from: "5.0.0"
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.8.0"
        ),
        .package(
            url: "https://github.com/socketio/socket.io-client-swift.git",
            from: "16.1.0"
        ),
    ],
    targets: [
        .target(
            name: "IntegrationsStudio",
            dependencies: ["SwiftyJSON", "Alamofire", "SocketIO"],
            path: "Sources/Shared"
        ),
        .target(
            name: "IntegrationsStudioMac",
            dependencies: ["IntegrationsStudio"],
            path: "Sources/macOS"
        ),
        .target(
            name: "IntegrationsStudioiOS",
            dependencies: ["IntegrationsStudio"],
            path: "Sources/iOS"
        ),
    ]
)
```

---

## 🔐 SHARED MODELS

```swift
// Sources/Shared/Models/Models.swift
import Foundation

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let avatarUrl: String?
    let theme: Theme
    let preferences: [String: AnyCodable]
    let createdAt: Date
    let updatedAt: Date
    
    enum Theme: String, Codable, CaseIterable {
        case copperTide = "copper-tide"
        case mintVoltage = "mint-voltage"
        case solarDrift = "solar-drift"
    }
}

// MARK: - Flow
struct Flow: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let intention: String
    let status: FlowStatus
    let nodes: [Node]
    let connections: [Connection]
    let metrics: FlowMetrics
    var triggers: [FlowTrigger]?
    let schedule: String?
    let createdAt: Date
    let updatedAt: Date
    var lastExecuted: Date?
    
    enum FlowStatus: String, Codable {
        case active, paused, archived
    }
}

// MARK: - Node
struct Node: Codable, Identifiable {
    let id: String
    let flowId: String
    let title: String
    let kind: NodeKind
    let detail: String
    let integrationId: String?
    let config: [String: AnyCodable]
    let order: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum NodeKind: String, Codable, CaseIterable {
        case trigger, action, filter, transform, decision, delay
    }
}

// MARK: - Connection
struct Connection: Codable, Identifiable {
    var id: UUID { UUID(uuidString: fromNodeId + toNodeId) ?? UUID() }
    let flowId: String
    let fromNodeId: String
    let toNodeId: String
    let label: String?
    let condition: String?
}

// MARK: - Integration
struct Integration: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let category: IntegrationCategory
    let type: String
    let capabilities: [String]
    let isConnected: Bool
    let lastChecked: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum IntegrationCategory: String, Codable, CaseIterable {
        case messaging, data, ops, finance, devtools, ai, docs
    }
}

// MARK: - ExecutionLog
struct ExecutionLog: Codable, Identifiable {
    let id: String
    let flowId: String
    let userId: String
    let status: ExecutionStatus
    let startTime: Date
    let endTime: Date?
    let duration: Int?
    let result: [String: AnyCodable]?
    let error: ExecutionError?
    let nodeExecutions: [NodeExecution]
    let createdAt: Date
    
    enum ExecutionStatus: String, Codable {
        case success, failure, pending, cancelled
    }
}

// MARK: - FlowMetrics
struct FlowMetrics: Codable {
    let successRate: String
    let avgRuntime: String
    let volumePerDay: String
    let notes: String
    let executionCount: Int
    let failureCount: Int
}

// MARK: - Helper
struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        }
    }
}
```

---

## 🌐 SHARED SERVICES

### API Client

```swift
// Sources/Shared/Services/APIService.swift
import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000"
    private let session: Session
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        self.session = Session(configuration: configuration)
    }
    
    // MARK: - Authentication
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        return try await post("/api/v1/auth/login", body: request)
    }
    
    func register(email: String, name: String, password: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, name: name, password: password)
        return try await post("/api/v1/auth/register", body: request)
    }
    
    func refreshToken(_ refreshToken: String) async throws -> TokenResponse {
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        return try await post("/api/v1/auth/refresh-token", body: request)
    }
    
    // MARK: - Flows
    
    func getFlows() async throws -> [Flow] {
        return try await get("/api/v1/flows")
    }
    
    func getFlow(id: String) async throws -> Flow {
        return try await get("/api/v1/flows/\(id)")
    }
    
    func createFlow(_ flow: CreateFlowRequest) async throws -> Flow {
        return try await post("/api/v1/flows", body: flow)
    }
    
    func updateFlow(id: String, _ flow: UpdateFlowRequest) async throws -> Flow {
        return try await put("/api/v1/flows/\(id)", body: flow)
    }
    
    func deleteFlow(id: String) async throws {
        _ = try await delete("/api/v1/flows/\(id)")
    }
    
    func executeFlow(id: String) async throws -> ExecutionResponse {
        return try await post("/api/v1/flows/\(id)/execute", body: [:])
    }
    
    // MARK: - Integrations
    
    func getIntegrations() async throws -> [Integration] {
        return try await get("/api/v1/integrations")
    }
    
    func testIntegration(id: String) async throws -> TestIntegrationResponse {
        return try await post("/api/v1/integrations/\(id)/test", body: [:])
    }
    
    // MARK: - Logs
    
    func getExecutionLogs(skip: Int = 0, take: Int = 50) async throws -> [ExecutionLog] {
        return try await get("/api/v1/logs?skip=\(skip)&take=\(take)")
    }
    
    // MARK: - Private Helpers
    
    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL + path
        return try await session.request(url).serializingDecodable(T.self).value
    }
    
    private func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let url = baseURL + path
        return try await session.request(
            url,
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder.default
        ).serializingDecodable(T.self).value
    }
    
    private func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let url = baseURL + path
        return try await session.request(
            url,
            method: .put,
            parameters: body,
            encoder: JSONParameterEncoder.default
        ).serializingDecodable(T.self).value
    }
    
    private func delete<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL + path
        return try await session.request(url, method: .delete).serializingDecodable(T.self).value
    }
}

// MARK: - Requests

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let name: String
    let password: String
}

struct CreateFlowRequest: Encodable {
    let name: String
    let intention: String
}

struct UpdateFlowRequest: Encodable {
    let name: String
    let intention: String
    let nodes: [Node]
    let connections: [Connection]
}

// MARK: - Responses

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct TokenResponse: Decodable {
    let accessToken: String
}

struct ExecutionResponse: Decodable {
    let logId: String
    let status: String
}

struct TestIntegrationResponse: Decodable {
    let isConnected: Bool
    let message: String
}
```

### Keychain Service

```swift
// Sources/Shared/Services/KeychainService.swift
import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let serviceName = "com.integrationsstudio.app"
    
    func set(_ value: String, forKey key: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }
    }
    
    func get(forKey key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deletionFailed
        }
    }
    
    enum KeychainError: LocalizedError {
        case itemNotFound
        case deletionFailed
    }
}
```

---

## 🍎 MACOS APP IMPLEMENTATION

### Main View

```swift
// Sources/macOS/Views/MacMainView.swift
import SwiftUI

struct MacMainView: View {
    @StateObject var appViewModel: AppViewModel
    @State private var selectedTab: Tab = .flows
    
    enum Tab {
        case dashboard, flows, integrations, workbenches, settings
    }
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selectedTab: $selectedTab)
                .frame(minWidth: 280)
        } detail: {
            detailView
                .navigationTitle(selectedTab.title)
        }
        .onAppear {
            setupMenuBar()
            setupKeyboardShortcuts()
        }
    }
    
    @ViewBuilder
    var detailView: some View {
        switch selectedTab {
        case .dashboard:
            DashboardView()
        case .flows:
            FlowsListView()
        case .integrations:
            IntegrationsView()
        case .workbenches:
            WorkbenchesView()
        case .settings:
            SettingsView()
        }
    }
    
    private func setupMenuBar() {
        let menu = NSMenu()
        
        // File menu
        let newFlowItem = NSMenuItem(title: "New Flow", action: #selector(createNewFlow), keyEquivalent: "n")
        menu.addItem(newFlowItem)
        
        // Edit menu items...
        
        NSApp.mainMenu = menu
    }
    
    @objc private func createNewFlow() {
        // Show new flow sheet
    }
    
    private func setupKeyboardShortcuts() {
        // ⌘K: Search
        // ⌘N: New flow
        // ⌘,: Settings
    }
}

// Sidebar
struct Sidebar: View {
    @Binding var selectedTab: MacMainView.Tab
    
    var body: some View {
        List(selection: $selectedTab) {
            NavigationLink(value: MacMainView.Tab.dashboard) {
                Label("Dashboard", systemImage: "square.grid.2x2")
            }
            NavigationLink(value: MacMainView.Tab.flows) {
                Label("Flows", systemImage: "flowchart")
            }
            NavigationLink(value: MacMainView.Tab.integrations) {
                Label("Integrations", systemImage: "plug.connected")
            }
            NavigationLink(value: MacMainView.Tab.workbenches) {
                Label("Workbenches", systemImage: "square.3.layers.3d")
            }
            
            Divider()
            
            NavigationLink(value: MacMainView.Tab.settings) {
                Label("Settings", systemImage: "gear")
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200, maxWidth: 280)
    }
}
```

---

## 📱 iOS APP IMPLEMENTATION

### Main View

```swift
// Sources/iOS/Views/iOSMainView.swift
import SwiftUI

struct iOSMainView: View {
    @StateObject var appViewModel: AppViewModel
    
    var body: some View {
        TabView {
            // Flows Tab
            NavigationStack {
                FlowsListView()
                    .navigationTitle("Flows")
            }
            .tabItem {
                Label("Flows", systemImage: "flowchart")
            }
            
            // Integrations Tab
            NavigationStack {
                IntegrationsListView()
                    .navigationTitle("Integrations")
            }
            .tabItem {
                Label("Integrations", systemImage: "plug.connected")
            }
            
            // Execution Tab
            NavigationStack {
                ExecutionLogView()
                    .navigationTitle("Executions")
            }
            .tabItem {
                Label("Executions", systemImage: "clock")
            }
            
            // Settings Tab
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .tint(.blue)
        .onAppear {
            setupPushNotifications()
            setupDeepLinking()
        }
    }
    
    private func setupPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _ in }
    }
    
    private func setupDeepLinking() {
        // Handle deep links from notifications, URLs, etc.
    }
}

// Flows List
struct FlowsListView: View {
    @StateObject var viewModel = FlowsViewModel()
    @State private var showNewFlowSheet = false
    
    var body: some View {
        List {
            ForEach(viewModel.flows) { flow in
                NavigationLink(destination: FlowDetailView(flow: flow)) {
                    FlowRow(flow: flow)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.loadFlows()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showNewFlowSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showNewFlowSheet) {
            NewFlowSheet(isPresented: $showNewFlowSheet)
        }
        .onAppear {
            Task { await viewModel.loadFlows() }
        }
    }
}

struct FlowRow: View {
    let flow: Flow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(flow.name)
                    .font(.headline)
                Spacer()
                StatusBadge(status: flow.status)
            }
            
            Text(flow.intention)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 16) {
                Label(flow.metrics.successRate, systemImage: "checkmark.circle")
                    .font(.caption)
                Label(flow.metrics.avgRuntime, systemImage: "clock")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadge: View {
    let status: Flow.FlowStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    var backgroundColor: Color {
        switch status {
        case .active: return .green
        case .paused: return .orange
        case .archived: return .gray
        }
    }
}
```

---

## 🎨 SHARED VIEW MODELS

```swift
// Sources/Shared/ViewModels/FlowsViewModel.swift
import Foundation

@MainActor
class FlowsViewModel: ObservableObject {
    @Published var flows: [Flow] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiService = APIService.shared
    
    func loadFlows() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            flows = try await apiService.getFlows()
        } catch {
            self.error = error
        }
    }
    
    func createFlow(name: String, intention: String) async {
        do {
            let request = CreateFlowRequest(name: name, intention: intention)
            let newFlow = try await apiService.createFlow(request)
            flows.insert(newFlow, at: 0)
        } catch {
            self.error = error
        }
    }
    
    func deleteFlow(_ flow: Flow) async {
        do {
            try await apiService.deleteFlow(id: flow.id)
            flows.removeAll { $0.id == flow.id }
        } catch {
            self.error = error
        }
    }
}
```

---

## ✅ IMPLEMENTATION CHECKLIST

- [ ] Set up Swift Package structure
- [ ] Implement shared models (User, Flow, Node, etc.)
- [ ] Create APIService with Alamofire
- [ ] Implement KeychainService for secure storage
- [ ] Create AuthService (login, token refresh)
- [ ] Build shared ViewModels
- [ ] Build macOS UI (main window, sidebar, views)
- [ ] Implement macOS menu bar integration
- [ ] Add macOS keyboard shortcuts (⌘K, ⌘N, ⌘,)
- [ ] Build iOS UI (tab bar navigation)
- [ ] Implement iOS bottom sheets
- [ ] Add iOS push notifications
- [ ] Implement iOS home screen widgets
- [ ] Add WebSocket real-time updates (both platforms)
- [ ] Implement biometric auth (Face ID / Touch ID)
- [ ] Set up deep linking (iOS notifications)
- [ ] Test on iOS simulator and device
- [ ] Test on macOS simulator and machine
- [ ] Build release apps

---

**Apple Apps Status:** Architecture complete ✅  
**Ready for:** Implementation (UI development + API integration)

