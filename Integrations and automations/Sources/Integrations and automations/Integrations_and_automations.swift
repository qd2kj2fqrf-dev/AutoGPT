import Foundation

/*
 PROJECT INSTRUCTIONS (KEEP THIS AT THE TOP OF THIS FILE)
 - Agent runtime: Claude is the acting agent. Use Claude CLI + Claude Code to execute, generate, and complete tasks.
 - Backend design/build: Copilot is primary, with ChatGPT + Codex as collaborators for backend architecture and implementation.
 - Freedom with boundaries: maximize autonomy, but every action must stay inside the running product API.
 - Appliance-simple: three questions, defaults that work day one, and guardrails that are always visible.
 - VS Code first: keep the workspace organized around Sources/, Tests/, and Package.swift; avoid committing generated artifacts.
*/

/// Entry point type for integrations and automations.
public struct IntegrationsAndAutomations {
    public init() {}

    public func applianceKit() -> ApplianceCatalog {
        ApplianceCatalog.sample()
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
    case finance
    case ai
    case docs

    public var label: String {
        switch self {
        case .messaging: return "Messaging"
        case .data: return "Data"
        case .finance: return "Finance"
        case .ai: return "AI"
        case .docs: return "Docs"
        }
    }
}

public struct OperatingModel: Hashable, Sendable {
    public let agentRuntime: AgentRuntime
    public let backendBuild: BackendBuild
    public let apiBoundary: String
    public let workspaceGuide: WorkspaceGuide

    public init(
        agentRuntime: AgentRuntime,
        backendBuild: BackendBuild,
        apiBoundary: String,
        workspaceGuide: WorkspaceGuide
    ) {
        self.agentRuntime = agentRuntime
        self.backendBuild = backendBuild
        self.apiBoundary = apiBoundary
        self.workspaceGuide = workspaceGuide
    }
}

public struct AgentRuntime: Hashable, Sendable {
    public let name: String
    public let tools: [String]
    public let responsibilities: [String]

    public init(name: String, tools: [String], responsibilities: [String]) {
        self.name = name
        self.tools = tools
        self.responsibilities = responsibilities
    }
}

public struct BackendBuild: Hashable, Sendable {
    public let primary: String
    public let collaborators: [String]
    public let responsibilities: [String]

    public init(primary: String, collaborators: [String], responsibilities: [String]) {
        self.primary = primary
        self.collaborators = collaborators
        self.responsibilities = responsibilities
    }
}

public struct WorkspaceGuide: Hashable, Sendable {
    public let ide: String
    public let focusAreas: [String]
    public let rules: [String]

    public init(ide: String, focusAreas: [String], rules: [String]) {
        self.ide = ide
        self.focusAreas = focusAreas
        self.rules = rules
    }
}

public struct ApplianceCatalog: Hashable, Sendable {
    public let name: String
    public let promise: String
    public let principles: [String]
    public let operatingModel: OperatingModel
    public let integrations: [Integration]
    public let appliances: [AutomationAppliance]

    public init(
        name: String,
        promise: String,
        principles: [String],
        operatingModel: OperatingModel,
        integrations: [Integration],
        appliances: [AutomationAppliance]
    ) {
        self.name = name
        self.promise = promise
        self.principles = principles
        self.operatingModel = operatingModel
        self.integrations = integrations
        self.appliances = appliances
    }

