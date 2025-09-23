import Foundation

// MARK: - AI Question Generator
class AIQuestionGenerator: ObservableObject {
    static let shared = AIQuestionGenerator()
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        // Get API key from environment variable
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        
        print("🔧 AIQuestionGenerator initialized with API key: \(self.apiKey.isEmpty ? "EMPTY" : "FOUND")")
    }
    
    // MARK: - Question Generation
    func generateQuestions(
        for topic: String,
        difficulty: Difficulty,
        ageRange: AgeRange,
        count: Int = 5
    ) async throws -> [Question] {
        print("🚀 STARTING generateQuestions function")
        print("📋 Topic: \(topic)")
        print("📋 Count: \(count)")
        
        guard !apiKey.isEmpty else {
            print("❌ API Key is empty!")
            throw AIError.missingAPIKey
        }
        
        print("🔑 API Key found: \(apiKey.prefix(10))...")
        
        let prompt = createPrompt(for: topic, difficulty: difficulty, ageRange: ageRange, count: count)
        print("📝 Sending prompt to OpenAI: \(prompt)")
        print("📝 Prompt length: \(prompt.count) characters")
        print("📝 Full prompt content:")
        print(prompt)
        print("📝 End of prompt")
        
        do {
            let response = try await callOpenAIAPI(prompt: prompt)
            let questions = try parseAIResponse(response, count: count)
            
            // Filter for child safety
            let safeQuestions = questions.filter { question in
                validateContentForChildren(question.text, age: ageRange.min) &&
                validateContentForChildren(question.explanation, age: ageRange.min)
            }
            
            // Adjust language for age appropriateness
            let adjustedQuestions = safeQuestions.map { question in
                var adjustedQuestion = question
                adjustedQuestion.text = adjustLanguageForAge(question.text, age: ageRange.min)
                adjustedQuestion.explanation = adjustLanguageForAge(question.explanation, age: ageRange.min)
                return adjustedQuestion
            }
            
            return adjustedQuestions
        } catch {
            // Fallback to mock questions if API fails
            print("OpenAI API failed, using mock questions: \(error)")
            return try await generateMockQuestions(for: topic, difficulty: difficulty, ageRange: ageRange, count: count)
        }
    }
    
    // MARK: - Content Safety & Filtering
    func validateContentForChildren(_ content: String, age: Int) -> Bool {
        // Implement child-safe content validation
        let inappropriateWords = [
            "violence", "weapon", "danger", "scary", "frightening",
            "inappropriate", "adult", "mature", "explicit"
        ]
        
        let lowercasedContent = content.lowercased()
        for word in inappropriateWords {
            if lowercasedContent.contains(word) {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Age-Appropriate Language
    func adjustLanguageForAge(_ content: String, age: Int) -> String {
        var adjustedContent = content
        
        if age < 8 {
            // Simplify language for younger children
            adjustedContent = content.replacingOccurrences(of: "utilize", with: "use")
            adjustedContent = adjustedContent.replacingOccurrences(of: "demonstrate", with: "show")
            adjustedContent = adjustedContent.replacingOccurrences(of: "consequently", with: "so")
        } else if age < 12 {
            // Moderate complexity for middle age group
            adjustedContent = content.replacingOccurrences(of: "utilize", with: "use")
        }
        // For 12+, keep original language
        
        return adjustedContent
    }
    
    // MARK: - Difficulty Adjustment
    func adjustDifficulty(_ question: Question, for difficulty: Difficulty) -> Question {
        var adjustedQuestion = question
        
        switch difficulty {
        case .easy:
            // Simplify language and concepts
            adjustedQuestion.text = simplifiedLanguage(question.text)
            adjustedQuestion.explanation = simplifiedLanguage(question.explanation)
        case .medium:
            // Keep moderate complexity
            break
        case .hard:
            // Add more complex concepts and vocabulary
            adjustedQuestion.text = enhancedLanguage(question.text)
            adjustedQuestion.explanation = enhancedLanguage(question.explanation)
        }
        
        return adjustedQuestion
    }
    
    // MARK: - Topic Expansion
    func expandTopic(_ topic: String, for age: Int) -> [String] {
        // Use AI to suggest related sub-topics or learning paths
        // For now, mock suggestions
        if topic.lowercased().contains("math") {
            return ["addition", "subtraction", "multiplication", "division"]
        } else if topic.lowercased().contains("science") {
            return ["animals", "plants", "space", "weather"]
        }
        return []
    }
    
    // MARK: - Private Methods
    
    private func createPrompt(
        for topic: String,
        difficulty: Difficulty,
        ageRange: AgeRange,
        count: Int
    ) -> String {
        // Simple hardcoded prompt for testing
        return "Create 5 quiz questions about \(topic) for kids. Format: Q: [question] A: [option1] A: [option2] A: [option3] A: [option4] Correct: [correct] Explanation: [explanation]"
    }
    
    private func simplifiedLanguage(_ text: String) -> String {
        // Mock simplification - in production, use AI for this
        return text.replacingOccurrences(of: "utilize", with: "use")
                  .replacingOccurrences(of: "demonstrate", with: "show")
                  .replacingOccurrences(of: "consequently", with: "so")
    }
    
    private func enhancedLanguage(_ text: String) -> String {
        // Mock enhancement - in production, use AI for this
        return text.replacingOccurrences(of: "use", with: "utilize")
                  .replacingOccurrences(of: "show", with: "demonstrate")
                  .replacingOccurrences(of: "so", with: "consequently")
    }
    
    // MARK: - OpenAI API Implementation
    private func callOpenAIAPI(prompt: String) async throws -> OpenAIResponse {
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                OpenAIMessage(role: "system", content: "You are an educational AI that creates child-safe quiz questions. Always ensure content is appropriate for children and educational."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            max_tokens: 2000,
            temperature: 0.7
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.apiError("Invalid response from OpenAI API")
        }
        
        print("🌐 HTTP Status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API Error: \(errorString)")
            throw AIError.apiError("OpenAI API error: \(errorString)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("📦 Raw API Response: \(responseString)")
        
        return try JSONDecoder().decode(OpenAIResponse.self, from: data)
    }
    
    private func parseAIResponse(_ response: OpenAIResponse, count: Int) throws -> [Question] {
        guard let content = response.choices.first?.message.content else {
            throw AIError.parsingError
        }
        
        // Debug: Print what the AI returned
        print("🤖 AI Response: \(content)")
        print("🤖 AI Response Length: \(content.count) characters")
        
        // Check if the AI is just returning the prompt
        if content.contains("Create \(count) multiple choice questions") {
            print("⚠️ AI is returning the prompt instead of generating questions!")
            throw AIError.parsingError
        }
        
        // Parse the AI response to extract questions
        // This is a simplified parser - you might want to make it more robust
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var questions: [Question] = []
        
        var currentQuestion: String = ""
        var currentOptions: [String] = []
        var currentCorrectAnswer: Int = 0
        var currentExplanation: String = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("Q:") {
                // Save previous question if we have one
                if !currentQuestion.isEmpty && currentOptions.count == 4 {
                    let question = Question(
                        id: UUID().uuidString,
                        text: currentQuestion,
                        options: currentOptions,
                        correctAnswer: currentCorrectAnswer,
                        explanation: currentExplanation,
                        difficulty: .medium
                    )
                    questions.append(question)
                }
                
                // Start new question
                currentQuestion = trimmedLine.replacingOccurrences(of: "Q:", with: "").trimmingCharacters(in: .whitespaces)
                currentOptions = []
                currentExplanation = ""
                
            } else if trimmedLine.hasPrefix("A:") {
                let option = trimmedLine.replacingOccurrences(of: "A:", with: "").trimmingCharacters(in: .whitespaces)
                if !option.isEmpty {
                    currentOptions.append(option)
                }
                
            } else if trimmedLine.hasPrefix("Correct:") {
                let correctText = trimmedLine.replacingOccurrences(of: "Correct:", with: "").trimmingCharacters(in: .whitespaces)
                currentCorrectAnswer = currentOptions.firstIndex(of: correctText) ?? 0
                
            } else if trimmedLine.hasPrefix("Explanation:") {
                currentExplanation = trimmedLine.replacingOccurrences(of: "Explanation:", with: "").trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Add the last question
        if !currentQuestion.isEmpty && !currentOptions.isEmpty {
            let question = Question(
                id: UUID().uuidString,
                text: currentQuestion,
                options: currentOptions,
                correctAnswer: currentCorrectAnswer,
                explanation: currentExplanation,
                difficulty: .medium
            )
            questions.append(question)
        }
        
        let finalQuestions = Array(questions.prefix(count))
        
        // If we didn't get any valid questions, fall back to mock
        if finalQuestions.isEmpty {
            print("⚠️ No valid questions parsed from AI response, using fallback")
            throw AIError.parsingError
        }
        
        print("✅ Successfully parsed \(finalQuestions.count) questions from AI")
        return finalQuestions
    }
    
    private func generateMockQuestions(
        for topic: String,
        difficulty: Difficulty,
        ageRange: AgeRange,
        count: Int
    ) async throws -> [Question] {
        // Fallback mock implementation
        var questions: [Question] = []
        
        for i in 0..<count {
            let questionText = "What is a \(topic) related question number \(i + 1) for a \(ageRange.min)-\(ageRange.max) year old at \(difficulty) difficulty?"
            let options = ["Option A", "Option B", "Option C", "Option D"]
            let correctAnswer = Int.random(in: 0..<4)
            let explanation = "This is the explanation for question \(i + 1) about \(topic)."
            
            let question = Question(
                id: UUID().uuidString,
                text: questionText,
                options: options,
                correctAnswer: correctAnswer,
                explanation: explanation,
                difficulty: difficulty
            )
            questions.append(question)
        }
        
        return questions
    }
}

// MARK: - OpenAI API Data Structures
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let max_tokens: Int
    let temperature: Double
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

// MARK: - AI Error Types
enum AIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case apiError(String)
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Please set OPENAI_API_KEY environment variable."
        case .invalidURL:
            return "Invalid API URL"
        case .apiError(let message):
            return "API Error: \(message)"
        case .parsingError:
            return "Failed to parse AI response"
        }
    }
}