import SwiftUI

struct ResultsView: View {
    let score: QuizScore
    @EnvironmentObject var store: AppStore
    @State private var animateScore = false
    @State private var showCelebration = false
    
    private var percentage: Int {
        Int((Double(score.correctAnswers) / Double(score.totalQuestions)) * 100)
    }
    
    private var performanceMessage: String {
        switch percentage {
        case 90...100:
            return "Outstanding! 🌟"
        case 80..<90:
            return "Excellent Work! 🎉"
        case 70..<80:
            return "Great Job! 👏"
        case 60..<70:
            return "Good Effort! 👍"
        default:
            return "Keep Learning! 📚"
        }
    }
    
    private var performanceColor: Color {
        switch percentage {
        case 90...100:
            return .green
        case 80..<90:
            return .blue
        case 70..<80:
            return .orange
        case 60..<70:
            return .yellow
        default:
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Quiz Complete!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(score.category.name)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Score Card
                    VStack(spacing: 24) {
                        // Score Circle
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                .frame(width: 160, height: 160)
                            
                            Circle()
                                .trim(from: 0, to: animateScore ? CGFloat(percentage) / 100 : 0)
                                .stroke(
                                    LinearGradient(
                                        colors: [performanceColor, performanceColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 2.0), value: animateScore)
                            
                            VStack(spacing: 4) {
                                Text("\(percentage)%")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(performanceColor)
                                
                                Text("Score")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Performance Message
                        Text(performanceMessage)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(performanceColor)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ResultStatCard(
                            title: "Correct",
                            value: "\(score.correctAnswers)",
                            subtitle: "out of \(score.totalQuestions)",
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                        
                        ResultStatCard(
                            title: "Time",
                            value: "\(score.timeSpent)s",
                            subtitle: "total time",
                            color: .blue,
                            icon: "clock.fill"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            store.dispatch(.navigateTo(.categorySelection))
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                Text("Try Another Quiz")
                            }
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: {
                            store.dispatch(.navigateTo(.welcome))
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Back to Home")
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                animateScore = true
            }
            
            withAnimation(.easeInOut(duration: 0.3).delay(1.0)) {
                showCelebration = true
            }
        }
    }
}

struct ResultStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ResultsView(score: QuizScore(
        totalQuestions: 10,
        correctAnswers: 8,
        timeSpent: 120,
        category: QuizCategory(
            id: "math",
            name: "Math Magic",
            description: "Numbers, shapes, and calculations",
            icon: "plus.circle.fill",
            color: "blue",
            difficulty: .easy,
            ageRange: AgeRange(min: 5, max: 12)
        ),
        completedAt: Date()
    ))
    .environmentObject(AppStore())
}
