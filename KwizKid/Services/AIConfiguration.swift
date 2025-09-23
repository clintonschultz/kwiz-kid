import Foundation

// MARK: - AI Configuration Manager
class AIConfiguration: ObservableObject {
    static let shared = AIConfiguration()
    
    @Published var currentProvider: AIProviderType = .openAI
    @Published var isConfigured: Bool = false
    
    private init() {}
    
    // MARK: - Provider Selection
    func setProvider(_ provider: AIProviderType) {
        currentProvider = provider
        isConfigured = true
    }
    
    // MARK: - API Key Management
    func saveAPIKey(_ key: String, for provider: AIProviderType) {
        // Securely save API key (e.g., using Keychain)
        print("Saving API key for \(provider): \(key)")
        // For now, just set configured status
        isConfigured = true
    }
    
    func getAPIKey(for provider: AIProviderType) -> String? {
        // Retrieve API key from secure storage
        print("Retrieving API key for \(provider)")
        return "MOCK_API_KEY" // Placeholder
    }
    
    // MARK: - Connection Testing
    func testConnection(for provider: AIProviderType) async throws -> Bool {
        print("Testing connection for \(provider)...")
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network call
        // In a real app, this would make a small API call to the provider
        return true
    }
    
    // MARK: - Content Moderation Settings
    func setContentModerationLevel(_ level: ContentModerationLevel) {
        print("Setting content moderation level to: \(level)")
    }
    
    func getContentModerationLevel() -> ContentModerationLevel {
        return .strict // Placeholder
    }
}

// MARK: - AI Provider Types
enum AIProviderType: String, CaseIterable, Identifiable {
    case openAI = "OpenAI GPT"
    case claude = "Anthropic Claude"
    case bedrock = "AWS Bedrock"
    case mock = "Mock Provider (Development)"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .openAI:
            return "OpenAI's GPT models for question generation"
        case .claude:
            return "Anthropic's Claude for advanced reasoning"
        case .bedrock:
            return "AWS Bedrock for enterprise AI"
        case .mock:
            return "Mock provider for development and testing"
        }
    }
}

enum ContentModerationLevel: String, CaseIterable, Identifiable {
    case lenient = "Lenient"
    case moderate = "Moderate"
    case strict = "Strict"
    
    var id: String { self.rawValue }
}