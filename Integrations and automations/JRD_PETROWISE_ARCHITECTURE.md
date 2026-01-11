# JRD PETROWISE
## Enterprise Integration & Automation Platform

**Version:** 2.0 (Rebrand + Integration Expansion)  
**Date:** January 11, 2026  
**Status:** Architecture Updated + Ready for Implementation  
**Core Innovation:** Auto-discovery + Dynamic API Integration Layer

---

## 🎯 VISION

**JRD PetroWise** is a **unified enterprise integration platform** that:

1. **Aggregates** all JRD enterprise applications (Fuel, Auto, Price-O-Tron, Jumbotron, Scanotron, etc.)
2. **Discovers** local/network APIs automatically via system scanning
3. **Pulls** API definitions on-demand (user clicks button → APIs auto-injected)
4. **Visualizes** complex integration connections (the hidden architecture)
5. **Customizes** workflows per user environment (network topology, local files, permissions)
6. **Executes** flows with 100% API coverage (no gaps, no unfilled endpoints)
7. **Orchestrates** fuel + auto operations with real-time data sync

**The Problem It Solves:**
You have enterprise apps scattered across your infrastructure with complex interconnections. PetroWise makes those connections visible, manageable, and automatable.

**The Differentiator:**
Auto-discovery + dynamic API pulling. Users don't manually configure integrations—PetroWise scans and injects them.

-- 

## 🏗️ ARCHITECTURE (UPDATED)

```
┌─────────────────────────────────────────────────────────────┐
│                  JRD PETROWISE PLATFORM                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │     API DISCOVERY ENGINE (New Core Feature)        │   │
│  │  • System scanner (local files, network, APIs)     │   │
│  │  • OpenAPI/Swagger parser                          │   │
│  │  • Dynamic endpoint mapper                         │   │
│  │  • Real-time capability detection                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │     UNIFIED DATA LAYER (Aggregates All Apps)       │   │
│  │  • JRD Fuel database                              │   │
│  │  • JRD Auto database                              │   │
│  │  • Price-O-Tron pricing engine                    │   │
│  │  • Jumbotron analytics                            │   │
│  │  • Scanotron data                                 │   │
│  │  • Custom local data sources                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │    ORCHESTRATION LAYER (Flow Engine + Sandbox)     │   │
│  │  • Flow executor                                  │   │
│  │  • Sandbox environments (test, staging, prod)     │   │
│  │  • Custom integration workflows                   │   │
│  │  • Real-time data streaming                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  3-CLIENT PRESENTATION LAYER (Desktop + Mobile)   │    │
│  │  • Windows (enterprise desktop)                   │    │
│  │  • macOS (power user)                            │    │
│  │  • iOS (field operations)                        │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 API DISCOVERY ENGINE (Core Innovation)

### How It Works

**User Flow:**
```
1. User opens JRD PetroWise
2. System scanner runs automatically in background
3. Discovers:
   - Local JRD applications (Fuel, Auto)
   - Network endpoints
   - Available databases
   - File system integrations
   - Cloud APIs
4. User clicks "Refresh APIs" button
5. Engine fetches OpenAPI specs from all discovered services
6. All APIs instantly available for flow building
7. Minimal manual configuration (just ensure services are running)
```

### Technical Implementation

```typescript
// API Discovery Service
class APIDiscoveryEngine {
  // 1. System Scanner
  async scanEnvironment(): Promise<DiscoveredServices> {
    return {
      localServices: await this.findLocalServices(),
      networkServices: await this.findNetworkServices(),
      filesystemIntegrations: await this.findFileSystemAPIs(),
      cloudAPIs: await this.findCloudServices(),
      databases: await this.detectDatabases(),
    }
  }

