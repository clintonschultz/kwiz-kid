import Foundation

// MARK: - Child Safety Service
class ChildSafetyService: ObservableObject {
    static let shared = ChildSafetyService()
    
    private init() {}
    
    // MARK: - Content Filtering
    func filterContent(_ content: String) -> String {
        var filteredContent = content
        
        // Remove or replace inappropriate words
        let inappropriateWords = [
            "bad", "stupid", "dumb", "hate", "kill", "die", "dead"
        ]
        
        for word in inappropriateWords {
            filteredContent = filteredContent.replacingOccurrences(
                of: word,
                with: "***",
                options: .caseInsensitive
            )
        }
        
        return filteredContent
    }
    
    // MARK: - Age-Appropriate Content
    func isContentAppropriateForAge(_ content: String, age: Int) -> Bool {
        // Simple age-appropriate content checking
        let ageInappropriateWords = [
            "violence", "weapon", "danger", "scary", "frightening"
        ]
        
        for word in ageInappropriateWords {
            if content.lowercased().contains(word) && age < 8 {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Safe Language Generation
    func generateSafeQuestion(for category: QuizCategory, age: Int) -> String {
        let safeTemplates = getSafeTemplates(for: category, age: age)
        return safeTemplates.randomElement() ?? "What is your favorite color?"
    }
    
    private func getSafeTemplates(for category: QuizCategory, age: Int) -> [String] {
        switch category.id {
        case "math":
            return getMathTemplates(age: age)
        case "science":
            return getScienceTemplates(age: age)
        case "reading":
            return getReadingTemplates(age: age)
        case "history":
            return getHistoryTemplates(age: age)
        case "geography":
            return getGeographyTemplates(age: age)
        case "art":
            return getArtTemplates(age: age)
        default:
            return ["What is your favorite color?"]
        }
    }
    
    private func getMathTemplates(age: Int) -> [String] {
        if age < 6 {
            return [
                "How many fingers do you have?",
                "What comes after 1?",
                "How many legs does a cat have?",
                "What is 1 + 1?"
            ]
        } else if age < 10 {
            return [
                "What is 2 + 2?",
                "How many sides does a triangle have?",
                "What is 5 + 3?",
                "How many days are in a week?"
            ]
        } else {
            return [
                "What is 12 + 8?",
                "How many sides does a square have?",
                "What is 15 - 7?",
                "How many months are in a year?"
            ]
        }
    }
    
    private func getScienceTemplates(age: Int) -> [String] {
        if age < 6 {
            return [
                "What color is the sun?",
                "What do plants need to grow?",
                "What animal says 'moo'?",
                "What color is grass?"
            ]
        } else if age < 10 {
            return [
                "What planet do we live on?",
                "What do bees make?",
                "What is the largest animal in the ocean?",
                "What do plants need to grow?"
            ]
        } else {
            return [
                "What is the largest planet in our solar system?",
                "What gas do plants produce?",
                "What is the smallest unit of matter?",
                "What is the process by which plants make food?"
            ]
        }
    }
    
    private func getReadingTemplates(age: Int) -> [String] {
        if age < 6 {
            return [
                "What letter comes after A?",
                "What sound does a cat make?",
                "What is the first letter of your name?",
                "What rhymes with 'cat'?"
            ]
        } else if age < 10 {
            return [
                "What is the opposite of 'big'?",
                "What is a word that rhymes with 'dog'?",
                "What is the plural of 'cat'?",
                "What is a word that starts with 'B'?"
            ]
        } else {
            return [
                "What is a synonym for 'happy'?",
                "What is the main character in a story called?",
                "What is a word that means 'very big'?",
                "What is the opposite of 'begin'?"
            ]
        }
    }
    
    private func getHistoryTemplates(age: Int) -> [String] {
        if age < 8 {
            return [
                "What do we celebrate on the 4th of July?",
                "Who was the first president of the United States?",
                "What is the name of our country?",
                "What do we call the place where people vote?"
            ]
        } else {
            return [
                "Who was the first president of the United States?",
                "What year did World War II end?",
                "Who wrote the Declaration of Independence?",
                "What is the name of the ship that brought the Pilgrims to America?"
            ]
        }
    }
    
    private func getGeographyTemplates(age: Int) -> [String] {
        if age < 8 {
            return [
                "What is the name of our country?",
                "What is the capital of our state?",
                "What ocean is on the east coast?",
                "What is the name of our planet?"
            ]
        } else {
            return [
                "What is the capital of France?",
                "What is the largest continent?",
                "What is the longest river in the world?",
                "What is the smallest country in the world?"
            ]
        }
    }
    
    private func getArtTemplates(age: Int) -> [String] {
        if age < 6 {
            return [
                "What color do you get when you mix red and blue?",
                "What is your favorite color?",
                "What do you use to draw?",
                "What shape has three sides?"
            ]
        } else if age < 10 {
            return [
                "What color do you get when you mix red and yellow?",
                "What is the name of the artist who painted the Mona Lisa?",
                "What is the primary color that is not red or blue?",
                "What do you call a picture you draw of yourself?"
            ]
        } else {
            return [
                "What is the name of the artist who painted the Mona Lisa?",
                "What is the primary color that is not red or blue?",
                "What is the name of the art movement that used bright colors?",
                "What is the name of the artist who painted the Starry Night?"
            ]
        }
    }
    
    // MARK: - Parental Controls
    func validateTimeLimit(_ timeSpent: Int, limit: Int) -> Bool {
        return timeSpent <= limit
    }
    
    func getRecommendedTimeLimit(for age: Int) -> Int {
        switch age {
        case 4...6:
            return 15 // 15 minutes
        case 7...9:
            return 20 // 20 minutes
        case 10...12:
            return 30 // 30 minutes
        default:
            return 30 // 30 minutes
        }
    }
    
    // MARK: - Progress Tracking
    func shouldTrackProgress(for age: Int) -> Bool {
        return age >= 6 // Track progress for children 6 and older
    }
    
    func generateProgressReport(score: QuizScore, age: Int) -> String {
        let percentage = Int((Double(score.correctAnswers) / Double(score.totalQuestions)) * 100)
        
        if age < 8 {
            return "Great job! You got \(score.correctAnswers) out of \(score.totalQuestions) questions right!"
        } else {
            return "You scored \(percentage)% on the \(score.category.name) quiz. You got \(score.correctAnswers) out of \(score.totalQuestions) questions correct!"
        }
    }
}

// MARK: - Content Safety Middleware
struct ContentSafetyMiddleware: Middleware {
    func process(action: AppAction, state: AppState, dispatch: @escaping (AppAction) -> Void) -> AppAction {
        switch action {
        case .startQuiz(let category):
            // Validate content is appropriate for user's age
            if let user = state.user {
                let age = user.age
                let timeLimit = ChildSafetyService.shared.getRecommendedTimeLimit(for: age)
                
                // Check if content is appropriate
                let content = "Sample quiz content" // This would be the actual quiz content
                if !ChildSafetyService.shared.isContentAppropriateForAge(content, age: age) {
                    dispatch(.setError(AppError.contentError("Content not appropriate for this age group")))
                    return action
                }
            }
        default:
            break
        }
        
        return action
    }
}