    public static func sample() -> ApplianceCatalog {
        let operatingModel = OperatingModel(
            agentRuntime: AgentRuntime(
                name: "Claude",
                tools: ["Claude CLI", "Claude Code"],
                responsibilities: ["Act", "Generate", "Execute tasks end-to-end"]
            ),
            backendBuild: BackendBuild(
                primary: "Copilot",
                collaborators: ["ChatGPT", "Codex"],
                responsibilities: ["Design backend", "Implement adapters", "Ship tests"]
            ),
            apiBoundary: "All actions must stay inside the running product API. No external side effects.",
            workspaceGuide: WorkspaceGuide(
                ide: "VS Code",
                focusAreas: ["Sources/", "Tests/", "Package.swift"],
                rules: ["Avoid generated artifacts", "Remove duplicates", "Keep samples minimal"]
            )
        )

        let integrations: [Integration] = [
            Integration(
                id: "maildrop",
                name: "Maildrop",
                category: .messaging,
                capabilities: ["Inbound sync", "Smart triage", "Reply drafts"]
            ),
            Integration(
                id: "northwind",
                name: "Northwind CRM",
                category: .data,
                capabilities: ["Lead capture", "Lifecycle scoring", "Task routing"]
            ),
            Integration(
                id: "harbor",
                name: "Harbor Ledger",
                category: .finance,
                capabilities: ["Invoice watch", "Payment drift", "Cash notes"]
            ),
            Integration(
                id: "lumen",
                name: "Lumen AI",
                category: .ai,
                capabilities: ["Summaries", "Drafts", "Forecasts"]
            ),
            Integration(
                id: "folio",
                name: "Folio Docs",
                category: .docs,
                capabilities: ["Decision logs", "Briefs", "Context vault"]
            )
        ]

        let inboxAppliance = AutomationAppliance(
            id: "inbox_autopilot",
            name: "Inbox Autopilot",
            headline: "Your inbox works while you sleep.",
            outcome: "Daily digest, smart drafts, and the boring threads handled.",
            timeToValue: "10 min",
            setup: SetupFlow(steps: [
                SetupStep(
                    id: "delivery",
                    title: "Where should updates land?",
                    prompt: "Pick where you actually look every day.",
                    options: [
                        SetupOption(
                            id: "email_only",
                            label: "Email",
                            detail: "Simple and quiet. Digest arrives at 8am.",
                            adjustments: [
                                .setSchedule("Daily 8:00am")
                            ],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "chat_only",
                            label: "Chat",
                            detail: "Short bursts in your team channel.",
                            adjustments: [
                                .setSchedule("Weekdays at 9:00am")
                            ],
                            isRecommended: false
                        ),
                        SetupOption(
                            id: "both",
                            label: "Email + Chat",
                            detail: "Digest in email, heads-up in chat.",
                            adjustments: [
                                .setSchedule("Daily 8:00am")
                            ],
                            isRecommended: false
                        )
                    ]
                ),
                SetupStep(
                    id: "autonomy",
                    title: "How bold can it be?",
                    prompt: "Choose how much the appliance can act on its own.",
                    options: [
                        SetupOption(
                            id: "draft_only",
                            label: "Draft only",
                            detail: "Everything waits for your approval.",
                            adjustments: [
                                .setMode(.assist),
                                .addGuardrail(Guardrail(
                                    id: "no_send",
                                    title: "No auto-send",
                                    detail: "All outbound messages stay in drafts.",
                                    severity: .firm
                                ))
                            ],
                            isRecommended: false
                        ),
                        SetupOption(
                            id: "co_pilot",
                            label: "Co-pilot",
                            detail: "Auto-send low-risk replies, ask on sensitive ones.",
                            adjustments: [
                                .setMode(.copilot),
                                .addGuardrail(Guardrail(
                                    id: "sensitive_topics",
                                    title: "Sensitive topics require approval",
                                    detail: "Pricing, legal, and exec threads are held.",
                                    severity: .firm
                                ))
                            ],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "auto",
                            label: "Auto",
                            detail: "Auto-send routine replies with safety checks.",
                            adjustments: [
                                .setMode(.auto),
                                .addGuardrail(Guardrail(
                                    id: "escalate_uncertain",
                                    title: "Escalate low confidence",
                                    detail: "If confidence is below 0.76, request approval.",
                                    severity: .soft
                                ))
                            ],
                            isRecommended: false
                        )
                    ]
                ),
                SetupStep(
                    id: "never_touch",
                    title: "What should it never touch?",
                    prompt: "Pick a safe boundary and it will stay inside it.",
                    options: [
                        SetupOption(
                            id: "finance",
                            label: "Finance threads",
                            detail: "No invoices or payment promises.",
                            adjustments: [
                                .addGuardrail(Guardrail(
                                    id: "finance_hold",
                                    title: "Finance hold",
                                    detail: "Finance conversations always need review.",
                                    severity: .strict
                                ))
                            ],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "legal",
                            label: "Legal or compliance",
                            detail: "Nothing sent without explicit sign-off.",
                            adjustments: [
                                .addGuardrail(Guardrail(
                                    id: "legal_hold",
                                    title: "Legal hold",
                                    detail: "Legal topics route to a human owner.",
                                    severity: .strict
                                ))
                            ],
                            isRecommended: false
                        ),
                        SetupOption(
                            id: "execs",
                            label: "Executive threads",
                            detail: "Anything with the exec team stays manual.",
                            adjustments: [
                                .addGuardrail(Guardrail(
                                    id: "exec_hold",
                                    title: "Executive hold",
                                    detail: "Exec threads never auto-send.",
                                    severity: .firm
                                ))
                            ],
                            isRecommended: false
                        )
                    ]
                )
            ]),
            template: ApplianceTemplate(
                basePlan: [
                    PlanStep(
                        id: "capture",
                        title: "Capture incoming threads",
                        summary: "Sync new inbound messages and label them.",
                        integrationName: "Maildrop",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "classify",
                        title: "Classify intent",
                        summary: "Detect intent, urgency, and sentiment.",
                        integrationName: "Lumen AI",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "draft",
                        title: "Draft replies",
                        summary: "Generate concise, human-sounding replies.",
                        integrationName: "Lumen AI",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "queue",
                        title: "Queue for review",
                        summary: "Keep drafts ready with clear next actions.",
                        integrationName: "Maildrop",
                        requiresApproval: true
                    )
                ],
                defaultMode: .copilot,
                defaultSchedule: "Daily 8:00am",
                defaultGuardrails: [
                    Guardrail(
                        id: "attachment_block",
                        title: "No attachments",
                        detail: "Never send files unless manually approved.",
                        severity: .firm
                    )
                ]
            )
        )

        let leadAppliance = AutomationAppliance(
            id: "lead_nurture",
            name: "Lead Nurture",
            headline: "Leads never go cold.",
            outcome: "Every lead gets a personal touch in under 2 hours.",
            timeToValue: "12 min",
            setup: SetupFlow(steps: [
                SetupStep(
                    id: "lead_source",
                    title: "Where do leads arrive?",
                    prompt: "Pick the source with the most volume.",
                    options: [
                        SetupOption(
                            id: "crm",
                            label: "CRM",
                            detail: "Leads already land in the CRM.",
                            adjustments: [],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "web",
                            label: "Website form",
                            detail: "New submissions hit a form inbox.",
                            adjustments: [
                                .addStep(PlanStep(
                                    id: "form_capture",
                                    title: "Capture form submissions",
                                    summary: "Normalize inbound forms and attach metadata.",
                                    integrationName: "Maildrop",
                                    requiresApproval: false
                                ))
                            ],
                            isRecommended: false
                        )
                    ]
                ),
                SetupStep(
                    id: "followup_speed",
                    title: "How fast should follow-ups go out?",
                    prompt: "Faster replies win more deals.",
                    options: [
                        SetupOption(
                            id: "one_hour",
                            label: "Within 1 hour",
                            detail: "Aggressive for high-volume inbound.",
                            adjustments: [
                                .setSchedule("Every hour")
                            ],
                            isRecommended: false
                        ),
                        SetupOption(
                            id: "two_hours",
                            label: "Within 2 hours",
                            detail: "Balanced between speed and control.",
                            adjustments: [
                                .setSchedule("Every 2 hours")
                            ],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "same_day",
                            label: "Same day",
                            detail: "Gentle touch, lower pressure.",
                            adjustments: [
                                .setSchedule("Daily 4:00pm")
                            ],
                            isRecommended: false
                        )
                    ]
                ),
                SetupStep(
                    id: "handoff",
                    title: "Who approves the first message?",
                    prompt: "Keep the human in the loop when needed.",
                    options: [
                        SetupOption(
                            id: "auto",
                            label: "Auto for low-risk",
                            detail: "Auto-send templates for SMB leads.",
                            adjustments: [
                                .setMode(.auto),
                                .addGuardrail(Guardrail(
                                    id: "enterprise_hold",
                                    title: "Enterprise hold",
                                    detail: "Enterprise accounts always require review.",
                                    severity: .firm
                                ))
                            ],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "approval",
                            label: "Approval required",
                            detail: "Every message waits for review.",
                            adjustments: [
                                .setMode(.assist)
                            ],
                            isRecommended: false
                        )
                    ]
                )
            ]),
            template: ApplianceTemplate(
                basePlan: [
                    PlanStep(
                        id: "lead_capture",
                        title: "Capture new lead",
                        summary: "Bring new leads into the routing queue.",
                        integrationName: "Northwind CRM",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "enrich",
                        title: "Enrich profile",
                        summary: "Fill gaps with firmographic context.",
                        integrationName: "Lumen AI",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "draft_intro",
                        title: "Draft intro message",
                        summary: "Personalize with context and next step.",
                        integrationName: "Lumen AI",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "route",
                        title: "Route to owner",
                        summary: "Assign to the right rep and log details.",
                        integrationName: "Northwind CRM",
                        requiresApproval: true
                    )
                ],
                defaultMode: .copilot,
                defaultSchedule: "Every 2 hours",
                defaultGuardrails: [
                    Guardrail(
                        id: "no_pricing",
                        title: "No pricing quotes",
                        detail: "Price discussions always require approval.",
                        severity: .firm
                    )
                ]
            )
        )

        let invoiceAppliance = AutomationAppliance(
            id: "invoice_nudge",
            name: "Invoice Nudge",
            headline: "Gentle reminders that get paid.",
            outcome: "Overdue invoices get a clean follow-up without awkwardness.",
            timeToValue: "8 min",
            setup: SetupFlow(steps: [
                SetupStep(
                    id: "tone",
                    title: "Pick the tone",
                    prompt: "Set the vibe for reminders.",
                    options: [
                        SetupOption(
                            id: "gentle",
                            label: "Gentle",
                            detail: "Friendly and short, assumes a mistake.",
                            adjustments: [
                                .addStep(PlanStep(
                                    id: "tone_gentle",
                                    title: "Use friendly language",
                                    summary: "Keep reminders soft and helpful.",
                                    integrationName: "Lumen AI",
                                    requiresApproval: false
                                ))
                            ],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "neutral",
                            label: "Neutral",
                            detail: "Clear, professional, direct.",
                            adjustments: [],
                            isRecommended: false
                        ),
                        SetupOption(
                            id: "firm",
                            label: "Firm",
                            detail: "Direct with clear next steps.",
                            adjustments: [
                                .addGuardrail(Guardrail(
                                    id: "approval_firm",
                                    title: "Firm tone review",
                                    detail: "Firm reminders require approval.",
                                    severity: .soft
                                ))
                            ],
                            isRecommended: false
                        )
                    ]
                ),
                SetupStep(
                    id: "escalate",
                    title: "When should it escalate?",
                    prompt: "Choose the escalation window.",
                    options: [
                        SetupOption(
                            id: "seven_days",
                            label: "After 7 days",
                            detail: "Act quickly on drift.",
                            adjustments: [
                                .setSchedule("Daily 9:00am")
                            ],
                            isRecommended: false
                        ),
                        SetupOption(
                            id: "fourteen_days",
                            label: "After 14 days",
                            detail: "Balanced, reduces noise.",
                            adjustments: [
                                .setSchedule("Weekdays 9:00am")
                            ],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "thirty_days",
                            label: "After 30 days",
                            detail: "Gentle, very low touch.",
                            adjustments: [
                                .setSchedule("Weekly Monday 9:00am")
                            ],
                            isRecommended: false
                        )
                    ]
                ),
                SetupStep(
                    id: "owner",
                    title: "Who owns the message?",
                    prompt: "Keep it aligned with your brand voice.",
                    options: [
                        SetupOption(
                            id: "finance",
                            label: "Finance",
                            detail: "Send from the billing team address.",
                            adjustments: [],
                            isRecommended: true
                        ),
                        SetupOption(
                            id: "account",
                            label: "Account owner",
                            detail: "Sent from the rep managing the client.",
                            adjustments: [
                                .addGuardrail(Guardrail(
                                    id: "account_owner_review",
                                    title: "Owner approval",
                                    detail: "Account owners must approve the first send.",
                                    severity: .soft
                                ))
                            ],
                            isRecommended: false
                        )
                    ]
                )
            ]),
            template: ApplianceTemplate(
                basePlan: [
                    PlanStep(
                        id: "invoice_watch",
                        title: "Watch invoice drift",
                        summary: "Detect invoices past due.",
                        integrationName: "Harbor Ledger",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "summarize",
                        title: "Summarize context",
                        summary: "Highlight reason and payment history.",
                        integrationName: "Lumen AI",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "draft_note",
                        title: "Draft reminder",
                        summary: "Create a friendly follow-up.",
                        integrationName: "Lumen AI",
                        requiresApproval: false
                    ),
                    PlanStep(
                        id: "log",
                        title: "Log follow-up",
                        summary: "Record outreach in a decision log.",
                        integrationName: "Folio Docs",
                        requiresApproval: false
                    )
                ],
                defaultMode: .copilot,
                defaultSchedule: "Weekdays 9:00am",
                defaultGuardrails: [
                    Guardrail(
                        id: "no_promises",
                        title: "No payment promises",
                        detail: "Never commit to payment terms without a human.",
                        severity: .firm
                    )
                ]
            )
        )

        return ApplianceCatalog(
            name: "Appliance Automation OS",
            promise: "Simple, sellable automations for teams that never want to touch a prompt.",
            principles: [
                "Ask only three questions.",
                "Auto-configure from defaults that work on day one.",
                "Stay inside the product API, never outside it.",
                "Guardrails are always visible, editable, and human-first."
            ],
            operatingModel: operatingModel,
            integrations: integrations,
            appliances: [inboxAppliance, leadAppliance, invoiceAppliance]
        )
    }
}

public struct AutomationAppliance: Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let headline: String
    public let outcome: String
    public let timeToValue: String
    public let setup: SetupFlow
    public let template: ApplianceTemplate

