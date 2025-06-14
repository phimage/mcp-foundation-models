
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
    
    @Flag(name: .long, help: "Enable debug logging. You could use environment variable 'DEBUG' also to set this")
    var debug: Bool = false 

    mutating func run() async throws {
        // Configure logger level based on debug flag or environment variable
        let isDebugEnabled = debug || ProcessInfo.processInfo.environment["DEBUG"] != nil
        logger.logLevel = isDebugEnabled ? .debug : .info
        
        if isDebugEnabled {
            logger.debug("Debug logging enabled")
        }
        
        let finalSystemInstructions = systemInstructions ?? ProcessInfo.processInfo.environment["SYSTEM_INSTRUCTIONS"] ?? "Your are a helpful assistant."
        logger.debug("Using system instructions: \(finalSystemInstructions)")
        
        let mcpServer = try await FoundationModelsServer(systemInstructions: finalSystemInstructions, logger: logger)
 
        try await ServiceGroup(
            services: [mcpServer],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: logger
        ).run()
    }

}
