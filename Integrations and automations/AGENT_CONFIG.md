# ⚠️ MANDATORY CONFIGURATION RULE

**ANY AGENT OR DEVELOPER WORKING ON THIS PROJECT MUST READ THIS FILE FIRST.**

---

## NON-NEGOTIABLE REQUIREMENT

Before you write a single line of code, modify a file, or make a commit:

### YOU MUST LOAD THIS CONFIGURATION

**Location:** `~/Library/CloudStorage/OneDrive-JRDCompanies/Claude-Config/`

This folder contains:
- `CLAUDE.md` - Master configuration + credentials
- `BRAIN/AGENT_BOOTSTRAP.md` - Full topology + secrets
- `BRAIN/state/` - Persistent state for long tasks
- All passwords, API keys, tokens, and auth contexts

**Why?** Because this project is part of the **AutoGPT ecosystem**, which requires consistent agent behavior across all implementations. Your configuration cascades from this single source of truth.

---

## STEP 1: CONFIGURE YOURSELF (Before Coding)

```bash
# If you're Claude (AI Agent)
1. Load: ~/Library/CloudStorage/OneDrive-JRDCompanies/Claude-Config/CLAUDE.md
2. Load: ~/Library/CloudStorage/OneDrive-JRDCompanies/Claude-Config/BRAIN/AGENT_BOOTSTRAP.md
3. Verify: You have access to Azure AD, Docker, Google Workspace tokens
4. Confirm: You know which Maplewood resources you're touching (if any)

# If you're a Human Developer
1. Read: CLAUDE.md from OneDrive
2. Read: AGENT_BOOTSTRAP.md for full topology
3. Get credentials from: MP Passwords v3.0.xlsx
4. Set up local env: .env file with Azure/Docker/Google tokens
```

---

## STEP 2: LOAD PROJECT CONTEXT

After configuring yourself, read these project files IN ORDER:

1. **[Package.swift](/Users/jdurand/AutoGPT/Integrations%20and%20automations/Package.swift)** - Project structure
2. **[FRONTEND_BUILDOUT.md](FRONTEND_BUILDOUT.md)** - Design system + interface contracts
3. **[DESIGN_PROMPTS.md](DESIGN_PROMPTS.md)** - Unconventional design exploration
4. **This file** - Agent behavior rules

---

## STEP 3: UNDERSTAND YOUR BOUNDARIES

| Task | Allowed? | Config Source | Notes |
|------|----------|---------------|-------|
| Modify Swift code | YES | CLAUDE.md → Tool Priority | Use codex skill if unrestricted |
| Add integrations | YES | AGENT_BOOTSTRAP.md → Integrations list | Ask first if new external API |
| Deploy to Azure | YES | CLAUDE.md → Azure credentials | Must be jrd.database.windows.net |
| Access Maplewood data | ASK FIRST | BRAIN/MP Passwords | Sensitive business data |
| Modify HTML/CSS | YES | FRONTEND_BUILDOUT.md → Component specs | Don't break existing design |
| Add new workbenches | YES | Design intent from DESIGN_PROMPTS.md | Must fit theatrical aesthetic |

---

## STEP 4: AGENT BEHAVIOR RULES

### Before You Touch Code:
```
□ Have you read CLAUDE.md? (Y/N)
□ Have you verified your tool priority? (Y/N)
□ Do you know which resources are in scope? (Y/N)
□ Have you checked if you need credentials? (Y/N)
→ If ANY are "N", STOP. Read the config files first.
```

### During Development:
```
□ Are you using the correct Python/Swift version?
□ Are your API calls authenticated against the right endpoint?
□ Have you checked AGENT_BOOTSTRAP.md for rate limits?
□ Are you logging to the right workspace (BRAIN/state/)?
→ After EVERY 5 steps, check: "Am I still on track?"
```

### Before You Commit:
```
□ Did you update this file if you changed project structure?
□ Did you document new integrations in FRONTEND_BUILDOUT.md?
□ Did you test against the sample data in AutomationStudio.sample()?
□ Did you check BRAIN/state/ for any persistent state to preserve?
→ If ANY are "N", add a TODO in your commit message.
```

---

## STEP 5: CONFIG FILE HIERARCHY

```
Integrations & Automations Project
├── CLAUDE.md (Source of Truth)
│   ├── Tool Priority
│   ├── All Credentials
│   ├── Azure resources (jrd.database.windows.net)
│   └── Resource network map
│
├── AGENT_BOOTSTRAP.md (Topology)
│   ├── All MCP servers
│   ├── Integration endpoints
│   ├── Rate limits per service
│   └── Fallback procedures
│
├── Project Files (This Workspace)
│   ├── Package.swift
│   ├── FRONTEND_BUILDOUT.md
│   ├── DESIGN_PROMPTS.md
│   ├── AGENT_CONFIG.md ← YOU ARE HERE
│   └── Source code (Swift, HTML, CSS)
│
└── BRAIN/state/ (Persistent State)
    ├── Execution logs
    ├── Task checkpoints
    └── Long-running state snapshots
```

