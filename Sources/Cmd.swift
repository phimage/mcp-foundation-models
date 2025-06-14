
import ArgumentParser
import Foundation
import FoundationModels
import Logging
import MCP
import ServiceLifecycle

/// Global logger instance
nonisolated(unsafe) var logger = Logger(label: "mcp")

/// Main command for the MCP Foundation Models server
@main
struct Cmd: AsyncParsableCommand {
    
    // MARK: - Command Configuration
    
    static let configuration = CommandConfiguration(
        commandName: "mcp-foundation-models",
        abstract: "MCP Server that provides Apple Foundation Models text generation capabilities",
        discussion: """
        This server implements the Model Context Protocol (MCP) to provide text generation
        capabilities using Apple's Foundation Models framework.
        
        Environment Variables:
        - SYSTEM_INSTRUCTIONS: Set default system instructions
        - DEBUG: Enable debug logging (any non-empty value)
        """
    )
    
    // MARK: - Command Arguments
 
    @Option(
        name: .long,
        help: "Specify alternate system instructions. Overrides SYSTEM_INSTRUCTIONS environment variable."
    )
    var systemInstructions: String?
    
    @Flag(
        name: .long,
        help: "Enable debug logging. Can also be enabled with DEBUG environment variable."
    )
    var debug: Bool = false 

    // MARK: - Command Execution
    
    mutating func run() async throws {
        // Create configuration from command line arguments and environment
        let configuration = ServerConfiguration(
            systemInstructions: systemInstructions,
            debug: debug
        )
        
        // Configure logger
        configureLogger(configuration: configuration)
        
        // Log startup information
        logStartupInfo(configuration: configuration)
        
        // Create and run the server
        try await createAndRunServer(configuration: configuration)
    }
    
    // MARK: - Helper Methods
    
    /// Configure the global logger based on configuration
    private func configureLogger(configuration: ServerConfiguration) {
        logger.logLevel = configuration.isDebugEnabled ? .debug : .info
        
        if configuration.isDebugEnabled {
            logger.debug("Debug logging enabled")
        }
    }
    
    /// Log startup information
    private func logStartupInfo(configuration: ServerConfiguration) {
        logger.info("Starting MCP Foundation Models Server")
        logger.debug("Configuration:")
        logger.debug("  System instructions: \(configuration.systemInstructions)")
        logger.debug("  Debug enabled: \(configuration.isDebugEnabled)")
        logger.debug("  Server name: \(configuration.serverName)")
        logger.debug("  Server version: \(configuration.serverVersion)")
    }
    
    /// Create and run the MCP server with service lifecycle management
    private func createAndRunServer(configuration: ServerConfiguration) async throws {
        do {
            // Create the MCP server
            let mcpServer = try await FoundationModelsServer(
                configuration: configuration,
                logger: logger
            )
            
            // Run with graceful shutdown handling
            try await ServiceGroup(
                services: [mcpServer],
                gracefulShutdownSignals: [.sigterm, .sigint],
                logger: logger
            ).run()
            
        } catch {
            logger.error("Failed to start server: \(error.localizedDescription)")
            throw error
        }
    }
}
