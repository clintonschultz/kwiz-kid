import Foundation

// MARK: - AI Configuration Manager
class AIConfiguration: ObservableObject {
    static let shared = AIConfiguration()
    
    @Published var currentProvider: AIProviderType = .mock
    @Published var isConfigured: Bool = false
    
    private init() {}
    
    // MARK: - Provider Selection
    func setProvider(_ provider: AIProviderType) {
        currentProvider = provider
        isConfigured = true
    }
    
    func getProvider() -> AIProvider {
        switch currentProvider {
        case .openAI:
            return OpenAIProvider()
        case .claude:
            return ClaudeProvider()
        case .awsBedrock:
            return AWSBedrockProvider()
        case .mock:
            return MockAIProvider()
        }
    }
    
    // MARK: - Configuration Validation
    func validateConfiguration() -> Bool {
        switch currentProvider {
        case .openAI:
            return validateOpenAIConfig()
        case .claude:
            return validateClaudeConfig()
        case .awsBedrock:
            return validateAWSConfig()
        case .mock:
            return true
        }
    }
    
    private func validateOpenAIConfig() -> Bool {
        // Check if OpenAI API key is configured
        return ((UserDefaults.standard.string(forKey: "openai_api_key")?.isEmpty) == nil)
    }
    
    private func validateClaudeConfig() -> Bool {
        // Check if Claude API key is configured
        return ((UserDefaults.standard.string(forKey: "claude_api_key")?.isEmpty) == nil)
    }
    
    private func validateAWSConfig() -> Bool {
        // Check if AWS credentials are configured
        return ((UserDefaults.standard.string(forKey: "aws_access_key")?.isEmpty) == nil)
    }
}

// MARK: - AI Provider Types
enum AIProviderType: String, CaseIterable {
    case openAI = "openai"
    case claude = "claude"
    case awsBedrock = "aws_bedrock"
    case mock = "mock"
    
    var displayName: String {
        switch self {
        case .openAI:
            return "OpenAI GPT"
        case .claude:
            return "Anthropic Claude"
        case .awsBedrock:
            return "AWS Bedrock"
        case .mock:
            return "Mock (Development)"
        }
    }
    
    var description: String {
        switch self {
        case .openAI:
            return "Fast and reliable question generation with GPT models"
        case .claude:
            return "High-quality, safe content generation with Claude"
        case .awsBedrock:
            return "Enterprise-grade AI with AWS Bedrock"
        case .mock:
            return "Local mock responses for development and testing"
        }
    }
}

// MARK: - Mock AI Provider for Development
class MockAIProvider: AIProvider {
    func generateQuestions(prompt: String) async throws -> [Question] {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return generateMockQuestions()
    }
    
    func validateContent(_ content: String) async throws -> Bool {
        // Mock validation - always returns true
        return true
    }
    
    func adjustLanguage(_ content: String, for age: Int) async throws -> String {
        // Mock language adjustment
        return content
    }
    
    private func generateMockQuestions() -> [Question] {
        return [
            Question(
                id: UUID().uuidString,
                text: "What is the capital of France?",
                options: ["London", "Paris", "Berlin", "Madrid"],
                correctAnswer: 1,
                explanation: "Paris is the capital city of France! It's famous for the Eiffel Tower.",
                difficulty: .easy
            ),
            Question(
                id: UUID().uuidString,
                text: "How many legs does a spider have?",
                options: ["6", "8", "10", "12"],
                correctAnswer: 1,
                explanation: "Spiders have 8 legs! They are arachnids, not insects.",
                difficulty: .easy
            ),
            Question(
                id: UUID().uuidString,
                text: "What do bees make?",
                options: ["Milk", "Honey", "Butter", "Cheese"],
                correctAnswer: 1,
                explanation: "Bees make honey! They collect nectar from flowers and turn it into honey.",
                difficulty: .easy
            ),
            Question(
                id: UUID().uuidString,
                text: "What color is the sun?",
                options: ["Yellow", "White", "Orange", "Red"],
                correctAnswer: 1,
                explanation: "The sun is actually white! It looks yellow from Earth because of our atmosphere.",
                difficulty: .medium
            ),
            Question(
                id: UUID().uuidString,
                text: "How many days are in a week?",
                options: ["5", "6", "7", "8"],
                correctAnswer: 2,
                explanation: "There are 7 days in a week: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, and Sunday!",
                difficulty: .easy
            )
        ]
    }
}

