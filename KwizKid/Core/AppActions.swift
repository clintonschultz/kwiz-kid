import Foundation

// MARK: - App Actions
enum AppAction {
    // App Lifecycle
    case appLaunched
    case appWillEnterForeground
    case appDidEnterBackground
    
    // Authentication
    case signIn(String, String) // email, password
    case signUp(String, String, String) // email, password, name
    case signOut
    case authenticationSucceeded(User)
    case authenticationFailed(AppError)
    
    // Categories
    case loadCategories
    case categoriesLoaded([QuizCategory])
    case categoriesLoadFailed(AppError)
    
    // Quiz
    case selectCategory(QuizCategory)
    case startQuiz(QuizCategory)
    case quizLoaded(Quiz)
    case quizLoadFailed(AppError)
    case answerQuestion(Int) // question index, selected answer
    case submitQuiz
    case quizCompleted(QuizScore)
    
    // Navigation
    case navigateTo(Screen)
    case goBack
    case selectTab(CurrentTab)
    
    // Subscription
    case checkSubscriptionStatus
    case subscriptionStatusUpdated(SubscriptionStatus)
    case purchaseSubscription
    case subscriptionPurchased
    case subscriptionPurchaseFailed(AppError)
    
    // UI State
    case setLoading(Bool)
    case setError(AppError?)
    case clearError
    
    // Settings
    case updateUserPreferences(UserPreferences)
    case updateParentalControls(ParentalControls)
}

// MARK: - Action Creators
struct ActionCreators {
    static func loadCategories() -> AppAction {
        return .loadCategories
    }
    
    static func selectCategory(_ category: QuizCategory) -> AppAction {
        return .selectCategory(category)
    }
    
    static func startQuiz(for category: QuizCategory) -> AppAction {
        return .startQuiz(category)
    }
    
    static func answerQuestion(_ questionIndex: Int, selectedAnswer: Int) -> AppAction {
        return .answerQuestion(selectedAnswer)
    }
    
    static func navigateTo(_ screen: Screen) -> AppAction {
        return .navigateTo(screen)
    }
    
    static func setError(_ error: AppError) -> AppAction {
        return .setError(error)
    }
    
    static func clearError() -> AppAction {
        return .clearError
    }
}