  // 2. Local Service Detection
  async findLocalServices(): Promise<LocalService[]> {
    // Scan common ports for JRD applications
    const services = []
    
    // JRD Fuel API (default: port 8001)
    if (await this.isServiceRunning('localhost:8001')) {
      services.push({
        name: 'JRD Fuel',
        url: 'http://localhost:8001',
        type: 'fuel'
      })
    }
    
    // JRD Auto API (default: port 8002)
    if (await this.isServiceRunning('localhost:8002')) {
      services.push({
        name: 'JRD Auto',
        url: 'http://localhost:8002',
        type: 'auto'
      })
    }
    
    // Price-O-Tron (default: port 8003)
    if (await this.isServiceRunning('localhost:8003')) {
      services.push({
        name: 'Price-O-Tron',
        url: 'http://localhost:8003',
        type: 'pricing'
      })
    }
    
    // Jumbotron (default: port 8004)
    if (await this.isServiceRunning('localhost:8004')) {
      services.push({
        name: 'Jumbotron',
        url: 'http://localhost:8004',
        type: 'analytics'
      })
    }
    
    // Scanotron (default: port 8005)
    if (await this.isServiceRunning('localhost:8005')) {
      services.push({
        name: 'Scanotron',
        url: 'http://localhost:8005',
        type: 'scanning'
      })
    }
    
    return services
  }

  // 3. Fetch OpenAPI Specs
  async discoverAPIs(service: LocalService): Promise<OpenAPISpec> {
    try {
      // Try common OpenAPI endpoints
      const endpoints = [
        `/swagger.json`,
        `/api/openapi.json`,
        `/api/v1/openapi.json`,
        `/openapi.json`,
        `/.well-known/openapi.json`
      ]
      
      for (const endpoint of endpoints) {
        const response = await fetch(`${service.url}${endpoint}`)
        if (response.ok) {
          return await response.json()
        }
      }
      
      // Fallback: auto-generate from service introspection
      return await this.introspectService(service)
    } catch (error) {
      console.error(`Failed to discover APIs for ${service.name}`, error)
      throw new Error(`API Discovery failed for ${service.name}`)
    }
  }

  // 4. Dynamic Endpoint Mapping
  async mapEndpoints(spec: OpenAPISpec): Promise<IntegrationEndpoint[]> {
    return Object.entries(spec.paths).map(([path, pathItem]) => {
      return Object.entries(pathItem).map(([method, operation]) => ({
        path,
        method: method.toUpperCase(),
        operationId: operation.operationId,
        description: operation.description,
        parameters: operation.parameters || [],
        requestBody: operation.requestBody,
        responses: operation.responses,
      }))
    }).flat()
  }
}
```

### Supported Discovery Types

**1. Local Services** (via port scanning)
```
JRD Fuel API       → localhost:8001
JRD Auto API       → localhost:8002
Price-O-Tron       → localhost:8003
Jumbotron          → localhost:8004
Scanotron          → localhost:8005
```

**2. File System Integrations**
```
CSV files          → Auto-detect + map columns
Excel files        → Sheet discovery
JSON files         → Structure mapping
Database files     → Connection pooling
Log files          → Parsing + streaming
```

**3. Network Services**
```
Network scan       → NMAP integration
Service discovery  → DNS resolution
Port mapping       → Open port detection
```

**4. Cloud APIs**
```
AWS services       → SQS, SNS, S3, etc.
Azure services     → App Service, Cosmos DB, etc.
Google Cloud       → Firestore, Cloud Storage, etc.
```

---

## 📊 UNIFIED DATA LAYER

### Data Model (Aggregated)

```typescript
// Fuel + Auto Operations (Core)
interface FuelOperation {
  id: string
  date: Date
  fuelType: 'Regular' | 'Premium' | 'Diesel'
  quantity: number
  price: number
  location: string
  vehicle?: string
  supplier: string
  metadata: Record<string, any>
}

interface AutoOperation {
  id: string
  vehicleId: string
  operationType: 'Service' | 'Repair' | 'Maintenance'
  cost: number
  date: Date
  location: string
  description: string
  metadata: Record<string, any>
}

// Aggregated Insights (from Price-O-Tron + Jumbotron + Scanotron)
interface EnterpriseMetrics {
  fuelCosts: {
    daily: number
    weekly: number
    monthly: number
    byType: Record<string, number>
    byLocation: Record<string, number>
    trend: number // percentage change
  }
  autoCosts: {
    daily: number
    weekly: number
    monthly: number
    byType: Record<string, number>
    byVehicle: Record<string, number>
  }
  pricing: {
    currentMarketPrice: number
    historicalAverage: number
    predictions: Array<{date: Date; price: number}>
  }
  utilization: {
    vehiclesActive: number
    averageDistance: number
    efficiency: number
  }
}

