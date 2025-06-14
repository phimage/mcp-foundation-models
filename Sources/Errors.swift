import Foundation

/// Custom error types for the MCP Foundation Models server
enum ServerError: Error, LocalizedError {
    case invalidParameter(String)
    case generationFailed(String)
    case serverSetupFailed(String)
    case unknownTool(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidParameter(let message):
            return "Invalid parameter: \(message)"
        case .generationFailed(let message):
            return "Text generation failed: \(message)"
        case .serverSetupFailed(let message):
            return "Server setup failed: \(message)"
        case .unknownTool(let name):
            return "Unknown tool requested: \(name)"
        }
    }
}

/// Result type for tool operations
struct ToolResult {
    let content: String
    let isError: Bool
    
    static func success(_ content: String) -> ToolResult {
        return ToolResult(content: content, isError: false)
    }
    
    static func error(_ message: String) -> ToolResult {
        return ToolResult(content: message, isError: true)
    }
}
