import Foundation

/// Configuration for the MCP Foundation Models server
struct ServerConfiguration {
    let systemInstructions: String
    let isDebugEnabled: Bool
    let serverName: String
    let serverVersion: String
    
    /// Default system instructions when none provided
    static let defaultSystemInstructions = "You are a helpful assistant."
    
    /// Initialize configuration from command line arguments and environment
    init(
        systemInstructions: String? = nil,
        debug: Bool = false,
        serverName: String = "mcp-foundation-models",
        serverVersion: String = "1.0.0"
    ) {
        self.isDebugEnabled = debug || ProcessInfo.processInfo.environment["DEBUG"] != nil
        self.systemInstructions = systemInstructions 
            ?? ProcessInfo.processInfo.environment["SYSTEM_INSTRUCTIONS"] 
            ?? Self.defaultSystemInstructions
        self.serverName = serverName
        self.serverVersion = serverVersion
    }
}

/// Generation parameters for Foundation Models
struct GenerationParameters {
    let prompt: String
    let temperature: Double
    let maxTokens: Int?
    
    static let defaultTemperature: Double = 0.7
    static let temperatureRange: ClosedRange<Double> = 0.0...1.0
    
    init(prompt: String, temperature: Double? = nil, maxTokens: Int? = nil) {
        self.prompt = prompt
        self.temperature = temperature ?? Self.defaultTemperature
        self.maxTokens = maxTokens
    }
    
    /// Validate parameters
    func validate() throws {
        guard !prompt.isEmpty else {
            throw ServerError.invalidParameter("Prompt cannot be empty")
        }
        
        guard Self.temperatureRange.contains(temperature) else {
            throw ServerError.invalidParameter("Temperature must be between \(Self.temperatureRange.lowerBound) and \(Self.temperatureRange.upperBound)")
        }
        
        if let maxTokens = maxTokens, maxTokens <= 0 {
            throw ServerError.invalidParameter("Max tokens must be positive")
        }
    }
}
