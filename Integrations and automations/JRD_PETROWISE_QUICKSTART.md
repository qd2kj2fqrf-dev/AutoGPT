# JRD PETROWISE: QUICK START REFERENCE
## One-Page Guide to Getting Started

---

This Will be a comprehensive build out
<!-- Remove placeholder and add high-impact prompts for agent-driven design, logic, and implementation. -->

---

### 🚦 Before You Start: Think Like an Architect, Builder, and Tester

#### **Design Prompts**
- What are the *core abstractions* and *responsibilities* for each service? Sketch a diagram or write a paragraph for each.
- How will you ensure *loose coupling* and *high cohesion* between modules?
- What are the *failure modes* for each service? How will you detect and recover from them?
- How will you *document* and *version* your APIs for future teams?
- What *security boundaries* exist between services? Where do you need authentication, authorization, or rate limiting?
- How will you *scale* each service independently? What are your partitioning/sharding strategies?

#### **Logic & Reasoning Prompts**
- What are the *critical paths* in API discovery and registration? Where could bottlenecks or race conditions occur?
- How will you *validate* that all endpoints are correctly discovered and registered?
- What *edge cases* could break discovery (e.g., missing specs, network flakiness, partial failures)?
- How will you *test* for correctness, performance, and resilience? What does a “passing” test look like?
- What *metrics* and *logs* will you emit to prove the system is working as intended?

#### **Implementation Prompts**
- What *interfaces* and *types* will you define up front to enforce contracts between modules?
- How will you *mock* or *simulate* services for local development and CI?
- What is your *error handling* and *retry* strategy for failed service calls?
- How will you *automate* setup, teardown, and data seeding for repeatable local runs?
- What *tooling* (linters, formatters, CI/CD) will you enable from day one?
- How will you *review* and *merge* code to maintain quality and velocity?

---

**Agents:** Use these prompts as a checklist before, during, and after each sprint. Document your answers, challenge assumptions, and share findings with the team. If you can’t answer a prompt, raise it in standup or retro—don’t let gaps go unnoticed!

### Monday-Wednesday (3-4 hours total)

**Step 1: Read the Architecture**
```
JRD_PETROWISE_ARCHITECTURE.md (45 min)
└─ Understand: 4 layers, 5 services, 1,000+ endpoints, API Discovery
```

**Step 2: Read the Implementation**
```
API_DISCOVERY_IMPLEMENTATION.md (30 min)
└─ Understand: How API Discovery works, copy/paste code ready
```

**Step 3: Review the Roadmap**
```
JRD_PETROWISE_ROADMAP.md (40 min)
└─ Understand: 18 weeks, 5 phases, Go/No-Go gates
```

**Step 4: Identify Your Setup**
```
Check your system:
  □ JRD Fuel API: What port? (assuming 8001)
  □ JRD Auto API: What port? (assuming 8002)
  □ Price-O-Tron: What port? (assuming 8003)
  □ Jumbotron: What port? (assuming 8004)
  □ Scanotron: What port? (assuming 8005)
  □ OpenAPI specs available?
  □ Data directories?
```

---

## 🚀 MONDAY MORNING: SPRINT 1 BEGINS

### What You'll Build (Week 1)

**Goal:** API Discovery Engine detecting services and registering 1,000+ endpoints

### Step 1: Initialize Node.js Project
```bash
cd backend
npm init -y
npm install express cors dotenv helmet axios socket.io
npm install --save-dev typescript @types/node @types/express
```

### Step 2: Project Structure
```
backend/
├─ src/
│  ├─ main.ts                 ← Express server
│  ├─ services/
│  │  └─ APIDiscoveryService.ts  ← COPY FROM GUIDE
│  ├─ routes/
│  │  └─ discovery.ts         ← COPY FROM GUIDE
│  └─ config/
│     └─ environment.ts       ← Your ports/config
├─ package.json
├─ tsconfig.json
└─ .env
```

### Step 3: Copy Code
```bash
# From API_DISCOVERY_IMPLEMENTATION.md:
# 1. Copy APIDiscoveryService class → src/services/APIDiscoveryService.ts
# 2. Copy discovery routes → src/routes/discovery.ts
# 3. Copy main.ts setup → src/main.ts
```

### Step 4: Configure Ports
```typescript
// src/config/environment.ts
const JRD_SERVICES = [
  { name: 'JRD Fuel', port: 8001, type: 'fuel' },
  { name: 'JRD Auto', port: 8002, type: 'auto' },
  { name: 'Price-O-Tron', port: 8003, type: 'pricing' },
  { name: 'Jumbotron', port: 8004, type: 'analytics' },
  { name: 'Scanotron', port: 8005, type: 'scanning' },
]
```

### Step 5: Start Services & Backend
```bash
# Terminal 1: Make sure JRD services running
# JRD Fuel on port 8001
# JRD Auto on port 8002
# Price-O-Tron on port 8003
# Jumbotron on port 8004
# Scanotron on port 8005

# Terminal 2: Start backend
npm run dev
# Backend should start on http://localhost:3000
```

