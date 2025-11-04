import Foundation

// MARK: - Quiz Content Service
class QuizContentService: ObservableObject {
    static let shared = QuizContentService()
    private let cloudService = CloudQuestionService.shared
    private let database = QuestionDatabase.shared
    private let aiGenerator = AIQuestionGenerator.shared
    
    private init() {}
    
    // MARK: - Cloud-First Question Retrieval
    func generateQuestions(for category: QuizCategory, count: Int = 5) async throws -> [Question] {
        print("🌐 Attempting to fetch questions from cloud...")
        
        // Try cloud service first (with local fallback)
        let questions = await cloudService.fetchQuestionsWithFallback(
            category: category.id,
            difficulty: category.difficulty,
            ageRange: category.ageRange,
            includeImages: false,
            limit: count
        )
        
        if !questions.isEmpty {
            print("✅ Retrieved \(questions.count) questions from cloud/local")
            return questions
        } else {
            print("⚠️ No questions found, falling back to AI generation")
            return try await generateQuestionsWithAI(for: category, count: count)
        }
    }
    
    // MARK: - AI Fallback Generation
    private func generateQuestionsWithAI(for category: QuizCategory, count: Int) async throws -> [Question] {
        print("🤖 Using AI to generate questions as fallback...")
        
        let topic = getTopicForCategory(category)
        let questions = try await aiGenerator.generateQuestions(
            for: topic,
            difficulty: category.difficulty,
            ageRange: category.ageRange,
            count: count
        )
        
        // Filter and validate questions for child safety
        let safeQuestions = questions.filter { question in
            aiGenerator.validateContentForChildren(question.text, age: category.ageRange.min)
        }
        
        // Adjust language for age appropriateness
        let adjustedQuestions = safeQuestions.map { question in
            var adjustedQuestion = question
            adjustedQuestion.text = aiGenerator.adjustLanguageForAge(question.text, age: category.ageRange.min)
            adjustedQuestion.explanation = aiGenerator.adjustLanguageForAge(question.explanation, age: category.ageRange.min)
            return aiGenerator.adjustDifficulty(adjustedQuestion, for: category.difficulty)
        }
        
        // Store generated questions in database for future use
        Task {
            for question in adjustedQuestions {
                let questionRecord = QuestionRecord(
                    id: question.id,
                    category: category.id,
                    difficulty: category.difficulty.rawValue,
                    ageMin: category.ageRange.min,
                    ageMax: category.ageRange.max,
                    questionText: question.text,
                    options: question.options,
                    correctAnswer: question.correctAnswer,
                    explanation: question.explanation,
                    hasImage: false,
                    imagePath: nil,
                    imagePrompt: nil,
                    tags: generateTags(for: category.id),
                    createdAt: Date(),
                    isActive: true,
                    usageCount: 0
                )
                database.insertQuestion(questionRecord)
            }
            print("💾 Stored \(adjustedQuestions.count) AI-generated questions in database")
        }
        
        return adjustedQuestions
    }
    
    // MARK: - Custom Topic Questions
    func generateQuestions(for customTopic: String, difficulty: Difficulty, ageRange: AgeRange, count: Int = 5) async throws -> [Question] {
        let questions = try await aiGenerator.generateQuestions(
            for: customTopic,
            difficulty: difficulty,
            ageRange: ageRange,
            count: count
        )
        
        // Filter and validate questions for child safety
        let safeQuestions = questions.filter { question in
            aiGenerator.validateContentForChildren(question.text, age: ageRange.min)
        }
        
        // Adjust language for age appropriateness
        let adjustedQuestions = safeQuestions.map { question in
            var adjustedQuestion = question
            adjustedQuestion.text = aiGenerator.adjustLanguageForAge(question.text, age: ageRange.min)
            adjustedQuestion.explanation = aiGenerator.adjustLanguageForAge(question.explanation, age: ageRange.min)
            return aiGenerator.adjustDifficulty(adjustedQuestion, for: difficulty)
        }
        
        return adjustedQuestions
    }
    
    // MARK: - Topic Expansion
    func getRelatedTopics(for category: QuizCategory) -> [String] {
        return aiGenerator.expandTopic(category.name, for: category.ageRange.min)
    }
    
    private func getTopicForCategory(_ category: QuizCategory) -> String {
        switch category.id {
        case "math":
            return "mathematics and numbers"
        case "science":
            return "science and nature"
        case "reading":
            return "reading and language"
        case "history":
            return "history and historical events"
        case "geography":
            return "geography and world knowledge"
        case "art":
            return "art and creativity"
        default:
            return category.name
        }
    }
    
    // MARK: - Content Filtering
    func filterContentForChildren(_ content: String) -> String {
        // Implement child-safe content filtering
        // This would use AWS Comprehend or similar service
        return content
    }
    
    // MARK: - Helper Methods
    private func convertToQuestions(_ records: [QuestionRecord]) -> [Question] {
        return records.map { record in
            Question(
                id: record.id,
                text: record.questionText,
                options: record.options,
                correctAnswer: record.correctAnswer,
                explanation: record.explanation,
                difficulty: Difficulty(rawValue: record.difficulty) ?? .easy
            )
        }
    }
    
    private func generateTags(for category: String) -> [String] {
        switch category {
        case "math":
            return ["numbers", "arithmetic", "problem-solving"]
        case "science":
            return ["nature", "experiments", "discovery"]
        case "reading":
            return ["language", "comprehension", "literature"]
        case "history":
            return ["past", "events", "historical"]
        case "geography":
            return ["world", "countries", "places"]
        case "art":
            return ["creativity", "colors", "artistic"]
        default:
            return ["general", "education"]
        }
    }
}