**RULE:** If you ever feel uncertain about a setting, credentials, or boundary:
1. **Ask** (don't assume)
2. **Check CLAUDE.md** (source of truth)
3. **Check AGENT_BOOTSTRAP.md** (topology)
4. **Check this file** (project-specific rules)
5. **Escalate** if you still don't know

---

## STEP 6: SPECIFIC TO THIS PROJECT

### Integrations & Automations = Phase 1 of AutoGPT

**Your Job:** Build the **exterior shell** (frontend design system).  
**Backend:** Comes after, you don't touch it yet.  
**Data Models:** Defined in `Integrations_and_automations.swift`, DO NOT change signatures.

### CSS + Image Handling

Images in this project are **CSS-wrapped**. See [CSS_IMAGE_SYSTEM.md](CSS_IMAGE_SYSTEM.md) for:
- How images are embedded (base64, URL references)
- Theme-aware image styling
- Responsive image breakpoints
- Accessibility alt-text patterns

### Swift Code Rules

- **Never** break the `Integration`, `AutomationNode`, `AutomationFlow` structures
- **Always** use the theme system from `StudioTheme.presets`
- **Test** with `swift run IntegrationsStudio --html --open`
- **Log** any issues to `BRAIN/state/debug.log` (if long-running)

---

## STEP 7: ESCALATION PROCEDURE

If you get stuck:

1. **Check the config** (CLAUDE.md + AGENT_BOOTSTRAP.md)
2. **Search this project** (grep for similar patterns)
3. **Test locally** (build and run, don't guess)
4. **Document the blocker** in BRAIN/state/blockers.md
5. **Escalate** with: "I'm blocked on [X], checked [Y], need [Z]"

**DO NOT:**
- Assume credentials you don't have
- Skip reading config files
- Commit without testing
- Modify agent behavior rules without explicit permission

---

## STEP 8: KEEP THIS SYNCED

Every time you make a major change:
- Update this file with new rules/boundaries
- Update FRONTEND_BUILDOUT.md if design changes
- Update DESIGN_PROMPTS.md if new design patterns emerge
- Commit with message: `docs: update agent config per [change]`

---

## ONEDRIVE CLAUDE-CONFIG INTEGRATION

**Your OneDrive path:**
```
~/Library/CloudStorage/OneDrive-JRDCompanies/Claude-Config/
```

**What's in there:**
- CLAUDE.md (READ FIRST)
- BRAIN/ folder with all credentials
- skills/ folder with reusable prompts
- state/ folder for persistent data

**How to use it:**
1. Any time you start working: `cat ~/Library/CloudStorage/OneDrive-JRDCompanies/Claude-Config/CLAUDE.md`
2. Before making API calls: Check AGENT_BOOTSTRAP.md for endpoints
3. If storing state: Use BRAIN/state/ folder (is it synced? Check OneDrive status)

**Critical:** If OneDrive is NOT synced, you cannot work on this project. Sync it first.

---

## FINAL CHECKLIST

**Before you start:**
```
✓ OneDrive/Claude-Config is synced to your machine
✓ You've read CLAUDE.md completely
✓ You've read AGENT_BOOTSTRAP.md completely
✓ You understand the tool priority (Docker > Azure > Google > Cloudflare)
✓ You know which Maplewood resources are off-limits
✓ You have the MP Passwords file (or know you don't have access)
✓ You understand the project scope (Phase 1 = Frontend, Phase 2+ = Backend)
✓ You've read FRONTEND_BUILDOUT.md
✓ You've read DESIGN_PROMPTS.md
✓ You've read THIS FILE
→ If ANY ✗, STOP NOW. Don't code until you've completed all checks.
```

---

## QUICK REFERENCE

| Need | Location | Action |
|------|----------|--------|
| API credentials | `CLAUDE.md` | Load before first API call |
| Azure auth | `AGENT_BOOTSTRAP.md` | Verify endpoint (jrd.database.windows.net) |
| Maplewood access | `MP Passwords v3.0.xlsx` | ASK FIRST |
| Tool priority | `CLAUDE.md` | Docker > Azure > Google > Cloudflare |
| Integration endpoints | `AGENT_BOOTSTRAP.md` | Check rate limits |
| Project structure | `Package.swift` | Read to understand targets |
| Design rules | `FRONTEND_BUILDOUT.md` | Before touching HTML/CSS |
| Design exploration | `DESIGN_PROMPTS.md` | When iterating design |
| State persistence | `BRAIN/state/` | Log long-running tasks here |

---

## STATUS

**Last Updated:** January 11, 2026  
**Enforced By:** All agents working on Integrations & Automations  
**Review Frequency:** Every new feature, every new agent  
**Bypass Authority:** jdurand only (with explicit written consent)

**This is NON-NEGOTIABLE. No exceptions.**

---

**Read CLAUDE.md now. Then come back to code.**