// Environment Configuration
interface UserEnvironment {
  networkTopology: {
    localServices: LocalService[]
    remoteServices: RemoteService[]
    internalNetworks: string[]
  }
  fileSystem: {
    dataDirectories: string[]
    integratedSources: FileSystemSource[]
  }
  permissions: {
    dataAccess: string[]
    apiAccess: string[]
    executionLevel: 'read' | 'read-write' | 'admin'
  }
  customizations: {
    themes: UserTheme[]
    workflows: CustomWorkflow[]
    alerts: AlertRule[]
  }
}
```

---

## 🎬 ORCHESTRATION LAYER

### Flow Execution (Enhanced)

```typescript
// Flow Node Types (Expanded)
type FlowNodeKind = 
  | 'fuel-operation'      // Fuel transaction
  | 'auto-service'        // Vehicle service
  | 'price-check'         // Price-O-Tron
  | 'analytics-query'     // Jumbotron
  | 'data-scan'           // Scanotron
  | 'integration-call'    // Generic API
  | 'filter'              // Data filtering
  | 'transform'           // Data transformation
  | 'condition'           // Decision logic
  | 'notification'        // Alert/notification
  | 'sandbox'             // Test execution

// Sandbox Environments
class SandboxEnvironment {
  // Test flows without affecting production
  async executeInSandbox(flow: Flow): Promise<ExecutionResult> {
    // 1. Create isolated database snapshot
    const snapshot = await this.createSnapshot()
    
    // 2. Execute flow against snapshot
    const result = await this.executeFlow(flow, snapshot)
    
    // 3. Show what WOULD have changed
    const diff = await this.compareSnapshot(snapshot)
    
    // 4. User can promote to production or discard
    return {
      result,
      simulatedChanges: diff,
      canPromote: true
    }
  }
}
```

### Buildable Workflows

Users can create complex flows:
```
Trigger: Daily at 9 AM
├─ Get fuel prices from Price-O-Tron
├─ Query this week's fuel operations from JRD Fuel
├─ Filter: expensive locations
├─ Call Jumbotron analytics
├─ Send alert if costs above threshold
└─ Log to Scanotron for audit trail
```

---

## 🌐 DATA AGGREGATION (The Key Differentiator)

### Real-Time Dashboard

```
┌─────────────────────────────────────────────────────────┐
│                   JRD PETROWISE DASHBOARD              │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ FUEL OPERATIONS                                         │
│ ├─ Today: 247 transactions, $3,842.50                 │
│ ├─ vs. Yesterday: +12%, -$234                        │
│ ├─ Top Supplier: Shell (45%)                          │
│ ├─ Price Trend: ↑ 2.3% (Price-O-Tron)              │
│ └─ Forecast: $4,120 tomorrow (AI prediction)          │
│                                                          │
│ AUTO OPERATIONS                                         │
│ ├─ Active Vehicles: 34/40                            │
│ ├─ Pending Services: 8                               │
│ ├─ Monthly Cost: $18,920                             │
│ └─ Fleet Efficiency: 8.2 MPG (↑0.3)                 │
│                                                          │
│ INTEGRATION STATUS                                      │
│ ├─ JRD Fuel: ✓ Connected (342 endpoints)            │
│ ├─ JRD Auto: ✓ Connected (278 endpoints)            │
│ ├─ Price-O-Tron: ✓ Connected (52 endpoints)        │
│ ├─ Jumbotron: ✓ Connected (89 endpoints)           │
│ └─ Scanotron: ✓ Connected (156 endpoints)          │
│                                                          │
│ NETWORK TOPOLOGY (Auto-Discovered)                     │
│ ├─ Local: 5 services detected                        │
│ ├─ Network: 12 endpoints mapped                      │
│ ├─ File Systems: 3 data sources connected           │
│ └─ Last Scan: 2 minutes ago                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 ENTERPRISE INTEGRATION POINTS

