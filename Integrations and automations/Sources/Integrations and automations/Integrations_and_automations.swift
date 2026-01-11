import Foundation
/// Entry point type for the integrations and automations library.
public struct IntegrationsAndAutomations {
    public init() {}

    public func studio() -> AutomationStudio {
        AutomationStudio.sample()
    }
}

public struct Integration: Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let category: IntegrationCategory
    public let capabilities: [String]

    public init(id: String, name: String, category: IntegrationCategory, capabilities: [String]) {
        self.id = id
        self.name = name
        self.category = category
        self.capabilities = capabilities
    }
}

public enum IntegrationCategory: String, CaseIterable, Hashable, Sendable {
    case messaging
    case data
    case ops
    case finance
    case devtools
    case ai
    case docs

    public var label: String {
        switch self {
        case .messaging: return "Messaging"
        case .data: return "Data"
        case .ops: return "Ops"
        case .finance: return "Finance"
        case .devtools: return "Devtools"
        case .ai: return "AI"
        case .docs: return "Docs"
        }
    }
}

public enum NodeKind: String, CaseIterable, Hashable, Sendable {
    case trigger
    case action
    case filter
    case transform
    case decision
    case delay

    public var label: String {
        rawValue.uppercased()
    }
}

public struct AutomationNode: Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let kind: NodeKind
    public let detail: String
    public let integrationName: String?

    public init(
        id: String,
        title: String,
        kind: NodeKind,
        detail: String,
        integrationName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.detail = detail
        self.integrationName = integrationName
    }
}

public struct AutomationConnection: Hashable, Sendable {
    public let from: String
    public let to: String
    public let label: String

    public init(from: String, to: String, label: String = "") {
        self.from = from
        self.to = to
        self.label = label
    }
}

public struct FlowMetrics: Hashable, Sendable {
    public let successRate: String
    public let avgRuntime: String
    public let volumePerDay: String
    public let notes: String

    public init(successRate: String, avgRuntime: String, volumePerDay: String, notes: String) {
        self.successRate = successRate
        self.avgRuntime = avgRuntime
        self.volumePerDay = volumePerDay
        self.notes = notes
    }
}

public struct AutomationFlow: Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let intention: String
    public let nodes: [AutomationNode]
    public let connections: [AutomationConnection]
    public let metrics: FlowMetrics

    public init(
        id: String,
        name: String,
        intention: String,
        nodes: [AutomationNode],
        connections: [AutomationConnection],
        metrics: FlowMetrics
    ) {
        self.id = id
        self.name = name
        self.intention = intention
        self.nodes = nodes
        self.connections = connections
        self.metrics = metrics
    }
}

public struct StudioTheme: Hashable, Sendable {
    public let name: String
    public let accent: String
    public let accentSoft: String
    public let background: String
    public let backgroundAlt: String
    public let foreground: String
    public let highlight: String

    public init(
        name: String,
        accent: String,
        accentSoft: String,
        background: String,
        backgroundAlt: String,
        foreground: String,
        highlight: String
    ) {
        self.name = name
        self.accent = accent
        self.accentSoft = accentSoft
        self.background = background
        self.backgroundAlt = backgroundAlt
        self.foreground = foreground
        self.highlight = highlight
    }

    public static let presets: [StudioTheme] = [
        StudioTheme(
            name: "Copper Tide",
            accent: "#ff8a5b",
            accentSoft: "#ffb089",
            background: "#0c1a1f",
            backgroundAlt: "#14262e",
            foreground: "#f3f2ea",
            highlight: "#ffd6a8"
        ),
        StudioTheme(
            name: "Mint Voltage",
            accent: "#2cead3",
            accentSoft: "#97f2e7",
            background: "#081b20",
            backgroundAlt: "#0f2c33",
            foreground: "#e7fbf8",
            highlight: "#b6fff5"
        ),
        StudioTheme(
            name: "Solar Drift",
            accent: "#ffcc4d",
            accentSoft: "#ffe7a3",
            background: "#1c1410",
            backgroundAlt: "#2b1b12",
            foreground: "#fff5e3",
            highlight: "#ffe9c2"
        )
    ]
}

