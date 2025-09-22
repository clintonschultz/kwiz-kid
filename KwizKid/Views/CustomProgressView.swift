import SwiftUI

struct CustomProgressView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var showingAchievementDetails = false
    @State private var selectedAchievement: Achievement?
    
    enum TimeFrame: String, CaseIterable {
        case week = "week"
        case month = "month"
        case all = "all"
        
        var displayName: String {
            switch self {
            case .week: return "This Week"
            case .month: return "This Month"
            case .all: return "All Time"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with stats
                    headerSection
                    
                    // Time frame selector
                    timeFrameSelector
                    
                    // Progress overview
                    progressOverview
                    
                    // Achievements section
                    achievementsSection
                    
                    // Category progress
                    categoryProgressSection
                    
                    // Weekly streak
                    streakSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAchievementDetails) {
            if let achievement = selectedAchievement {
                AchievementDetailView(achievement: achievement)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Main stats
            HStack(spacing: 20) {
                StatCard(
                    title: "Quizzes Completed",
                    value: "\(store.state.userStats.totalQuizzesCompleted)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(store.state.userStats.currentStreak) days",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Accuracy",
                    value: accuracyPercentage,
                    icon: "target",
                    color: .blue
                )
                
                StatCard(
                    title: "Time Spent",
                    value: timeSpentFormatted,
                    icon: "clock.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Time Frame Selector
    private var timeFrameSelector: some View {
        HStack(spacing: 12) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Button(action: {
                    selectedTimeframe = timeframe
                }) {
                    Text(timeframe.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTimeframe == timeframe ? Color.blue : Color.blue.opacity(0.1))
                        )
                }
            }
        }
    }
    
    // MARK: - Progress Overview
    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Overview")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ProgressRow(
                    title: "Questions Answered",
                    current: questionsAnswered,
                    total: questionsAnswered + 10, // Example total
                    color: .blue
                )
                
                ProgressRow(
                    title: "Correct Answers",
                    current: store.state.userStats.correctAnswers,
                    total: store.state.userStats.totalQuestionsAnswered,
                    color: .green
                )
                
                ProgressRow(
                    title: "Categories Mastered",
                    current: masteredCategories,
                    total: 6, // Total categories
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(store.state.userStats.achievements.count) earned")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(store.state.userStats.achievements) { achievement in
                    AchievementBadge(
                        achievement: achievement,
                        onTap: {
                            selectedAchievement = achievement
                            showingAchievementDetails = true
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Category Progress Section
    private var categoryProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Progress")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(categoryProgressData, id: \.category) { data in
                    CategoryProgressRow(
                        category: data.category,
                        progress: data.progress,
                        questionsAnswered: data.questionsAnswered,
                        accuracy: data.accuracy
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Streak")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Streak")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(store.state.userStats.currentStreak) days")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Best Streak")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(store.state.userStats.longestStreak) days")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
            
            // Streak visualization
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { day in
                    Circle()
                        .fill(day < store.state.userStats.currentStreak ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Computed Properties
    private var accuracyPercentage: String {
        guard store.state.userStats.totalQuestionsAnswered > 0 else { return "0%" }
        let percentage = (Double(store.state.userStats.correctAnswers) / Double(store.state.userStats.totalQuestionsAnswered)) * 100
        return String(format: "%.0f%%", percentage)
    }
    
    private var timeSpentFormatted: String {
        let hours = store.state.userStats.totalTimeSpent / 3600
        let minutes = (store.state.userStats.totalTimeSpent % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var questionsAnswered: Int {
        store.state.userStats.totalQuestionsAnswered
    }
    
    private var masteredCategories: Int {
        // Count categories with high accuracy
        store.state.userStats.categoryStats.values.filter { $0.accuracy >= 80 }.count
    }
    
    private var categoryProgressData: [CategoryProgressData] {
        [
            CategoryProgressData(category: "Math", progress: 0.8, questionsAnswered: 24, accuracy: 85),
            CategoryProgressData(category: "Science", progress: 0.6, questionsAnswered: 18, accuracy: 78),
            CategoryProgressData(category: "Reading", progress: 0.9, questionsAnswered: 27, accuracy: 92),
            CategoryProgressData(category: "History", progress: 0.4, questionsAnswered: 12, accuracy: 67),
            CategoryProgressData(category: "Geography", progress: 0.7, questionsAnswered: 21, accuracy: 81),
            CategoryProgressData(category: "Art", progress: 0.5, questionsAnswered: 15, accuracy: 73)
        ]
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct ProgressRow: View {
    let title: String
    let current: Int
    let total: Int
    let color: Color
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(current)/\(total)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                
                Text(achievement.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(achievement.isUnlocked ? Color.yellow : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryProgressRow: View {
    let category: String
    let progress: Double
    let questionsAnswered: Int
    let accuracy: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(accuracy)%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(accuracy >= 80 ? .green : accuracy >= 60 ? .orange : .red)
            }
            
            HStack {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: accuracy >= 80 ? .green : accuracy >= 60 ? .orange : .red))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                
                Text("\(questionsAnswered) questions")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Achievement icon
                Image(systemName: achievement.icon)
                    .font(.system(size: 80))
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                
                // Achievement title
                Text(achievement.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Achievement description
                Text(achievement.description)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Progress if not unlocked
                if !achievement.isUnlocked {
                    VStack(spacing: 12) {
                        Text("Progress: \(achievement.progress)/\(achievement.requirement)")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        ProgressView(value: Double(achievement.progress), total: Double(achievement.requirement))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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

// MARK: - Supporting Data Structures

struct CategoryProgressData {
    let category: String
    let progress: Double
    let questionsAnswered: Int
    let accuracy: Int
}

#Preview {
    CustomProgressView()
        .environmentObject(AppStore())
}
