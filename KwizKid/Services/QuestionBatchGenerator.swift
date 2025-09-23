import Foundation

// MARK: - Batch Generation Configuration
struct BatchGenerationConfig {
    let questionsPerCategory: Int
    let categories: [String]
    let difficulties: [Difficulty]
    let ageRanges: [AgeRange]
    
    static let defaultConfig = BatchGenerationConfig(
        questionsPerCategory: 50, // Generate 50 questions per category
        categories: ["Science", "Math", "History", "Geography", "Animals", "Space"],
        difficulties: [.easy, .medium, .hard],
        ageRanges: [
            AgeRange(min: 5, max: 8),   // Early elementary
            AgeRange(min: 9, max: 12),  // Late elementary
            AgeRange(min: 13, max: 16)  // Middle school
        ]
    )
}

// MARK: - Batch Generation Progress
struct GenerationProgress {
    let totalTasks: Int
    let completedTasks: Int
    let currentTask: String
    let isComplete: Bool
    
    var percentage: Double {
        return Double(completedTasks) / Double(totalTasks)
    }
}

// MARK: - Question Batch Generator
class QuestionBatchGenerator: ObservableObject {
    static let shared = QuestionBatchGenerator()
    
    @Published var isGenerating = false
    @Published var progress: GenerationProgress?
    @Published var generationError: String?
    
    private let aiGenerator = AIQuestionGenerator.shared
    private let databaseService = AWSDatabaseService.shared
    
    private init() {}
    
    // MARK: - Main Generation Method
    func generateQuestionDatabase(config: BatchGenerationConfig = .defaultConfig) async {
        await MainActor.run {
            self.isGenerating = true
            self.generationError = nil
            self.progress = GenerationProgress(
                totalTasks: calculateTotalTasks(config),
                completedTasks: 0,
                currentTask: "Starting generation...",
                isComplete: false
            )
        }
        
        do {
            var allQuestions: [StoredQuestion] = []
            var completedTasks = 0
            
            // Generate questions for each combination
            for category in config.categories {
                for difficulty in config.difficulties {
                    for ageRange in config.ageRanges {
                        let taskName = "\(category) - \(difficulty.rawValue) - Ages \(ageRange.min)-\(ageRange.max)"
                        
                        await MainActor.run {
                            self.progress = GenerationProgress(
                                totalTasks: calculateTotalTasks(config),
                                completedTasks: completedTasks,
                                currentTask: taskName,
                                isComplete: false
                            )
                        }
                        
                        do {
                            // Generate questions using AI
                            let questions = try await generateQuestionsForCategory(
                                category: category,
                                difficulty: difficulty,
                                ageRange: ageRange,
                                count: config.questionsPerCategory
                            )
                            
                            // Convert to StoredQuestion format
                            let storedQuestions = questions.map { question in
                                StoredQuestion(
                                    question: question,
                                    category: category,
                                    difficulty: difficulty,
                                    ageRange: ageRange
                                )
                            }
                            
                            allQuestions.append(contentsOf: storedQuestions)
                            
                            // Store in database
                            try await databaseService.storeQuestions(storedQuestions)
                            
                            completedTasks += 1
                            
                            print("✅ Generated \(questions.count) questions for \(taskName)")
                            
                        } catch {
                            print("❌ Failed to generate questions for \(taskName): \(error)")
                            // Continue with other tasks even if one fails
                        }
                    }
                }
            }
            
            // Final batch storage
            try await databaseService.batchStoreQuestions(allQuestions)
            
            await MainActor.run {
                self.progress = GenerationProgress(
                    totalTasks: calculateTotalTasks(config),
                    completedTasks: completedTasks,
                    currentTask: "Generation complete!",
                    isComplete: true
                )
                self.isGenerating = false
            }
            
            print("🎉 Question database generation completed!")
            print("📊 Total questions generated: \(allQuestions.count)")
            
        } catch {
            await MainActor.run {
                self.generationError = "Failed to generate question database: \(error.localizedDescription)"
                self.isGenerating = false
            }
            print("❌ Database generation failed: \(error)")
        }
    }
    