public struct AutomationStudio: Hashable, Sendable {
    public let name: String
    public let tagline: String
    public let theme: StudioTheme
    public let integrations: [Integration]
    public let flows: [AutomationFlow]
    public let workbenches: [StudioWorkbench]

    public init(
        name: String,
        tagline: String,
        theme: StudioTheme,
        integrations: [Integration],
        flows: [AutomationFlow],
        workbenches: [StudioWorkbench]
    ) {
        self.name = name
        self.tagline = tagline
        self.theme = theme
        self.integrations = integrations
        self.flows = flows
        self.workbenches = workbenches
    }

    public static func sample() -> AutomationStudio {
        let integrations: [Integration] = [
            Integration(
                id: "pulse",
                name: "Pulse Inbox",
                category: .messaging,
                capabilities: ["Thread capture", "Priority tags", "Human escalation"]
            ),
            Integration(
                id: "northwind",
                name: "Northwind CRM",
                category: .data,
                capabilities: ["Lead sync", "Lifecycle scoring", "Account notes"]
            ),
            Integration(
                id: "atlas",
                name: "Atlas Ops",
                category: .ops,
                capabilities: ["Runbook triggers", "On-call rotations", "Incident timeline"]
            ),
            Integration(
                id: "harbor",
                name: "Harbor Ledger",
                category: .finance,
                capabilities: ["Invoice watch", "Payment drift", "Cash forecast"]
            ),
            Integration(
                id: "quartz",
                name: "Quartz Build",
                category: .devtools,
                capabilities: ["Pipeline status", "Deploy gates", "Quality checks"]
            ),
            Integration(
                id: "lumen",
                name: "Lumen AI",
                category: .ai,
                capabilities: ["Summaries", "Forecasts", "Rag notes"]
            ),
            Integration(
                id: "folio",
                name: "Folio Docs",
                category: .docs,
                capabilities: ["Briefs", "Decision logs", "Evergreen pages"]
            )
        ]

        let leadFlowNodes: [AutomationNode] = [
            AutomationNode(
                id: "lead_trigger",
                title: "New lead scored",
                kind: .trigger,
                detail: "Score over 72 triggers handoff",
                integrationName: "Northwind CRM"
            ),
            AutomationNode(
                id: "lead_filter",
                title: "Filter by region",
                kind: .filter,
                detail: "Focus on NA + EMEA",
                integrationName: "Northwind CRM"
            ),
            AutomationNode(
                id: "lead_action",
                title: "Draft outreach",
                kind: .action,
                detail: "Create tailored intro email",
                integrationName: "Lumen AI"
            ),
            AutomationNode(
                id: "lead_sync",
                title: "Update pipeline",
                kind: .action,
                detail: "Push to sales pipeline",
                integrationName: "Northwind CRM"
            )
        ]

        let incidentFlowNodes: [AutomationNode] = [
            AutomationNode(
                id: "incident_trigger",
                title: "Incident detected",
                kind: .trigger,
                detail: "Latency spike above 2s",
                integrationName: "Atlas Ops"
            ),
            AutomationNode(
                id: "incident_delay",
                title: "Warmup window",
                kind: .delay,
                detail: "Hold for 3 minutes",
                integrationName: "Atlas Ops"
            ),
            AutomationNode(
                id: "incident_decision",
                title: "Noise gate",
                kind: .decision,
                detail: "Escalate if still unstable",
                integrationName: "Quartz Build"
            ),
            AutomationNode(
                id: "incident_action",
                title: "Launch runbook",
                kind: .action,
                detail: "Open incident dashboard",
                integrationName: "Atlas Ops"
            ),
            AutomationNode(
                id: "incident_notify",
                title: "Notify leads",
                kind: .action,
                detail: "Send bridge brief",
                integrationName: "Pulse Inbox"
            )
        ]

        let financeFlowNodes: [AutomationNode] = [
            AutomationNode(
                id: "finance_trigger",
                title: "Invoice drift",
                kind: .trigger,
                detail: "Late by 7 days",
                integrationName: "Harbor Ledger"
            ),
            AutomationNode(
                id: "finance_transform",
                title: "Summarize context",
                kind: .transform,
                detail: "Highlight overdue reason",
                integrationName: "Lumen AI"
            ),
            AutomationNode(
                id: "finance_action",
                title: "Prep followup",
                kind: .action,
                detail: "Draft finance note",
                integrationName: "Pulse Inbox"
            ),
            AutomationNode(
                id: "finance_log",
                title: "Log brief",
                kind: .action,
                detail: "Append to decision log",
                integrationName: "Folio Docs"
            )
        ]

        let flows: [AutomationFlow] = [
            AutomationFlow(
                id: "lead_orbit",
                name: "Lead Orbit",
                intention: "Convert fast-moving leads into tailored outreach without losing context.",
                nodes: leadFlowNodes,
                connections: [
                    AutomationConnection(from: "lead_trigger", to: "lead_filter"),
                    AutomationConnection(from: "lead_filter", to: "lead_action"),
                    AutomationConnection(from: "lead_action", to: "lead_sync")
                ],
                metrics: FlowMetrics(
                    successRate: "97%",
                    avgRuntime: "2m 18s",
                    volumePerDay: "140",
                    notes: "Auto-escalate on VIP signals"
                )
            ),
            AutomationFlow(
                id: "incident_radar",
                name: "Incident Radar",
                intention: "Spot high-signal incidents, reduce noise, and launch the right runbook.",
                nodes: incidentFlowNodes,
                connections: [
                    AutomationConnection(from: "incident_trigger", to: "incident_delay"),
                    AutomationConnection(from: "incident_delay", to: "incident_decision", label: "Stable?"),
                    AutomationConnection(from: "incident_decision", to: "incident_action", label: "Escalate"),
                    AutomationConnection(from: "incident_action", to: "incident_notify")
                ],
                metrics: FlowMetrics(
                    successRate: "92%",
                    avgRuntime: "4m 02s",
                    volumePerDay: "36",
                    notes: "Uses quiet hours gating"
                )
            ),
            AutomationFlow(
                id: "cash_drift",
                name: "Cash Drift",
                intention: "Surface payment drift and keep finance narratives tight.",
                nodes: financeFlowNodes,
                connections: [
                    AutomationConnection(from: "finance_trigger", to: "finance_transform"),
                    AutomationConnection(from: "finance_transform", to: "finance_action"),
                    AutomationConnection(from: "finance_action", to: "finance_log")
                ],
                metrics: FlowMetrics(
                    successRate: "95%",
                    avgRuntime: "1m 11s",
                    volumePerDay: "82",
                    notes: "Escalate after 14 days"
                )
            )
        ]

        let workbenches: [StudioWorkbench] = [
            StudioWorkbench(
                name: "Signal Deck",
                purpose: "Curate signals worth automation and rank them by impact.",
                focus: ["Lead quality", "Latency spikes", "Payment drift"]
            ),
            StudioWorkbench(
                name: "Human Loop",
                purpose: "Decide where humans must approve or refine automation output.",
                focus: ["Executive outreach", "Incident messaging", "Customer success followups"]
            ),
            StudioWorkbench(
                name: "Durability Lab",
                purpose: "Harden automations with fallback paths and observability.",
                focus: ["Retries", "Shadow modes", "Health probes"]
            )
        ]

        let themeSeed = "Integrations & Automations Studio"
        let themeIndex = stableIndex(seed: themeSeed, modulus: StudioTheme.presets.count)
        let theme = StudioTheme.presets[themeIndex]

        return AutomationStudio(
            name: "Integrations & Automations Studio",
            tagline: "A playful control room for stitching apps into cinematic automations.",
            theme: theme,
            integrations: integrations,
            flows: flows,
            workbenches: workbenches
        )
    }
}

