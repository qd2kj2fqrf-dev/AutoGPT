import Foundation
import Integrations_and_automations

let studio = AutomationStudio.sample()
let renderer = StudioRenderer()

print(renderer.renderCLI(studio))

let arguments = Set(CommandLine.arguments.dropFirst())
let shouldWriteHTML = arguments.contains("--html") || arguments.contains("--open") || arguments.contains("-o")
let shouldOpen = arguments.contains("--open") || arguments.contains("-o")

if shouldWriteHTML {
    let html = renderer.renderHTML(studio)
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