    public init(
        id: String,
        name: String,
        headline: String,
        outcome: String,
        timeToValue: String,
        setup: SetupFlow,
        template: ApplianceTemplate
    ) {
        self.id = id
        self.name = name
        self.headline = headline
        self.outcome = outcome
        self.timeToValue = timeToValue
        self.setup = setup
        self.template = template
    }
}

public struct SetupFlow: Hashable, Sendable {
    public let steps: [SetupStep]

    public init(steps: [SetupStep]) {
        self.steps = steps
    }
}

public struct SetupStep: Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let prompt: String
    public let options: [SetupOption]

    public init(id: String, title: String, prompt: String, options: [SetupOption]) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.options = options
    }
}

public struct SetupOption: Hashable, Identifiable, Sendable {
    public let id: String
    public let label: String
    public let detail: String
    public let adjustments: [PlanAdjustment]
    public let isRecommended: Bool

    public init(
        id: String,
        label: String,
        detail: String,
        adjustments: [PlanAdjustment],
        isRecommended: Bool
    ) {
        self.id = id
        self.label = label
        self.detail = detail
        self.adjustments = adjustments
        self.isRecommended = isRecommended
    }
}

public struct ApplianceTemplate: Hashable, Sendable {
    public let basePlan: [PlanStep]
    public let defaultMode: AutonomyMode
    public let defaultSchedule: String
    public let defaultGuardrails: [Guardrail]

