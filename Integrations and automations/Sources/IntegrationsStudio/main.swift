import Foundation
import Integrations_and_automations

let kit = IntegrationsAndAutomations()
let catalog = kit.applianceKit()
let engine = ApplianceEngine()
let renderer = ApplianceRenderer()

let selectedAppliance = catalog.appliances.first ?? AutomationAppliance(
    id: "empty",
    name: "Empty",
    headline: "No appliances available.",
    outcome: "",
    timeToValue: "",
    setup: SetupFlow(steps: []),
    template: ApplianceTemplate(basePlan: [], defaultMode: .assist, defaultSchedule: "", defaultGuardrails: [])
)

let answers = engine.defaultAnswers(for: selectedAppliance)
let recommendation = engine.recommend(appliance: selectedAppliance, answers: answers)

print(renderer.renderCLI(catalog: catalog, recommendation: recommendation))

let arguments = Set(CommandLine.arguments.dropFirst())
let shouldWriteHTML = arguments.contains("--html") || arguments.contains("--open") || arguments.contains("-o")
let shouldOpen = arguments.contains("--open") || arguments.contains("-o")

if shouldWriteHTML {
    let configJSON = engine.exportJSON(recommendation)
    let html = renderer.renderHTML(catalog: catalog, recommendation: recommendation, configJSON: configJSON)
    let fileName = "Integrations Studio Preview.html"
    let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent(fileName)

    do {
        try html.write(to: fileURL, atomically: true, encoding: .utf8)
        print("\nWrote preview to \(fileURL.path)")
        if shouldOpen {
            openFile(fileURL.path)
        }
    } catch {
        print("\nFailed to write HTML preview: \(error)")
    }
}

func openFile(_ path: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = [path]
    do {
        try process.run()
    } catch {
        print("Unable to open preview: \(error)")
    }
}
