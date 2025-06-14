import Foundation
import FoundationModels
import MCP
import Logging
import ServiceLifecycle

class FoundationModelsServer: Service, @unchecked Sendable {
    
    private let systemInstructions: String
    private let server: MCP.Server
    private let logger: Logger

    init(systemInstructions: String, logger: Logger) async throws {
        self.systemInstructions = systemInstructions
        self.logger = logger
        self.server =  MCP.Server(
            name: "mcp-foundation-models",
            version: "1.0.0",
            capabilities: .init(
                tools: .init(listChanged: false),
            ))
        // Register the FoundationModels tool
        await self.server.withMethodHandler(ListTools.self) { _ in

            let schema: [String: Value] = [
                "type": "object",
                "properties": [
                    "prompt": [
                        "type": "string",
                        "description": "The text prompt to generate a response for"
                    ],
                    "temperature": [
                        "type": "number",
                        "description": "Controls randomness in the output (0.0 to 1.0, default: 0.7)",
                        "minimum": 0.0,
                        "maximum": 1.0
                    ],
                    "max_tokens": [
                        "type": "integer",
                        "description": "Maximum number of tokens to generate"
                    ]
                ],
                "required": ["prompt"]
            ]

            return .init(tools: [
                Tool(
                    name: "foundation-models",
                    description: "Generate text using FoundationModels",
                    inputSchema: .object(schema)
                )
            ])
        }
        await self.server.withMethodHandler(CallTool.self) { params in
            self.logger.debug("Received tool call: \(params.name) with arguments: \(String(describing: params.arguments))")
            switch params.name {
            case "foundation-models":
                guard let prompt = params.arguments?["prompt"]?.stringValue else {
                    self.logger.debug("Missing prompt in arguments")
                    return .init(
                        content: [.text("prompt is required \(String(describing: params.arguments))")],
                        isError: true
                    )
                }

                let temperature = params.arguments?["temperature"]?.doubleValue ?? 0.7
                let maxTokens = params.arguments?["max_tokens"]?.intValue
                
                self.logger.debug("Processing request - prompt length: \(prompt.count), temperature: \(temperature), maxTokens: \(String(describing: maxTokens))")

                // Initialize the Foundation Models session
                let tools: [any FoundationModels.Tool] = []
                let model = SystemLanguageModel.default
                let session = LanguageModelSession(
                    model: model,
                    guardrails: .default,
                    tools: tools,
                    instructions: systemInstructions
                )
                
                // Set up generation options
                let sampling: GenerationOptions.SamplingMode? = nil
                let options = GenerationOptions(
                    sampling: sampling,
                    temperature: temperature,
                    maximumResponseTokens: maxTokens
                )

                do {
                    // Generate response using FoundationModels
                    self.logger.debug("Generating response with FoundationModels...")
                    let response = try await session.respond(to: prompt, options: options)
                    self.logger.debug("Generated response with \(response.content.count) characters")

                    return .init(
                        content: [.text(response.content)],
                        isError: false
                    )
                } catch {
                    self.logger.error("Failed to generate text: \(error.localizedDescription)")
                    return .init(
                        content: [.text("Failed to generate text: \(error.localizedDescription)")],
                        isError: true
                    )
                }
            default:
                self.logger.debug("Unknown tool requested: \(params.name)")
                return .init(content: [.text("Unknown tool")], isError: true)
            }
        }
    }
    
    func run() async throws {
        // Start the MCP server
        let transport = StdioTransport(logger: logger)
        try await server.start(transport: transport) { clientInfo, clientCapabilities in
            self.logger.info("Client \(clientInfo.name) v\(clientInfo.version) connected")
        }
        
        // Keep running until external cancellation
        try await Task.sleep(for: .seconds(365 * 100 * 24 * 60 * 60))
    }

    func stop() async throws {
        // Gracefully stop the server
        await server.stop()
        self.logger.info("Server stopped")
    }
}

