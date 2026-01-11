import Testing
@testable import Integrations_and_automations

@Test func catalogBuilds() async throws {
    let catalog = ApplianceCatalog.sample()
    #expect(!catalog.appliances.isEmpty)
    #expect(!catalog.integrations.isEmpty)
}

@Test func recommendationBuilds() async throws {
    let catalog = ApplianceCatalog.sample()
    let appliance = catalog.appliances[0]
    let engine = ApplianceEngine()
    let answers = engine.defaultAnswers(for: appliance)
    let recommendation = engine.recommend(appliance: appliance, answers: answers)
    #expect(!recommendation.plan.isEmpty)
    #expect(!recommendation.guardrails.isEmpty)
}

@Test func rendererOutputsHTML() async throws {
    let catalog = ApplianceCatalog.sample()
    let appliance = catalog.appliances[0]
    let engine = ApplianceEngine()
    let answers = engine.defaultAnswers(for: appliance)
    let recommendation = engine.recommend(appliance: appliance, answers: answers)
    let html = ApplianceRenderer().renderHTML(catalog: catalog, recommendation: recommendation, configJSON: engine.exportJSON(recommendation))
    #expect(html.contains("<html"))
    #expect(html.contains(catalog.name))
}