// MARK: - AI Settings View Model
class AISettingsViewModel: ObservableObject {
    @Published var selectedProvider: AIProviderType = .mock
    @Published var openAIKey: String = ""
    @Published var claudeKey: String = ""
    @Published var awsAccessKey: String = ""
    @Published var awsSecretKey: String = ""
    @Published var awsRegion: String = "us-east-1"
    
    @Published var isGeneratingQuestions: Bool = false
    @Published var lastGenerationTime: TimeInterval = 0
    @Published var questionsGenerated: Int = 0
    
    private let aiConfig = AIConfiguration.shared
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        UserDefaults.standard.set(selectedProvider.rawValue, forKey: "ai_provider")
        UserDefaults.standard.set(openAIKey, forKey: "openai_api_key")
        UserDefaults.standard.set(claudeKey, forKey: "claude_api_key")
        UserDefaults.standard.set(awsAccessKey, forKey: "aws_access_key")
        UserDefaults.standard.set(awsSecretKey, forKey: "aws_secret_key")
        UserDefaults.standard.set(awsRegion, forKey: "aws_region")
        
        aiConfig.setProvider(selectedProvider)
    }
    
    func testConnection() async -> Bool {
        do {
            let provider = aiConfig.getProvider()
            let questions = try await provider.generateQuestions(prompt: "Generate 1 test question about animals")
            return !questions.isEmpty
        } catch {
            return false
        }
    }
    
    func generateTestQuestions() async {
        isGeneratingQuestions = true
        let startTime = Date()
        
        do {
            let provider = aiConfig.getProvider()
            let questions = try await provider.generateQuestions(prompt: "Generate 5 test questions about science")
            
            questionsGenerated = questions.count
            lastGenerationTime = Date().timeIntervalSince(startTime)
        } catch {
            print("Error generating test questions: \(error)")
        }
        
        isGeneratingQuestions = false
    }
    
    private func loadSettings() {
        selectedProvider = AIProviderType(rawValue: UserDefaults.standard.string(forKey: "ai_provider") ?? "mock") ?? .mock
        openAIKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        claudeKey = UserDefaults.standard.string(forKey: "claude_api_key") ?? ""
        awsAccessKey = UserDefaults.standard.string(forKey: "aws_access_key") ?? ""
        awsSecretKey = UserDefaults.standard.string(forKey: "aws_secret_key") ?? ""
        awsRegion = UserDefaults.standard.string(forKey: "aws_region") ?? "us-east-1"
    }
}

// MARK: - AI Analytics
struct AIAnalytics {
    let questionsGenerated: Int
    let averageGenerationTime: TimeInterval
    let successRate: Double
    let mostUsedProvider: AIProviderType
    let contentSafetyScore: Double
    let ageAppropriateScore: Double
}

// MARK: - AI Content Moderation
class AIContentModerator: ObservableObject {
    static let shared = AIContentModerator()
    
    private init() {}
    
    func moderateContent(_ content: String, for age: Int) -> ModerationResult {
        // Implement content moderation logic
        let inappropriateWords = [
            "violence", "weapon", "danger", "scary", "frightening",
            "inappropriate", "adult", "mature", "explicit", "harmful"
        ]
        
        let lowercasedContent = content.lowercased()
        let foundWords = inappropriateWords.filter { word in
            lowercasedContent.contains(word)
        }
        
        if !foundWords.isEmpty {
            return ModerationResult(
                isApproved: false,
                reason: "Content contains inappropriate words: \(foundWords.joined(separator: ", "))",
                confidence: 0.9
            )
        }
        
        // Check age appropriateness
        let ageScore = calculateAgeAppropriateness(content, for: age)
        if ageScore < 0.7 {
            return ModerationResult(
                isApproved: false,
                reason: "Content may not be appropriate for age \(age)",
                confidence: ageScore
            )
        }
        
        return ModerationResult(
            isApproved: true,
            reason: "Content is appropriate",
            confidence: ageScore
        )
    }
    
    private func calculateAgeAppropriateness(_ content: String, for age: Int) -> Double {
        // Simple heuristic for age appropriateness
        let complexWords = content.components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 8 }
        
        let complexityScore = Double(complexWords.count) / Double(content.components(separatedBy: .whitespacesAndNewlines).count)
        
        switch age {
        case 0..<6:
            return complexityScore < 0.1 ? 1.0 : 0.5
        case 6..<10:
            return complexityScore < 0.2 ? 1.0 : 0.7
        case 10..<14:
            return complexityScore < 0.3 ? 1.0 : 0.8
        default:
            return 1.0
        }
    }
}

// MARK: - Moderation Result
struct ModerationResult {
    let isApproved: Bool
    let reason: String
    let confidence: Double
}