    public init(
        basePlan: [PlanStep],
        defaultMode: AutonomyMode,
        defaultSchedule: String,
        defaultGuardrails: [Guardrail]
    ) {
        self.basePlan = basePlan
        self.defaultMode = defaultMode
        self.defaultSchedule = defaultSchedule
        self.defaultGuardrails = defaultGuardrails
    }
}

public struct PlanStep: Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let integrationName: String
    public let requiresApproval: Bool

    public init(
        id: String,
        title: String,
        summary: String,
        integrationName: String,
        requiresApproval: Bool
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.integrationName = integrationName
        self.requiresApproval = requiresApproval
    }
}

public enum AutonomyMode: String, CaseIterable, Hashable, Sendable {
    case assist
    case copilot
    case auto

    public var label: String {
        switch self {
        case .assist: return "Assist"
        case .copilot: return "Co-pilot"
        case .auto: return "Auto"
        }
    }

    public var summary: String {
        switch self {
        case .assist: return "Drafts only, human sends."
        case .copilot: return "Auto-send routine items, ask on risk."
        case .auto: return "Auto-send with guardrails and escalation."
        }
    }
}

public struct Guardrail: Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let severity: GuardrailSeverity

    public init(id: String, title: String, detail: String, severity: GuardrailSeverity) {
        self.id = id
        self.title = title
        self.detail = detail
        self.severity = severity
    }
}

