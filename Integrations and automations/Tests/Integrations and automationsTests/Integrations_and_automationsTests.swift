import Testing
@testable import Integrations_and_automations

@Test func studioBuilds() async throws {
    let studio = AutomationStudio.sample()
    #expect(!studio.flows.isEmpty)
    #expect(!studio.integrations.isEmpty)
}

@Test func flowsHaveNodes() async throws {
    let studio = AutomationStudio.sample()
    let flow = studio.flows[0]
    #expect(!flow.nodes.isEmpty)
    #expect(!flow.connections.isEmpty)
}

@Test func rendererOutputsHTML() async throws {
    let studio = AutomationStudio.sample()
    let html = StudioRenderer().renderHTML(studio)
    #expect(html.contains("<html"))
    // Name contains & which is escaped to &amp; in HTML
    #expect(html.contains("Integrations &amp; Automations Studio"))
}