### JRD Fuel Integration
```
┌─────────────────────────────────────────┐
│         JRD FUEL APPLICATION            │
├─────────────────────────────────────────┤
│ • Transaction processing (pump → DB)   │
│ • Inventory management                 │
│ • Supplier management                  │
│ • Price tracking                       │
│ • Payment processing                   │
│ • Compliance reporting                 │
│                                         │
│ API Endpoints Available:                │
│ • POST /transactions (create)          │
│ • GET /transactions (list/filter)      │
│ • GET /inventory                       │
│ • GET /suppliers                       │
│ • GET /pricing/current                 │
│ • GET /reports/compliance              │
│ • POST /reconciliation                 │
│ (342 total endpoints)                  │
└─────────────────────────────────────────┘
```

### JRD Auto Integration
```
┌─────────────────────────────────────────┐
│         JRD AUTO APPLICATION            │
├─────────────────────────────────────────┤
│ • Fleet management                     │
│ • Vehicle maintenance tracking         │
│ • Service scheduling                   │
│ • Parts inventory                      │
│ • Technician assignment                │
│ • Cost tracking                        │
│                                         │
│ API Endpoints Available:                │
│ • GET /vehicles (fleet)                │
│ • POST /services (schedule)            │
│ • GET /maintenance/due                 │
│ • GET /parts/inventory                 │
│ • POST /work-orders                    │
│ • GET /costs/analysis                  │
│ • POST /technician/assignments         │
│ (278 total endpoints)                  │
└─────────────────────────────────────────┘
```

### Enterprise Applications Integration
```
Price-O-Tron (Pricing Engine)
├─ Real-time fuel pricing
├─ Market analysis
├─ Forecasting
└─ Supplier rate comparison

Jumbotron (Analytics)
├─ Data aggregation
├─ Report generation
├─ Trend analysis
└─ Predictive insights

Scanotron (Data Scanner)
├─ Data quality checks
├─ Anomaly detection
├─ Audit trails
└─ Compliance verification
```

---

## 💾 CUSTOMIZATION PER ENVIRONMENT

### User Environment Detection

```typescript
class EnvironmentDetector {
  async detectUserEnvironment(): Promise<UserEnvironment> {
    return {
      // Network topology
      network: await this.scanNetwork(),
      
      // File system integrations
      fileSystem: {
        dataDirectory: await this.locateDataDirectory(),
        integrations: await this.findDataSources(),
      },
      
      // Database connections
      databases: await this.detectDatabases(),
      
      // Permissions
      permissions: await this.detectUserPermissions(),
      
      // Local services
      services: await this.discoverLocalServices(),
      
      // User preferences
      preferences: await this.loadUserPreferences(),
    }
  }

  async locateDataDirectory(): Promise<string> {
    // Common locations for JRD data
    const candidates = [
      '/Users/jdurand/JRDData',
      '/var/jrd/data',
      'C:\\JRDData',
      process.env.JRD_DATA_DIR,
    ]
    
    for (const dir of candidates) {
      if (await this.directoryExists(dir)) {
        return dir
      }
    }
    
    throw new Error('JRD data directory not found')
  }

  async findDataSources(): Promise<DataSource[]> {
    const sources = []
    
    // Scan for CSV files
    const csvFiles = await this.findFiles('*.csv')
    sources.push(...csvFiles.map(f => ({
      type: 'csv',
      path: f,
      autoDetectColumns: true
    })))
    
    // Scan for Excel files
    const excelFiles = await this.findFiles('*.xlsx')
    sources.push(...excelFiles.map(f => ({
      type: 'excel',
      path: f,
      autoDetectSheets: true
    })))
    
    // Scan for JSON files
    const jsonFiles = await this.findFiles('*.json')
    sources.push(...jsonFiles.map(f => ({
      type: 'json',
      path: f,
      autoDetectSchema: true
    })))
    
    return sources
  }

  async detectDatabases(): Promise<DatabaseConnection[]> {
    const connections = []
    
    // Check for local PostgreSQL
    if (await this.isServiceRunning('localhost:5432')) {
      connections.push({
        type: 'postgresql',
        host: 'localhost',
        port: 5432,
        database: 'jrd',
      })
    }
    
    // Check for SQLite files
    const sqliteFiles = await this.findFiles('*.db')
    connections.push(...sqliteFiles.map(f => ({
      type: 'sqlite',
      path: f,
    })))
    
    return connections
  }
}
```

---

## 🚀 IMPLEMENTATION ROADMAP (UPDATED)

### Phase 1: API Discovery Engine (Weeks 1-4)

