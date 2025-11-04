import Foundation

// MARK: - AI Question Generator
class AIQuestionGenerator: ObservableObject {
    static let shared = AIQuestionGenerator()
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        // Get API key from environment variable or use hardcoded for development
        let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        if !envKey.isEmpty {
            self.apiKey = envKey
            print("🔧 Using environment API key")
        } else {
            // No API key found. Configure via environment or secure storage.
            self.apiKey = ""
            print("❗️ No OPENAI_API_KEY found in environment. Configure your API key.")
        }
        
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
            
            // Check if it's a quota error and provide helpful message
            if let apiError = error as? AIError, case .apiError(let errorMessage) = apiError {
                if errorMessage.contains("insufficient_quota") {
                    print("⚠️ OpenAI quota exceeded. Using mock questions instead.")
                }
            }
            
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
        let difficultyText = difficulty.rawValue.capitalized
        let ageText = "ages \(ageRange.min)-\(ageRange.max)"
        
        return """
        Create exactly \(count) educational quiz questions about \(topic) for children \(ageText) at \(difficultyText) level.
        
        IMPORTANT: Return ONLY the questions in this exact format. Do not include any other text, explanations, or formatting.
        
        Format each question exactly like this:
        
        Q: What is the capital of France?
        A: London
        A: Berlin  
        A: Paris
        A: Madrid
        Correct: 3
        Explanation: Paris is the capital city of France.
        
        Q: What color do you get when you mix red and blue?
        A: Green
        A: Purple
        A: Orange
        A: Yellow
        Correct: 2
        Explanation: When you mix red and blue paint, you get purple.
        
        Continue this format for all \(count) questions. Make sure each question is appropriate for \(ageText) children and \(difficultyText) difficulty level.
        """
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
        if content.contains("Create exactly \(count) educational quiz questions") {
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
                // Handle both number format (Correct: 3) and text format (Correct: Paris)
                if let correctNumber = Int(correctText) {
                    currentCorrectAnswer = correctNumber - 1 // Convert to 0-based index
                } else {
                    currentCorrectAnswer = currentOptions.firstIndex(of: correctText) ?? 0
                }
                
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
        
        let mockQuestions = getMockQuestionsForTopic(topic, difficulty: difficulty, ageRange: ageRange)
        
        for i in 0..<count {
            let mockIndex = i % mockQuestions.count
            let mockQuestion = mockQuestions[mockIndex]
            
            let question = Question(
                id: "mock_\(topic)_\(difficulty.rawValue)_\(ageRange.min)_\(ageRange.max)_\(i)_\(Date().timeIntervalSince1970)_\(UUID().uuidString.prefix(8))",
                text: mockQuestion.text,
                options: mockQuestion.options,
                correctAnswer: mockQuestion.correctAnswer,
                explanation: mockQuestion.explanation,
                difficulty: difficulty
            )
            questions.append(question)
        }
        
        return questions
    }
    
    private func getMockQuestionsForTopic(_ topic: String, difficulty: Difficulty, ageRange: AgeRange) -> [Question] {
        let uniqueId = UUID().uuidString.prefix(8)
        switch topic.lowercased() {
        case "math":
            return [
                Question(id: "mock_math_1_\(uniqueId)", text: "What is 5 + 3?", options: ["6", "7", "8", "9"], correctAnswer: 2, explanation: "5 + 3 equals 8.", difficulty: .easy),
                Question(id: "mock_math_2_\(uniqueId)", text: "What is 10 - 4?", options: ["5", "6", "7", "8"], correctAnswer: 1, explanation: "10 - 4 equals 6.", difficulty: .easy),
                Question(id: "mock_math_3_\(uniqueId)", text: "What is 2 × 3?", options: ["4", "5", "6", "7"], correctAnswer: 2, explanation: "2 × 3 equals 6.", difficulty: .easy)
            ]
        case "science":
            return [
                Question(id: "mock_science_1_\(uniqueId)", text: "What do plants need to grow?", options: ["Water only", "Sunlight only", "Water and sunlight", "Nothing"], correctAnswer: 2, explanation: "Plants need both water and sunlight to grow.", difficulty: .easy),
                Question(id: "mock_science_2_\(uniqueId)", text: "What is the largest planet in our solar system?", options: ["Earth", "Mars", "Jupiter", "Saturn"], correctAnswer: 2, explanation: "Jupiter is the largest planet in our solar system.", difficulty: .medium)
            ]
        case "reading":
            return [
                Question(id: "mock_reading_1_\(uniqueId)", text: "What is the opposite of 'happy'?", options: ["Sad", "Angry", "Excited", "Tired"], correctAnswer: 0, explanation: "The opposite of 'happy' is 'sad'.", difficulty: .easy),
                Question(id: "mock_reading_2_\(uniqueId)", text: "What do we call a person who writes books?", options: ["Artist", "Author", "Actor", "Singer"], correctAnswer: 1, explanation: "A person who writes books is called an author.", difficulty: .easy)
            ]
        default:
            return [
                Question(id: "mock_general_1_\(uniqueId)", text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswer: 2, explanation: "Paris is the capital of France.", difficulty: .easy),
                Question(id: "mock_general_2_\(uniqueId)", text: "What color do you get when you mix red and blue?", options: ["Green", "Purple", "Orange", "Yellow"], correctAnswer: 1, explanation: "When you mix red and blue, you get purple.", difficulty: .easy)
            ]
        }
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