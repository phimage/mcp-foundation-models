import Foundation
import FoundationModels
import Logging

/// Protocol for text generation services
protocol TextGenerationService {
    func generateText(with parameters: GenerationParameters) async throws -> String
}

/// Foundation Models implementation of text generation
class FoundationModelsService: TextGenerationService {
    private let systemInstructions: String
    private let logger: Logger
    
    init(systemInstructions: String, logger: Logger) {
        self.systemInstructions = systemInstructions
        self.logger = logger
    }
    
    func generateText(with parameters: GenerationParameters) async throws -> String {
        // Validate parameters
        try parameters.validate()
        
        logger.debug("Processing request - prompt length: \(parameters.prompt.count), temperature: \(parameters.temperature), maxTokens: \(String(describing: parameters.maxTokens))")
        
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
        let options = GenerationOptions(
            sampling: nil,
            temperature: parameters.temperature,
            maximumResponseTokens: parameters.maxTokens
        )
        
        do {
            logger.debug("Generating response with FoundationModels...")
            let response = try await session.respond(to: parameters.prompt, options: options)
            logger.debug("Generated response with \(response.content.count) characters")
            return response.content
        } catch {
            logger.error("Failed to generate text: \(error.localizedDescription)")
            throw ServerError.generationFailed(error.localizedDescription)
        }
    }
}