**Week 1-2: Discovery Infrastructure**
- [ ] System scanner (ports, files, databases)
- [ ] OpenAPI spec parser
- [ ] Local service detection (Fuel, Auto, etc.)
- [ ] Environment mapping

**Week 3-4: Dynamic API Integration**
- [ ] API endpoint mapper
- [ ] Automatic integration registration
- [ ] Real-time capability detection
- [ ] Fallback introspection (if no OpenAPI)

### Phase 2: Unified Data Layer (Weeks 5-8)

- [ ] Fuel data aggregation
- [ ] Auto data aggregation
- [ ] Enterprise app data mappers
- [ ] Real-time data streaming
- [ ] Historical data warehouse

### Phase 3: Orchestration (Weeks 9-12)

- [ ] Enhanced flow nodes (fuel-operation, auto-service, etc.)
- [ ] Sandbox environments
- [ ] Buildable workflows
- [ ] Execution logging

### Phase 4: Client Development (Weeks 13-16)

- [ ] Windows app (enterprise desktop)
- [ ] macOS app (power user)
- [ ] iOS app (field operations)

### Phase 5: Testing + Launch (Weeks 17-18)

- [ ] Cross-platform testing
- [ ] Performance optimization
- [ ] Security audit
- [ ] Beta launch

---

## 🎯 NO UNFILLED API AREAS

**Guarantee:** Every endpoint discovered by the system is:
- ✅ Available in flow builder
- ✅ Fully documented
- ✅ Testable
- ✅ Executable
- ✅ Logged

```typescript
// Validation: Ensure API completeness
class APICompleteValidator {
  async validate(integration: Integration): Promise<ValidationResult> {
    const endpoints = await this.discoverEndpoints(integration)
    const issues = []

    for (const endpoint of endpoints) {
      // Check 1: Is it documented?
      if (!endpoint.description) {
        issues.push(`${endpoint.path} missing description`)
      }

      // Check 2: Are parameters defined?
      if (endpoint.parameters.some(p => !p.description)) {
        issues.push(`${endpoint.path} has undocumented parameters`)
      }

      // Check 3: Are responses mapped?
      if (!endpoint.responses || Object.keys(endpoint.responses).length === 0) {
        issues.push(`${endpoint.path} has no response mappings`)
      }

      // Check 4: Can it be tested?
      try {
        await this.testEndpoint(endpoint)
      } catch (e) {
        issues.push(`${endpoint.path} failed test: ${e.message}`)
      }
    }

    return {
      complete: issues.length === 0,
      totalEndpoints: endpoints.length,
      issues,
    }
  }
}
```

---

## 📱 THREE-CLIENT PRESENTATION

### Windows (Enterprise Desktop)
- Full-screen dashboard
- Complex flow builder
- Multi-monitor support
- Advanced analytics
- System integration

### macOS (Power User)
- Native SwiftUI
- Menu bar quick access
- Keyboard shortcuts
- Workflow automation
- Dark mode + light mode

### iOS (Field Operations)
- Quick fuel/service logging
- Real-time alerts
- Offline mode
- Mobile-optimized
- Biometric auth

---

## 🎯 SUCCESS CRITERIA

✅ **API Discovery:** Discovers 100% of available endpoints on first scan  
✅ **Minimal Config:** User only ensures services are running on expected ports  
✅ **One-Click:** "Refresh APIs" button pulls all available endpoints  
✅ **Complete Coverage:** Every discovered endpoint is usable  
✅ **Auto-Customization:** UI adapts to user's network/file topology  
✅ **Zero Gaps:** No unfilled API areas or incomplete integrations

---

## 📝 NEXT STEPS

1. **Review** this updated architecture
2. **Identify** exact ports/configurations for Fuel, Auto, Price-O-Tron, Jumbotron, Scanotron
3. **Start** with API Discovery Engine (most critical feature)
4. **Test** against your existing applications
5. **Build** unified dashboard
6. **Deploy** 3 clients

---

**JRD PetroWise Status:** Architecture Complete ✅  
**Core Innovation:** Auto-discovery + Dynamic API Integration  
**Ready to Build:** Yes ✅  
**Timeline:** 18 weeks to MVP (with auto-discovery focus)

