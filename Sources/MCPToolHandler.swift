import Foundation
import MCP

/// Handles MCP tool definitions and schema creation
struct MCPToolHandler {
    
    /// Name of the foundation models tool
    static let foundationModelsToolName = "foundation-models"
    
    /// Creates the tool definition for Foundation Models
    static func createFoundationModelsTool() -> Tool {
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
        
        return Tool(
            name: foundationModelsToolName,
            description: "Generate text using Apple Foundation Models",
            inputSchema: .object(schema)
        )
    }
    
    /// Parses tool arguments into GenerationParameters
    static func parseArguments(_ arguments: [String: Value]?) throws -> GenerationParameters {
        guard let prompt = arguments?["prompt"]?.stringValue else {
            throw ServerError.invalidParameter("prompt is required")
        }
        
        let temperature = arguments?["temperature"]?.doubleValue
        let maxTokens = arguments?["max_tokens"]?.intValue
        
        return GenerationParameters(
            prompt: prompt,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }
}