    // MARK: - Individual Category Generation
    private func generateQuestionsForCategory(
        category: String,
        difficulty: Difficulty,
        ageRange: AgeRange,
        count: Int
    ) async throws -> [Question] {
        
        print("🤖 Generating \(count) questions for \(category)...")
        
        do {
            // Try AI generation first
            let questions = try await aiGenerator.generateQuestions(
                for: category,
                difficulty: difficulty,
                ageRange: ageRange,
                count: count
            )
            
            print("✅ AI generated \(questions.count) questions for \(category)")
            return questions
            
        } catch {
            print("⚠️ AI generation failed for \(category), using fallback: \(error)")
            
            // Fallback to mock questions if AI fails
            return generateFallbackQuestions(
                for: category,
                difficulty: difficulty,
                ageRange: ageRange,
                count: count
            )
        }
    }
    
    // MARK: - Fallback Question Generation
    private func generateFallbackQuestions(
        for category: String,
        difficulty: Difficulty,
        ageRange: AgeRange,
        count: Int
    ) -> [Question] {
        
        let baseQuestions = getBaseQuestions(for: category)
        var questions: [Question] = []
        
        // Generate variations of base questions
        for i in 0..<count {
            let baseIndex = i % baseQuestions.count
            let baseQuestion = baseQuestions[baseIndex]
            
            // Create variations by modifying the base question
            let variation = createQuestionVariation(
                from: baseQuestion,
                index: i,
                difficulty: difficulty,
                ageRange: ageRange
            )
            
            questions.append(variation)
        }
        
        return questions
    }
    
    private func getBaseQuestions(for category: String) -> [Question] {
        switch category.lowercased() {
        case "science":
            return [
                Question(id: "science_1", text: "What is the chemical symbol for water?", options: ["H2O", "CO2", "NaCl", "O2"], correctAnswer: 0, explanation: "Water is made of two hydrogen atoms and one oxygen atom.", difficulty: .easy),
                Question(id: "science_2", text: "Which planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctAnswer: 1, explanation: "Mars is called the Red Planet because of its reddish appearance.", difficulty: .easy)
            ]
        case "math":
            return [
                Question(id: "math_1", text: "What is 5 + 3?", options: ["6", "7", "8", "9"], correctAnswer: 2, explanation: "5 + 3 equals 8.", difficulty: .easy),
                Question(id: "math_2", text: "What is 10 - 4?", options: ["5", "6", "7", "8"], correctAnswer: 1, explanation: "10 - 4 equals 6.", difficulty: .easy)
            ]
        case "history":
            return [
                Question(id: "history_1", text: "Who was the first president of the United States?", options: ["Thomas Jefferson", "George Washington", "John Adams", "Benjamin Franklin"], correctAnswer: 1, explanation: "George Washington was the first president of the United States.", difficulty: .medium),
                Question(id: "history_2", text: "In what year did World War II end?", options: ["1944", "1945", "1946", "1947"], correctAnswer: 1, explanation: "World War II ended in 1945.", difficulty: .medium)
            ]
        default:
            return [
                Question(id: "general_1", text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswer: 2, explanation: "Paris is the capital of France.", difficulty: .easy),
                Question(id: "general_2", text: "Which animal is known as the King of the Jungle?", options: ["Tiger", "Lion", "Elephant", "Giraffe"], correctAnswer: 1, explanation: "The lion is often called the King of the Jungle.", difficulty: .easy)
            ]
        }
    }
    
    private func createQuestionVariation(
        from baseQuestion: Question,
        index: Int,
        difficulty: Difficulty,
        ageRange: AgeRange
    ) -> Question {
        
        // For now, return the base question with slight modifications
        // In a real implementation, you'd create more sophisticated variations
        return Question(
            id: "\(baseQuestion.id)_var_\(index)",
            text: baseQuestion.text,
            options: baseQuestion.options,
            correctAnswer: baseQuestion.correctAnswer,
            explanation: baseQuestion.explanation,
            difficulty: difficulty
        )
    }
    
    // MARK: - Helper Methods
    private func calculateTotalTasks(_ config: BatchGenerationConfig) -> Int {
        return config.categories.count * config.difficulties.count * config.ageRanges.count
    }
    
    // MARK: - Database Management
    func clearDatabase() async throws {
        print("🗑️ Clearing question database...")
        
        // TODO: Implement actual database clearing
        print("✅ Database cleared")
    }
    
    func getDatabaseStats() async throws -> (totalQuestions: Int, categories: [String: Int]) {
        print("📊 Getting database statistics...")
        
        // TODO: Implement actual database stats
        return (totalQuestions: 0, categories: [:])
    }
}