### Step 6: Test Discovery
```bash
# Terminal 3: Trigger API discovery
curl http://localhost:3000/api/discovery/scan

# Expected response:
{
  "success": true,
  "data": {
    "services": [
      { "name": "JRD Fuel", "endpoints": 342 },
      { "name": "JRD Auto", "endpoints": 278 },
      { "name": "Price-O-Tron", "endpoints": 52 },
      { "name": "Jumbotron", "endpoints": 89 },
      { "name": "Scanotron", "endpoints": 156 }
    ],
    "totalEndpoints": 917
  }
}
```

### Step 7: Check Endpoints
```bash
# Get all discovered endpoints
curl http://localhost:3000/api/discovery/endpoints

# Get endpoints for specific service
curl http://localhost:3000/api/discovery/endpoints?service=JRD%20Fuel

# Search endpoints
curl http://localhost:3000/api/discovery/endpoints?query=transaction
```

---

## ✅ WEEK 1 SUCCESS CRITERIA

- ✓ Backend running on localhost:3000
- ✓ 5 services detected
- ✓ 900+ endpoints registered
- ✓ /api/discovery/scan returning results
- ✓ /api/discovery/endpoints returning list
- ✓ First git commit with working code

---

## 🛠 COMMON COMMANDS

### Development
```bash
npm run dev              # Start with hot reload
npm run build          # Compile TypeScript
npm test               # Run tests
npm run lint           # Check code style
```

### Testing
```bash
curl http://localhost:3000/api/discovery/scan
curl http://localhost:3000/api/discovery/endpoints
curl http://localhost:3000/api/discovery/services
curl http://localhost:3000/api/discovery/status
```

### Git
```bash
git status             # Check status
git add .              # Stage all changes
git commit -m "..."    # Commit
git push               # Push to remote
git log --oneline      # View commits
```

---

## 📊 QUICK METRICS

| Metric | Status | Next |
|--------|--------|------|
| API Discovery Engine | 🚀 Ready to code | Week 1 |
| Services Detected | 0 → 5 | Week 2 |
| Endpoints Registered | 0 → 917 | Week 4 |
| Data Aggregation | 📋 Planned | Week 5 |
| Orchestration | 📋 Planned | Week 9 |
| Three Clients | 📋 Planned | Week 13 |
| Security + Launch | 📋 Planned | Week 17 |

---

## ❓ COMMON QUESTIONS

**Q: What if JRD services aren't running?**
A: Discovery will skip them. Check logs, verify ports, restart services.

**Q: What if no OpenAPI spec available?**
A: Fallback introspection will probe common endpoints. See APIDiscoveryService.ts.

**Q: How often should we refresh APIs?**
A: Automatic on startup, manual via "Refresh APIs" button, or scheduled daily.

**Q: What if endpoint specs change?**
A: Discovery re-scans on refresh, updates database, clients get latest specs.

**Q: When do we get real-time data?**
A: Week 5+ when Data Aggregation layer built. Week 1 is just endpoint discovery.

---

## 🎯 THIS SPRINT'S GOAL

**By Friday of Week 2:**
- API Discovery Engine working
- 1,000+ endpoints registered
- User can click "Refresh APIs" and see all available endpoints
- Zero manual configuration needed

**Go/No-Go Gate Pass Criteria:**
```
✓ 5 services discovered
✓ 900+ endpoints registered
✓ /api/discovery/scan functional
✓ Tests passing
✓ First code committed
```

---

## 📞 NEED HELP?

**API Discovery Questions?**
→ See API_DISCOVERY_IMPLEMENTATION.md (full code examples)

**Architecture Questions?**
→ See JRD_PETROWISE_ARCHITECTURE.md (detailed design)

**Timeline Questions?**
→ See JRD_PETROWISE_ROADMAP.md (week-by-week breakdown)

---

## 📁 ALL DOCUMENTS

```
JRD_PETROWISE_ARCHITECTURE.md         ← Start here (45 min)
├─ Vision, architecture, design
└─ Everything about how it works

API_DISCOVERY_IMPLEMENTATION.md       ← Then here (30 min)
├─ Copy/paste TypeScript code
└─ Testing + local verification

JRD_PETROWISE_ROADMAP.md             ← Then here (40 min)
├─ 18-week timeline
└─ Week-by-week deliverables

JRD_PETROWISE_FINAL_SUMMARY.md       ← Reference (10 min)
└─ High-level overview

THIS FILE                              ← For quick startup
└─ Get going Monday morning
```

---

## 🎬 ACTION ITEMS

- [ ] Read 4 documents (3-4 hours)
- [ ] Identify service ports on your system
- [ ] Check for OpenAPI specs
- [ ] Set up Node.js environment
- [ ] Monday: Initialize backend project
- [ ] Monday: Copy APIDiscoveryService code
- [ ] Tuesday: Test discovery working
- [ ] Wednesday: Register endpoints
- [ ] Thursday: Write first test
- [ ] Friday: First git commit

---

**Status:** Ready to start ✅  
**Timeline:** 18 weeks to MVP  
**Next:** Monday morning Sprint 1 begins  
**Questions?** All answered in the 4 documents above