public enum GuardrailSeverity: String, CaseIterable, Hashable, Sendable {
    case soft
    case firm
    case strict

    public var label: String {
        switch self {
        case .soft: return "Soft"
        case .firm: return "Firm"
        case .strict: return "Strict"
        }
    }
}

public enum PlanAdjustment: Hashable, Sendable {
    case addStep(PlanStep)
    case addGuardrail(Guardrail)
    case setMode(AutonomyMode)
    case setSchedule(String)
}

public struct ApplianceRecommendation: Hashable, Sendable {
    public let appliance: AutomationAppliance
    public let plan: [PlanStep]
    public let mode: AutonomyMode
    public let schedule: String
    public let guardrails: [Guardrail]
    public let estimatedSetupMinutes: Int
    public let config: AutomationConfig

    public init(
        appliance: AutomationAppliance,
        plan: [PlanStep],
        mode: AutonomyMode,
        schedule: String,
        guardrails: [Guardrail],
        estimatedSetupMinutes: Int,
        config: AutomationConfig
    ) {
        self.appliance = appliance
        self.plan = plan
        self.mode = mode
        self.schedule = schedule
        self.guardrails = guardrails
        self.estimatedSetupMinutes = estimatedSetupMinutes
        self.config = config
    }
}

public struct AutomationConfig: Codable, Hashable, Sendable {
    public let applianceId: String
    public let applianceName: String
    public let mode: String
    public let schedule: String
    public let steps: [AutomationConfigStep]
    public let guardrails: [String]

    public init(
        applianceId: String,
        applianceName: String,
        mode: String,
        schedule: String,
        steps: [AutomationConfigStep],
        guardrails: [String]
    ) {
        self.applianceId = applianceId
        self.applianceName = applianceName
        self.mode = mode
        self.schedule = schedule
        self.steps = steps
        self.guardrails = guardrails
    }
}

