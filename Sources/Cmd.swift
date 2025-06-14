
import ArgumentParser
import Foundation
import FoundationModels
import Logging
import MCP
import ServiceLifecycle

nonisolated(unsafe) var logger = Logger(label: "mcp")
@main
struct Cmd: AsyncParsableCommand {
 
    @Option(name: .long, help: "Specify an alternate system instructions. You could use environment variable 'SYSTEM_INSTRUCTIONS' also to set this")
    var systemInstructions: String? 

    mutating func run() async throws {
        let finalSystemInstructions = systemInstructions ?? ProcessInfo.processInfo.environment["SYSTEM_INSTRUCTIONS"] ?? "Your are a helpful assistant."
        let mcpServer = try await FoundationModelsServer(systemInstructions: finalSystemInstructions, logger: logger)
 
        try await ServiceGroup(
            services: [mcpServer],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: logger
        ).run()
    }

}