public struct StudioWorkbench: Hashable, Sendable {
    public let name: String
    public let purpose: String
    public let focus: [String]

    public init(name: String, purpose: String, focus: [String]) {
        self.name = name
        self.purpose = purpose
        self.focus = focus
    }
}

public struct StudioRenderer {
    public init() {}

    public func renderCLI(_ studio: AutomationStudio) -> String {
        var lines: [String] = []
        lines.append(studio.name)
        lines.append(String(repeating: "=", count: studio.name.count))
        lines.append(studio.tagline)
        lines.append("Theme: \(studio.theme.name)")
        lines.append("")
        lines.append("Integrations")
        lines.append(String(repeating: "-", count: 12))
        for integration in studio.integrations {
            let caps = integration.capabilities.joined(separator: ", ")
            lines.append("* \(integration.name) [\(integration.category.label)]: \(caps)")
        }
        lines.append("")
        lines.append("Automation Flows")
        lines.append(String(repeating: "-", count: 16))
        for flow in studio.flows {
            lines.append("* \(flow.name) -- \(flow.intention)")
            lines.append("  Metrics: \(flow.metrics.successRate) success | \(flow.metrics.avgRuntime) avg | \(flow.metrics.volumePerDay) / day")
            lines.append("  Note: \(flow.metrics.notes)")
            lines.append("  \(renderNodeLine(flow.nodes))")
            lines.append("")
        }
        lines.append("Workbenches")
        lines.append(String(repeating: "-", count: 10))
        for bench in studio.workbenches {
            let focus = bench.focus.joined(separator: ", ")
            lines.append("* \(bench.name): \(bench.purpose) [\(focus)]")
        }
        return lines.joined(separator: "\n")
    }