public struct AutomationConfigStep: Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let integration: String
    public let requiresApproval: Bool

    public init(id: String, title: String, integration: String, requiresApproval: Bool) {
        self.id = id
        self.title = title
        self.integration = integration
        self.requiresApproval = requiresApproval
    }
}

public struct ApplianceEngine {
    public init() {}

    public func defaultAnswers(for appliance: AutomationAppliance) -> [String: String] {
        var answers: [String: String] = [:]
        for step in appliance.setup.steps {
            if let recommended = step.options.first(where: { $0.isRecommended }) {
                answers[step.id] = recommended.id
            } else if let first = step.options.first {
                answers[step.id] = first.id
            }
        }
        return answers
    }

    public func recommend(
        appliance: AutomationAppliance,
        answers: [String: String]
    ) -> ApplianceRecommendation {
        var plan = appliance.template.basePlan
        var mode = appliance.template.defaultMode
        var schedule = appliance.template.defaultSchedule
        var guardrails = appliance.template.defaultGuardrails

        for step in appliance.setup.steps {
            guard let selectedId = answers[step.id],
                  let option = step.options.first(where: { $0.id == selectedId }) else {
                continue
            }

            for adjustment in option.adjustments {
                switch adjustment {
                case .addStep(let newStep):
                    plan.append(newStep)
                case .addGuardrail(let newGuardrail):
                    guardrails.append(newGuardrail)
                case .setMode(let newMode):
                    mode = newMode
                case .setSchedule(let newSchedule):
                    schedule = newSchedule
                }
            }
        }

        let estimatedSetupMinutes = max(8, 4 + plan.count * 2 + appliance.setup.steps.count)
        let config = AutomationConfig(
            applianceId: appliance.id,
            applianceName: appliance.name,
            mode: mode.label,
            schedule: schedule,
            steps: plan.map {
                AutomationConfigStep(
                    id: $0.id,
                    title: $0.title,
                    integration: $0.integrationName,
                    requiresApproval: $0.requiresApproval
                )
            },
            guardrails: guardrails.map { "\($0.title): \($0.detail)" }
        )

        return ApplianceRecommendation(
            appliance: appliance,
            plan: plan,
            mode: mode,
            schedule: schedule,
            guardrails: guardrails,
            estimatedSetupMinutes: estimatedSetupMinutes,
            config: config
        )
    }

    public func exportJSON(_ recommendation: ApplianceRecommendation) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(recommendation.config),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

public struct ApplianceRenderer {
    public init() {}

    public func renderCLI(catalog: ApplianceCatalog, recommendation: ApplianceRecommendation) -> String {
        var lines: [String] = []
        lines.append(catalog.name)
        lines.append(String(repeating: "=", count: catalog.name.count))
        lines.append(catalog.promise)
        lines.append("")
        lines.append("Why it works")
        lines.append(String(repeating: "-", count: 12))
        catalog.principles.forEach { lines.append("* \($0)") }
        lines.append("")
        lines.append("Appliances")
        lines.append(String(repeating: "-", count: 10))
        for appliance in catalog.appliances {
            lines.append("* \(appliance.name): \(appliance.headline) (\(appliance.timeToValue))")
        }
        lines.append("")
        lines.append("Recommended Setup: \(recommendation.appliance.name)")
        lines.append(String(repeating: "-", count: 30))
        for step in recommendation.appliance.setup.steps {
            let selected = recommendationSelection(for: step)
            lines.append("* \(step.title) -> \(selected.label)")
        }
        lines.append("")
        lines.append("Automation Plan")
        lines.append(String(repeating: "-", count: 15))
        for planStep in recommendation.plan {
            let approval = planStep.requiresApproval ? " (approval)" : ""
            lines.append("* \(planStep.title) [\(planStep.integrationName)]\(approval)")
        }
        lines.append("")
        lines.append("Autonomy: \(recommendation.mode.label) - \(recommendation.mode.summary)")
        lines.append("Schedule: \(recommendation.schedule)")
        lines.append("Setup time: ~\(recommendation.estimatedSetupMinutes) min")
        lines.append("")
        lines.append("Guardrails")
        lines.append(String(repeating: "-", count: 10))
        for guardrail in recommendation.guardrails {
            lines.append("* \(guardrail.title) (\(guardrail.severity.label))")
        }
        return lines.joined(separator: "\n")
    }

