import Foundation
import FoundationModels
import MCP
import Logging
import ServiceLifecycle

/// MCP Server that provides Foundation Models text generation capabilities
class FoundationModelsServer: Service, @unchecked Sendable {
    
    private let configuration: ServerConfiguration
    private let server: MCP.Server
    private let logger: Logger
    private let textGenerationService: TextGenerationService

    /// Initialize the MCP server with configuration
    init(configuration: ServerConfiguration, logger: Logger) async throws {
        self.configuration = configuration
        self.logger = logger
        self.textGenerationService = FoundationModelsService(
            systemInstructions: configuration.systemInstructions,
            logger: logger
        )
        
        // Initialize MCP server
        self.server = MCP.Server(
            name: configuration.serverName,
            version: configuration.serverVersion,
            capabilities: .init(
                tools: .init(listChanged: false)
            )
        )
        
        // Setup MCP handlers
        try await setupMCPHandlers()
    }
    
    /// Setup MCP method handlers
    private func setupMCPHandlers() async throws {
        // Register tool listing handler
        await server.withMethodHandler(ListTools.self) { _ in
            return .init(tools: [MCPToolHandler.createFoundationModelsTool()])
        }        
        // Register tool execution handler
        await server.withMethodHandler(CallTool.self) { params in
            return await self.handleToolCall(params)
        }
    }
    
    /// Handle tool execution requests
    private func handleToolCall(_ params: CallTool.Parameters) async -> CallTool.Result {
        logger.debug("Received tool call: \(params.name) with arguments: \(String(describing: params.arguments))")
        
        switch params.name {
        case MCPToolHandler.foundationModelsToolName:
            return await handleFoundationModelsCall(params.arguments)
        default:
            logger.debug("Unknown tool requested: \(params.name)")
            return .init(
                content: [.text("Unknown tool: \(params.name)")],
                isError: true
            )
        }
    }
    
    /// Handle Foundation Models tool calls
    private func handleFoundationModelsCall(_ arguments: [String: Value]?) async -> CallTool.Result {
        do {
            // Parse and validate arguments
            let parameters = try MCPToolHandler.parseArguments(arguments)
            
            // Generate text using the service
            let result = try await textGenerationService.generateText(with: parameters)
            
            return .init(
                content: [.text(result)],
                isError: false
            )
        } catch let error as ServerError {
            logger.error("Tool execution failed: \(error.localizedDescription)")
            return .init(
                content: [.text(error.localizedDescription)],
                isError: true
            )
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            return .init(
                content: [.text("An unexpected error occurred: \(error.localizedDescription)")],
                isError: true
            )
        }
    }
    
    // MARK: - Service Lifecycle
    
    /// Start the MCP server
    func run() async throws {
        logger.info("Starting \(configuration.serverName) v\(configuration.serverVersion)")
        
        let transport = StdioTransport(logger: logger)
        try await server.start(transport: transport) { clientInfo, clientCapabilities in
            self.logger.info("Client \(clientInfo.name) v\(clientInfo.version) connected")
            self.logger.debug("Client capabilities: \(clientCapabilities)")
        }
        
        // Keep running until external cancellation
        logger.info("Server running and ready to accept connections")
        try await Task.sleep(for: .seconds(365 * 100 * 24 * 60 * 60)) // Effectively infinite
    }

    /// Stop the MCP server gracefully
    func stop() async throws {
        logger.info("Stopping server...")
        await server.stop()
        logger.info("Server stopped gracefully")
    }
}