    public func renderHTML(_ studio: AutomationStudio) -> String {
        let integrationCards = studio.integrations.enumerated().map { index, integration in
            let caps = integration.capabilities.map { "<li>\(htmlEscape($0))</li>" }.joined()
            return """
            <article class="card" style="animation-delay: \(Double(index) * 0.06)s;">
                <div class="card-header">
                    <p class="eyebrow">\(htmlEscape(integration.category.label))</p>
                    <h3>\(htmlEscape(integration.name))</h3>
                </div>
                <ul class="card-list">\(caps)</ul>
            </article>
            """
        }.joined(separator: "\n")

        let flowCards = studio.flows.enumerated().map { index, flow in
            let nodes = flow.nodes.map { node in
                let integrationLabel = node.integrationName.map { "<span class=\"node-meta\">\(htmlEscape($0))</span>" } ?? ""
                return """
                <div class="node \(node.kind.rawValue)">
                    <div class="node-title">\(htmlEscape(node.title))</div>
                    <div class="node-kind">\(htmlEscape(node.kind.label))</div>
                    <div class="node-detail">\(htmlEscape(node.detail))</div>
                    \(integrationLabel)
                </div>
                """
            }.joined(separator: "<div class=\"connector\">-&gt;</div>")

            return """
            <article class="flow" style="animation-delay: \(Double(index) * 0.08)s;">
                <header>
                    <div>
                        <p class="eyebrow">Automation Flow</p>
                        <h3>\(htmlEscape(flow.name))</h3>
                        <p class="flow-intent">\(htmlEscape(flow.intention))</p>
                    </div>
                    <div class="metrics">
                        <span>\(htmlEscape(flow.metrics.successRate)) success</span>
                        <span>\(htmlEscape(flow.metrics.avgRuntime)) avg</span>
                        <span>\(htmlEscape(flow.metrics.volumePerDay)) / day</span>
                    </div>
                </header>
                <div class="node-row">\(nodes)</div>
                <p class="flow-note">\(htmlEscape(flow.metrics.notes))</p>
            </article>
            """
        }.joined(separator: "\n")

        let workbenchCards = studio.workbenches.enumerated().map { index, bench in
            let focus = bench.focus.map { "<li>\(htmlEscape($0))</li>" }.joined()
            return """
            <article class="bench" style="animation-delay: \(Double(index) * 0.05)s;">
                <h3>\(htmlEscape(bench.name))</h3>
                <p>\(htmlEscape(bench.purpose))</p>
                <ul>\(focus)</ul>
            </article>
            """
        }.joined(separator: "\n")

        return """
        <!doctype html>
        <html lang="en">
        <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>\(htmlEscape(studio.name))</title>
            <style>
                :root {
                    --bg-1: \(studio.theme.background);
                    --bg-2: \(studio.theme.backgroundAlt);
                    --text: \(studio.theme.foreground);
                    --accent: \(studio.theme.accent);
                    --accent-soft: \(studio.theme.accentSoft);
                    --highlight: \(studio.theme.highlight);
                }
                * {
                    box-sizing: border-box;
                }
                body {
                    margin: 0;
                    min-height: 100vh;
                    background: radial-gradient(circle at 20% 20%, rgba(255, 255, 255, 0.08), transparent 55%),
                                radial-gradient(circle at 80% 10%, rgba(255, 255, 255, 0.12), transparent 40%),
                                linear-gradient(135deg, var(--bg-1), var(--bg-2));
                    color: var(--text);
                    font-family: "Avenir Next", "Gill Sans", "Trebuchet MS", sans-serif;
                    letter-spacing: 0.2px;
                }
                body::before {
                    content: "";
                    position: fixed;
                    inset: -20% -10%;
                    background: radial-gradient(circle at 30% 40%, rgba(255, 200, 120, 0.18), transparent 45%),
                                radial-gradient(circle at 70% 60%, rgba(60, 240, 220, 0.15), transparent 35%);
                    filter: blur(10px);
                    z-index: -2;
                }
                body::after {
                    content: "";
                    position: fixed;
                    width: 320px;
                    height: 320px;
                    border-radius: 50%;
                    border: 1px dashed rgba(255, 255, 255, 0.18);
                    top: -80px;
                    right: -40px;
                    opacity: 0.4;
                    z-index: -1;
                }
                .shell {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 48px 28px 80px;
                    display: flex;
                    flex-direction: column;
                    gap: 48px;
                }
                .hero {
                    display: grid;
                    gap: 16px;
                    padding: 24px;
                    background: rgba(0, 0, 0, 0.2);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    border-radius: 24px;
                    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.35);
                    animation: fadeUp 0.7s ease-out both;
                }
                .hero h1 {
                    margin: 0;
                    font-family: "Baskerville", "Times New Roman", serif;
                    font-size: clamp(2.2rem, 3vw, 3.4rem);
                    letter-spacing: 1px;
                }
                .hero p {
                    margin: 0;
                    font-size: 1.05rem;
                    opacity: 0.85;
                }
                .pill-row {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 12px;
                }
                .pill {
                    padding: 6px 14px;
                    border-radius: 999px;
                    background: rgba(255, 255, 255, 0.08);
                    border: 1px solid rgba(255, 255, 255, 0.18);
                    font-size: 0.85rem;
                }
                .section {
                    display: grid;
                    gap: 20px;
                }
                .section h2 {
                    margin: 0;
                    font-size: 1.4rem;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    color: var(--accent-soft);
                }
                .grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                    gap: 18px;
                }
                .card {
                    background: rgba(0, 0, 0, 0.35);
                    border: 1px solid rgba(255, 255, 255, 0.14);
                    border-radius: 20px;
                    padding: 18px;
                    display: grid;
                    gap: 12px;
                    box-shadow: 0 14px 30px rgba(0, 0, 0, 0.25);
                    animation: fadeUp 0.7s ease-out both;
                }
                .card-header h3,
                .bench h3,
                .flow h3 {
                    margin: 0;
                }
                .eyebrow {
                    margin: 0 0 6px;
                    font-size: 0.8rem;
                    text-transform: uppercase;
                    letter-spacing: 1.8px;
                    color: var(--accent-soft);
                }
                .card-list {
                    margin: 0;
                    padding-left: 18px;
                    display: grid;
                    gap: 6px;
                }
                .flows {
                    display: grid;
                    gap: 20px;
                }
                .flow {
                    background: rgba(8, 12, 16, 0.6);
                    border-radius: 24px;
                    padding: 24px;
                    border: 1px solid rgba(255, 255, 255, 0.15);
                    display: grid;
                    gap: 16px;
                    box-shadow: 0 22px 50px rgba(0, 0, 0, 0.35);
                    animation: fadeUp 0.8s ease-out both;
                }
                .flow header {
                    display: flex;
                    justify-content: space-between;
                    gap: 20px;
                    flex-wrap: wrap;
                }
                .flow-intent {
                    margin: 6px 0 0;
                    opacity: 0.8;
                }
                .metrics {
                    display: flex;
                    gap: 10px;
                    flex-wrap: wrap;
                    align-items: center;
                    font-size: 0.85rem;
                }
                .metrics span {
                    padding: 6px 10px;
                    border-radius: 999px;
                    border: 1px solid rgba(255, 255, 255, 0.18);
                    background: rgba(255, 255, 255, 0.08);
                }
                .node-row {
                    display: grid;
                    grid-auto-flow: column;
                    grid-auto-columns: minmax(180px, 1fr);
                    align-items: stretch;
                    gap: 12px;
                    overflow-x: auto;
                    padding-bottom: 8px;
                }
                .node {
                    background: rgba(255, 255, 255, 0.06);
                    border-radius: 18px;
                    padding: 14px;
                    border: 1px solid rgba(255, 255, 255, 0.12);
                    display: grid;
                    gap: 6px;
                    min-width: 180px;
                }
                .node-kind {
                    font-size: 0.75rem;
                    letter-spacing: 1.4px;
                    text-transform: uppercase;
                    color: var(--accent-soft);
                }
                .node-title {
                    font-weight: 600;
                }
                .node-detail {
                    font-size: 0.9rem;
                    opacity: 0.8;
                }
                .node-meta {
                    font-size: 0.75rem;
                    opacity: 0.7;
                }
                .connector {
                    display: none;
                }
                .node.trigger {
                    border-color: rgba(255, 190, 120, 0.4);
                }
                .node.action {
                    border-color: rgba(120, 255, 210, 0.35);
                }
                .node.filter,
                .node.decision {
                    border-color: rgba(255, 255, 255, 0.25);
                }
                .node.transform,
                .node.delay {
                    border-color: rgba(140, 200, 255, 0.35);
                }
                .flow-note {
                    margin: 0;
                    font-size: 0.85rem;
                    color: var(--highlight);
                }
                .bench-grid {
                    display: grid;
                    gap: 16px;
                    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                }
                .bench {
                    padding: 18px;
                    border-radius: 20px;
                    background: rgba(0, 0, 0, 0.32);
                    border: 1px solid rgba(255, 255, 255, 0.12);
                    display: grid;
                    gap: 8px;
                    animation: fadeUp 0.8s ease-out both;
                }
                .bench ul {
                    margin: 0;
                    padding-left: 18px;
                    display: grid;
                    gap: 6px;
                }
                .footer {
                    font-size: 0.8rem;
                    opacity: 0.6;
                }
                @keyframes fadeUp {
                    from {
                        opacity: 0;
                        transform: translateY(14px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
                @media (max-width: 720px) {
                    .flow header {
                        flex-direction: column;
                        align-items: flex-start;
                    }
                }
            </style>
        </head>
        <body>
            <main class="shell">
                <section class="hero">
                    <h1>\(htmlEscape(studio.name))</h1>
                    <p>\(htmlEscape(studio.tagline))</p>
                    <div class="pill-row">
                        <span class="pill">Theme: \(htmlEscape(studio.theme.name))</span>
                        <span class="pill">Integrations: \(studio.integrations.count)</span>
                        <span class="pill">Flows: \(studio.flows.count)</span>
                        <span class="pill">Workbenches: \(studio.workbenches.count)</span>
                    </div>
                </section>

                <section class="section">
                    <h2>Integration Orbit</h2>
                    <div class="grid">\(integrationCards)</div>
                </section>

                <section class="section">
                    <h2>Automation Theatre</h2>
                    <div class="flows">\(flowCards)</div>
                </section>

                <section class="section">
                    <h2>Workbenches</h2>
                    <div class="bench-grid">\(workbenchCards)</div>
                </section>

                <footer class="footer">
                    Rendered locally by StudioRenderer. Edit the Swift models to remix the universe.
                </footer>
            </main>
        </body>
        </html>
        """
    }
}

private func renderNodeLine(_ nodes: [AutomationNode]) -> String {
    nodes.map { node in
        let integration = node.integrationName.map { " (\($0))" } ?? ""
        return "[\(node.kind.label): \(node.title)\(integration)]"
    }.joined(separator: " -> ")
}

private func stableIndex(seed: String, modulus: Int) -> Int {
    guard modulus > 0 else { return 0 }
    var value = 0
    for scalar in seed.unicodeScalars {
        value = (value * 31 + Int(scalar.value)) % modulus
    }
    return value
}

private func htmlEscape(_ value: String) -> String {
    value
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}

autoreleasepool(invoking: { ~Copyable }) 
build_tool_version: "5.7.1"
import PackageDescription autonomous: true           