    public func renderHTML(
        catalog: ApplianceCatalog,
        recommendation: ApplianceRecommendation,
        configJSON: String
    ) -> String {
        let applianceCards = catalog.appliances.enumerated().map { index, appliance in
            let outcomes = appliance.outcome.split(separator: ",").map {
                "<li>\(htmlEscape(String($0)).trimmingCharacters(in: .whitespaces))</li>"
            }.joined()
            return """
            <article class="appliance" style="animation-delay: \(Double(index) * 0.08)s;">
                <div>
                    <p class="tag">\(htmlEscape(appliance.timeToValue)) setup</p>
                    <h3>\(htmlEscape(appliance.name))</h3>
                    <p class="headline">\(htmlEscape(appliance.headline))</p>
                    <p class="outcome">\(htmlEscape(appliance.outcome))</p>
                </div>
                <ul>\(outcomes)</ul>
                <button type="button" class="ghost">Start with defaults</button>
            </article>
            """
        }.joined(separator: "\n")

        let setupSteps = recommendation.appliance.setup.steps.enumerated().map { index, step in
            let selected = recommendationSelection(for: step)
            return """
            <div class="setup-step" style="animation-delay: \(Double(index) * 0.06)s;">
                <span class="step-index">0\(index + 1)</span>
                <div>
                    <h4>\(htmlEscape(step.title))</h4>
                    <p>\(htmlEscape(step.prompt))</p>
                    <p class="choice">Default: \(htmlEscape(selected.label))</p>
                </div>
            </div>
            """
        }.joined(separator: "\n")

        let planSteps = recommendation.plan.enumerated().map { index, step in
            let approval = step.requiresApproval ? "Requires approval" : "Auto"
            return """
            <div class="plan-step" style="animation-delay: \(Double(index) * 0.05)s;">
                <h4>\(htmlEscape(step.title))</h4>
                <p>\(htmlEscape(step.summary))</p>
                <span>\(htmlEscape(step.integrationName)) • \(approval)</span>
            </div>
            """
        }.joined(separator: "\n")

        let guardrails = recommendation.guardrails.map {
            "<li><strong>\(htmlEscape($0.title))</strong> \(htmlEscape($0.detail))</li>"
        }.joined(separator: "\n")

        let principles = catalog.principles.map { "<li>\(htmlEscape($0))</li>" }.joined()

        let configSnippet = htmlEscape(configJSON)

        return """
        <!doctype html>
        <html lang="en">
        <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>\(htmlEscape(catalog.name))</title>
            <style>
                :root {
                    --cream: #f7f3e9;
                    --ink: #1b1a18;
                    --clay: #d08c6b;
                    --sun: #f0b45c;
                    --sand: #f2e6d2;
                    --stone: #3c3430;
                }
                * { box-sizing: border-box; }
                body {
                    margin: 0;
                    font-family: "Futura", "Trebuchet MS", sans-serif;
                    color: var(--ink);
                    background: radial-gradient(circle at 20% 20%, rgba(240, 180, 92, 0.25), transparent 55%),
                                radial-gradient(circle at 80% 10%, rgba(208, 140, 107, 0.2), transparent 50%),
                                var(--cream);
                }
                h1, h2, h3, h4 {
                    font-family: "Iowan Old Style", "Palatino", "Times New Roman", serif;
                    margin: 0;
                }
                main {
                    max-width: 1160px;
                    margin: 0 auto;
                    padding: 48px 28px 80px;
                    display: grid;
                    gap: 48px;
                }
                .hero {
                    display: grid;
                    gap: 18px;
                    padding: 28px 32px;
                    border-radius: 28px;
                    background: white;
                    box-shadow: 0 24px 60px rgba(27, 26, 24, 0.12);
                    animation: rise 0.7s ease-out both;
                }
                .hero h1 {
                    font-size: clamp(2.4rem, 3.2vw, 3.6rem);
                    letter-spacing: 1px;
                }
                .hero p {
                    font-size: 1.05rem;
                    max-width: 720px;
                }
                .pill-row {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 10px;
                }
                .pill {
                    padding: 6px 12px;
                    border-radius: 999px;
                    background: var(--sand);
                    font-size: 0.85rem;
                }
                .section-title {
                    display: flex;
                    justify-content: space-between;
                    align-items: baseline;
                }
                .section-title h2 {
                    font-size: 1.6rem;
                }
                .appliance-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
                    gap: 18px;
                }
                .appliance {
                    background: white;
                    border-radius: 24px;
                    padding: 20px;
                    display: grid;
                    gap: 16px;
                    box-shadow: 0 18px 40px rgba(27, 26, 24, 0.12);
                    animation: rise 0.8s ease-out both;
                }
                .appliance h3 { font-size: 1.4rem; }
                .appliance .headline { font-weight: 600; }
                .appliance .outcome { opacity: 0.8; }
                .appliance ul {
                    margin: 0;
                    padding-left: 20px;
                    display: grid;
                    gap: 6px;
                }
                .tag {
                    display: inline-block;
                    padding: 4px 10px;
                    border-radius: 999px;
                    background: var(--sand);
                    font-size: 0.75rem;
                    text-transform: uppercase;
                    letter-spacing: 1.2px;
                }
                .ghost {
                    border: 1px solid var(--stone);
                    border-radius: 999px;
                    padding: 8px 14px;
                    background: transparent;
                    font-size: 0.85rem;
                }
                .setup-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
                    gap: 16px;
                }
                .setup-step {
                    background: var(--sand);
                    border-radius: 20px;
                    padding: 16px;
                    display: grid;
                    gap: 12px;
                    animation: rise 0.8s ease-out both;
                }
                .step-index {
                    font-size: 0.9rem;
                    font-weight: 600;
                    color: var(--stone);
                }
                .choice {
                    font-weight: 600;
                    color: var(--stone);
                }
                .plan-grid {
                    display: grid;
                    gap: 14px;
                }
                .plan-step {
                    background: white;
                    border-radius: 20px;
                    padding: 18px;
                    display: grid;
                    gap: 8px;
                    box-shadow: 0 12px 30px rgba(27, 26, 24, 0.08);
                    animation: rise 0.9s ease-out both;
                }
                .plan-step span {
                    font-size: 0.85rem;
                    color: var(--stone);
                }
                .guardrails {
                    background: var(--ink);
                    color: var(--cream);
                    border-radius: 24px;
                    padding: 24px;
                    display: grid;
                    gap: 12px;
                }
                .guardrails ul {
                    margin: 0;
                    padding-left: 20px;
                    display: grid;
                    gap: 8px;
                }
                .config {
                    background: #101010;
                    color: #f6f2ea;
                    border-radius: 18px;
                    padding: 20px;
                    font-family: "SFMono-Regular", "Menlo", "Courier New", monospace;
                    font-size: 0.78rem;
                    white-space: pre-wrap;
                }
                .principles {
                    background: white;
                    border-radius: 24px;
                    padding: 22px;
                    box-shadow: 0 16px 40px rgba(27, 26, 24, 0.1);
                }
                .principles ul {
                    margin: 0;
                    padding-left: 20px;
                    display: grid;
                    gap: 8px;
                }
                footer {
                    font-size: 0.8rem;
                    opacity: 0.6;
                }
                @keyframes rise {
                    from { opacity: 0; transform: translateY(14px); }
                    to { opacity: 1; transform: translateY(0); }
                }
            </style>
        </head>
        <body>
            <main>
                <section class="hero">
                    <h1>\(htmlEscape(catalog.name))</h1>
                    <p>\(htmlEscape(catalog.promise))</p>
                    <div class="pill-row">
                        <span class="pill">\(catalog.appliances.count) appliances</span>
                        <span class="pill">Setup in under 15 minutes</span>
                        <span class="pill">Mode: \(htmlEscape(recommendation.mode.label))</span>
                    </div>
                </section>

                <section class="principles">
                    <div class="section-title">
                        <h2>Built like an appliance</h2>
                    </div>
                    <ul>\(principles)</ul>
                </section>

                <section>
                    <div class="section-title">
                        <h2>Pick your appliance</h2>
                        <p>Start with defaults. Change later.</p>
                    </div>
                    <div class="appliance-grid">\(applianceCards)</div>
                </section>

                <section>
                    <div class="section-title">
                        <h2>Three-step setup</h2>
                        <p>\(htmlEscape(recommendation.appliance.name)) defaults</p>
                    </div>
                    <div class="setup-grid">\(setupSteps)</div>
                </section>

                <section>
                    <div class="section-title">
                        <h2>Automation plan</h2>
                        <p>\(htmlEscape(recommendation.appliance.outcome))</p>
                    </div>
                    <div class="plan-grid">\(planSteps)</div>
                </section>

                <section class="guardrails">
                    <h2>Guardrails</h2>
                    <p>Visible, editable, and always human-first.</p>
                    <ul>\(guardrails)</ul>
                </section>

                <section>
                    <div class="section-title">
                        <h2>Appliance config (export)</h2>
                        <p>Drop this into the running API as-is.</p>
                    </div>
                    <div class="config">\(configSnippet)</div>
                </section>

                <footer>
                    Rendered locally. Tune the appliance definitions to ship a real product.
                </footer>
            </main>
        </body>
        </html>
        """
    }
}

private func recommendationSelection(for step: SetupStep) -> SetupOption {
    if let recommended = step.options.first(where: { $0.isRecommended }) {
        return recommended
    }
    return step.options.first ?? SetupOption(
        id: "none",
        label: "",
        detail: "",
        adjustments: [],
        isRecommended: false
    )
}

private func htmlEscape(_ value: String) -> String {
    value
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}
