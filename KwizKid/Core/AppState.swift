import Foundation

// MARK: - App State
struct AppState {
    var currentScreen: Screen = .welcome
    var selectedTab: CurrentTab = .home
    var user: User?
    var categories: [QuizCategory] = []
    var currentQuiz: Quiz?
    var isLoading = false
    var errorMessage: String?
    var subscriptionStatus: SubscriptionStatus = .free
    var userStats: UserStats = UserStats()
}

// MARK: - Screen Enum
enum Screen {
    case welcome
    case categorySelection
    case quiz(QuizCategory)
    case results(QuizScore)
}

// MARK: - Tab Enum
enum CurrentTab: String, CaseIterable {
    case home = "home"
    case progress = "progress"
    case profile = "profile"
    case settings = "settings"
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let age: Int
    var preferences: UserPreferences
}

struct UserPreferences: Codable {
    var difficulty: Difficulty = .easy
    var sessionLength: Int = 15 // minutes
    var soundEffects: Bool = true
    var favoriteCategories: [String] = []
    var parentalControls: ParentalControls = ParentalControls()
}

struct ParentalControls: Codable {
    var timeLimit: Int = 30 // minutes
    var dailyTimeLimit: Int = 60 // minutes
    var contentFilter: Bool = true
    var progressTracking: Bool = true
}

// MARK: - Quiz Models
struct QuizCategory: Codable, Identifiable, Hashable {
    static func == (lhs: QuizCategory, rhs: QuizCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: String
    let difficulty: Difficulty
    let ageRange: AgeRange
}

struct AgeRange: Codable, Hashable {
    let min: Int
    let max: Int
}

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var displayName: String {
        return self.rawValue
    }
}

struct Quiz: Codable {
    let id: String
    let category: QuizCategory
    let questions: [Question]
    let timeLimit: Int // seconds
}

struct Question: Codable, Identifiable {
    let id: String
    var text: String
    let options: [String]
    let correctAnswer: Int
    var explanation: String
    let difficulty: Difficulty
}

struct QuizScore: Codable {
    let totalQuestions: Int
    let correctAnswers: Int
    let timeSpent: Int
    let category: QuizCategory
    let completedAt: Date
}

// MARK: - Subscription
enum SubscriptionStatus {
    case free
    case premium
    case trial
}

// MARK: - User Stats
struct UserStats: Codable {
    var totalQuizzesCompleted: Int = 0
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var totalTimeSpent: Int = 0 // in seconds
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var achievements: [Achievement] = []
    var categoryStats: [String: CategoryStats] = [:]
    var weeklyProgress: [WeeklyProgress] = []
    var lastQuizDate: Date?
}

struct CategoryStats: Codable {
    var quizzesCompleted: Int = 0
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var accuracy: Double = 0.0
    var averageScore: Double = 0.0
    var bestScore: Int = 0
    var timeSpent: Int = 0
}

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    let progress: Int
    let requirement: Int
}

struct WeeklyProgress: Codable {
    let weekStart: Date
    let quizzesCompleted: Int
    let timeSpent: Int
    let averageScore: Double
}

// MARK: - Error Types
enum AppError: LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case subscriptionError(String)
    case contentError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .subscriptionError(let message):
            return "Subscription Error: \(message)"
        case .contentError(let message):
            return "Content Error: \(message)"
        }
    }
}
