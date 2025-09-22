import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        NavigationView {
            switch store.state.currentScreen {
            case .welcome:
                WelcomeView()
            case .categorySelection:
                MainTabView()
            case .quiz(let category):
                QuizView(category: category)
            case .results(let score):
                ResultsView(score: score)
            }
        }
        .onAppear {
            store.dispatch(.appLaunched)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore())
}
