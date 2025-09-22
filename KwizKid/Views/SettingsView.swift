import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var showParentalControls = false
    @State private var showNotifications = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // User Section
                Section {
                    HStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(store.state.user?.name.prefix(1).uppercased() ?? "U")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.state.user?.name ?? "Guest User")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Learning Level: \(getLearningLevel())")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Learning Preferences
                Section("Learning Preferences") {
                    NavigationLink(destination: DifficultySettingsView()) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Difficulty Level")
                            Spacer()
                            Text(store.state.user?.preferences.difficulty.displayName ?? "Easy")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: CategoryPreferencesView()) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .frame(width: 24)
                            Text("Favorite Categories")
                            Spacer()
                            Text("\(store.state.user?.preferences.favoriteCategories.count ?? 0) selected")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Parental Controls
                Section("Parental Controls") {
                    Button(action: {
                        showParentalControls = true
                    }) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Parental Controls")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Notifications
                Section("Notifications") {
                    Button(action: {
                        showNotifications = true
                    }) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Notification Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Subscription
                Section("Subscription") {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .frame(width: 24)
                        Text("Subscription Status")
                        Spacer()
                        Text(store.state.subscriptionStatus == .premium ? "Premium" : "Free")
                            .foregroundColor(store.state.subscriptionStatus == .premium ? .green : .secondary)
                    }
                    
                    if store.state.subscriptionStatus != .premium {
                        Button(action: {
                            store.dispatch(.purchaseSubscription)
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .frame(width: 24)
                                Text("Upgrade to Premium")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                // App Settings
                Section("App Settings") {
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("About KwizKid")
                        }
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            Text("Privacy Policy")
                        }
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Terms of Service")
                        }
                    }
                }
                
                // Account
                Section("Account") {
                    Button(action: {
                        store.dispatch(.signOut)
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Sign Out")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showParentalControls) {
            ParentalControlsView()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationSettingsView()
        }
    }
    
    private func getLearningLevel() -> String {
        let totalQuizzes = store.state.userStats.totalQuizzesCompleted
        switch totalQuizzes {
        case 0..<5: return "Beginner"
        case 5..<15: return "Explorer"
        case 15..<30: return "Scholar"
        case 30..<50: return "Expert"
        default: return "Master"
        }
    }
}

// MARK: - Settings Sub-Views

struct DifficultySettingsView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        List {
            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                Button(action: {
                    var preferences = store.state.user?.preferences ?? UserPreferences()
                    preferences.difficulty = difficulty
                    store.dispatch(.updateUserPreferences(preferences))
                }) {
                    HStack {
                        Text(difficulty.displayName)
                        Spacer()
                        if store.state.user?.preferences.difficulty == difficulty {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Difficulty Level")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryPreferencesView: View {
    @EnvironmentObject var store: AppStore
    
    private let categories = ["math", "science", "reading", "history", "geography", "art"]
    
    var body: some View {
        List {
            ForEach(categories, id: \.self) { categoryId in
                Button(action: {
                    toggleCategory(categoryId)
                }) {
                    HStack {
                        Text(getCategoryName(categoryId))
                        Spacer()
                        if store.state.user?.preferences.favoriteCategories.contains(categoryId) == true {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                        } else {
                            Image(systemName: "heart")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Favorite Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleCategory(_ categoryId: String) {
        var preferences = store.state.user?.preferences ?? UserPreferences()
        if preferences.favoriteCategories.contains(categoryId) {
            preferences.favoriteCategories.removeAll { $0 == categoryId }
        } else {
            preferences.favoriteCategories.append(categoryId)
        }
        store.dispatch(.updateUserPreferences(preferences))
    }
    
    private func getCategoryName(_ id: String) -> String {
        switch id {
        case "math": return "Math Magic"
        case "science": return "Science Fun"
        case "reading": return "Reading Adventure"
        case "history": return "Time Travel"
        case "geography": return "World Explorer"
        case "art": return "Creative Corner"
        default: return "Unknown"
        }
    }
}

struct ParentalControlsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Time Limits") {
                    HStack {
                        Text("Daily Time Limit")
                        Spacer()
                        Text("\(store.state.user?.preferences.parentalControls.timeLimit ?? 30) minutes")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Content Filtering") {
                    HStack {
                        Text("Content Filter")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { store.state.user?.preferences.parentalControls.contentFilter ?? true },
                            set: { newValue in
                                var preferences = store.state.user?.preferences ?? UserPreferences()
                                preferences.parentalControls.contentFilter = newValue
                                store.dispatch(.updateUserPreferences(preferences))
                            }
                        ))
                    }
                }
                
                Section("Progress Tracking") {
                    HStack {
                        Text("Track Progress")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { store.state.user?.preferences.parentalControls.progressTracking ?? true },
                            set: { newValue in
                                var preferences = store.state.user?.preferences ?? UserPreferences()
                                preferences.parentalControls.progressTracking = newValue
                                store.dispatch(.updateUserPreferences(preferences))
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Parental Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Learning Reminders") {
                    HStack {
                        Text("Daily Learning Reminder")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section("Achievements") {
                    HStack {
                        Text("Achievement Notifications")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("KwizKid")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Version 1.0.0")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("Making learning fun for kids through interactive quizzes and AI-powered content.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 40)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Your privacy is important to us. This policy explains how we collect, use, and protect your information.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                // Add more privacy policy content here
            }
            .padding(20)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("By using KwizKid, you agree to these terms and conditions.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                // Add more terms content here
            }
            .padding(20)
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStore())
}
