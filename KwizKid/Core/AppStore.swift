import Foundation
import Combine

// MARK: - App Store (Unidirectional State Management)
class AppStore: ObservableObject {
    @Published private(set) var state: AppState
    
    private let reducer: AppReducer
    private let middleware: [Middleware]
    private var cancellables = Set<AnyCancellable>()
    
    init(initialState: AppState = AppState(), middleware: [Middleware] = []) {
        self.state = initialState
        self.reducer = AppReducer()
        self.middleware = middleware
    }
    
    func dispatch(_ action: AppAction) {
        // Apply middleware
        let processedAction = middleware.reduce(action) { result, middleware in
            middleware.process(action: result, state: state, dispatch: dispatch)
        }
        
        // Update state through reducer
        let newState = reducer.reduce(state: state, action: processedAction)
        
        DispatchQueue.main.async {
            self.state = newState
        }
    }
}

// MARK: - App Reducer
struct AppReducer {
    func reduce(state: AppState, action: AppAction) -> AppState {
        var newState = state
        
        switch action {
        // App Lifecycle
        case .appLaunched:
            newState.currentScreen = .welcome
            newState.isLoading = false
            
        case .appWillEnterForeground:
            // Handle app foreground logic
            break
            
        case .appDidEnterBackground:
            // Handle app background logic
            break
            
        // Authentication
        case .signIn, .signUp:
            newState.isLoading = true
            newState.errorMessage = nil
            
        case .authenticationSucceeded(let user):
            newState.user = user
            newState.isLoading = false
            newState.currentScreen = .categorySelection
            
        case .authenticationFailed(let error):
            newState.isLoading = false
            newState.errorMessage = error.localizedDescription
            
        case .signOut:
            newState.user = nil
            newState.currentScreen = .welcome
            
        // Categories
        case .loadCategories:
            newState.isLoading = true
            newState.errorMessage = nil
            
        case .categoriesLoaded(let categories):
            newState.categories = categories
            newState.isLoading = false
            
        case .categoriesLoadFailed(let error):
            newState.isLoading = false
            newState.errorMessage = error.localizedDescription
            
        // Quiz
        case .selectCategory(let category):
            newState.currentScreen = .quiz(category)
            
        case .startQuiz(let category):
            newState.isLoading = true
            newState.errorMessage = nil
            
        case .quizLoaded(let quiz):
            newState.currentQuiz = quiz
            newState.isLoading = false
            
        case .quizLoadFailed(let error):
            newState.isLoading = false
            newState.errorMessage = error.localizedDescription
            
        case .answerQuestion(let selectedAnswer):
            // Handle answer logic in quiz view
            break
            
        case .submitQuiz:
            newState.isLoading = true
            
        case .quizCompleted(let score):
            newState.isLoading = false
            newState.currentScreen = .results(score)
            newState.currentQuiz = nil
            
        // Navigation
        case .navigateTo(let screen):
            newState.currentScreen = screen
            
        case .goBack:
            // Handle back navigation logic
            break
            
        case .selectTab(let tab):
            newState.selectedTab = tab
            
        // Subscription
        case .checkSubscriptionStatus:
            newState.isLoading = true
            
        case .subscriptionStatusUpdated(let status):
            newState.subscriptionStatus = status
            newState.isLoading = false
            
        case .purchaseSubscription:
            newState.isLoading = true
            
        case .subscriptionPurchased:
            newState.subscriptionStatus = .premium
            newState.isLoading = false
            
        case .subscriptionPurchaseFailed(let error):
            newState.isLoading = false
            newState.errorMessage = error.localizedDescription
            
        // UI State
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let error):
            newState.errorMessage = error?.localizedDescription
            newState.isLoading = false
            
        case .clearError:
            newState.errorMessage = nil
            
        // Settings
        case .updateUserPreferences(let preferences):
            if var user = newState.user {
                user.preferences = preferences
                newState.user = user
            }
            
        case .updateParentalControls(let controls):
            if var user = newState.user {
                user.preferences.parentalControls = controls
                newState.user = user
            }
        }
        
        return newState
    }
}

// MARK: - Middleware Protocol
protocol Middleware {
    func process(action: AppAction, state: AppState, dispatch: @escaping (AppAction) -> Void) -> AppAction
}

// MARK: - Logging Middleware
struct LoggingMiddleware: Middleware {
    func process(action: AppAction, state: AppState, dispatch: @escaping (AppAction) -> Void) -> AppAction {
        print("🔄 Action: \(action)")
        return action
    }
}

// MARK: - Analytics Middleware
struct AnalyticsMiddleware: Middleware {
    func process(action: AppAction, state: AppState, dispatch: @escaping (AppAction) -> Void) -> AppAction {
        // Track analytics events
        switch action {
        case .appLaunched:
            // Track app launch
            break
        case .quizCompleted(let score):
            // Track quiz completion
            break
        case .purchaseSubscription:
            // Track subscription purchase
            break
        default:
            break
        }
        
        return action
    }
}
