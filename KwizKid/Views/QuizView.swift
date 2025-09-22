import SwiftUI

struct QuizView: View {
    let category: QuizCategory
    @EnvironmentObject var store: AppStore
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var showQuitAlert = false
    @State private var questions: [Question] = []
    @State private var isLoadingQuestions = true
    @State private var loadingError: String?
    
    private let quizContentService = QuizContentService.shared
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoadingQuestions {
                loadingView
            } else if let error = loadingError {
                errorView(error)
            } else {
                quizContent
            }
        }
        .onAppear {
            loadQuestions()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Generating Questions...")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("Our AI is creating personalized questions for you!")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Error View
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(error)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Try Again") {
                loadQuestions()
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(20)
        }
    }
    
    // MARK: - Quiz Content
    private var quizContent: some View {
        VStack(spacing: 0) {
            // Header
            QuizHeaderView(
                category: category,
                currentQuestion: currentQuestionIndex + 1,
                totalQuestions: questions.count,
                timeRemaining: timeRemaining,
                onQuit: {
                    showQuitAlert = true
                }
            )
            
            // Progress Bar
            ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
            // Question Content
            if currentQuestionIndex < questions.count {
                QuestionView(
                    question: questions[currentQuestionIndex],
                    selectedAnswer: selectedAnswer,
                    showResult: showResult,
                    isCorrect: isCorrect,
                    onAnswerSelected: { answer in
                        selectedAnswer = answer
                    }
                )
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                if showResult {
                    ResultView(
                        isCorrect: isCorrect,
                        explanation: questions[currentQuestionIndex].explanation,
                        onContinue: {
                            nextQuestion()
                        }
                    )
                } else {
                    Button(action: {
                        submitAnswer()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Submit Answer")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            selectedAnswer != nil ? 
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(28)
                    }
                    .disabled(selectedAnswer == nil)
                    .padding(.horizontal, 32)
                }
            }
            .padding(.bottom, 32)
        }
        .navigationBarHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .alert("Quit Quiz?", isPresented: $showQuitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Quit", role: .destructive) {
                quitQuiz()
            }
        } message: {
            Text("Are you sure you want to quit? Your progress will be lost.")
        }
    }
    
    // MARK: - Load Questions
    private func loadQuestions() {
        isLoadingQuestions = true
        loadingError = nil
        
        Task {
            do {
                let generatedQuestions = try await quizContentService.generateQuestions(for: category, count: 5)
                await MainActor.run {
                    self.questions = generatedQuestions
                    self.isLoadingQuestions = false
                }
            } catch {
                await MainActor.run {
                    self.loadingError = "Failed to generate questions. Please try again."
                    self.isLoadingQuestions = false
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Time's up - auto submit
                submitAnswer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func submitAnswer() {
        guard let selectedAnswer = selectedAnswer else { return }
        
        let question = questions[currentQuestionIndex]
        isCorrect = selectedAnswer == question.correctAnswer
        
        if isCorrect {
            score += 1
        }
        
        showResult = true
        stopTimer()
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
            timeRemaining = 30
            startTimer()
        } else {
            // Quiz completed
            let quizScore = QuizScore(
                totalQuestions: questions.count,
                correctAnswers: score,
                timeSpent: (30 * questions.count) - timeRemaining,
                category: category,
                completedAt: Date()
            )
            store.dispatch(.quizCompleted(quizScore))
        }
    }
    
    private func quitQuiz() {
        stopTimer()
        store.dispatch(.navigateTo(.categorySelection))
    }
}

struct QuizHeaderView: View {
    let category: QuizCategory
    let currentQuestion: Int
    let totalQuestions: Int
    let timeRemaining: Int
    let onQuit: () -> Void
    
    var body: some View {
        HStack {
            // Back/Quit button
            Button(action: onQuit) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Quit")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            
            Spacer()
            
            // Category info
            VStack(spacing: 4) {
                Text(category.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Question \(currentQuestion) of \(totalQuestions)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Timer
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(timeRemaining <= 10 ? .red : .blue)
                Text("\(timeRemaining)s")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(timeRemaining <= 10 ? .red : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(timeRemaining <= 10 ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

struct QuestionView: View {
    let question: Question
    let selectedAnswer: Int?
    let showResult: Bool
    let isCorrect: Bool
    let onAnswerSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Question text
            Text(question.text)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    AnswerOptionView(
                        text: option,
                        isSelected: selectedAnswer == index,
                        isCorrect: showResult && index == question.correctAnswer,
                        isWrong: showResult && selectedAnswer == index && index != question.correctAnswer,
                        onTap: {
                            if !showResult {
                                onAnswerSelected(index)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }
}

struct AnswerOptionView: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let onTap: () -> Void
    
    private var backgroundColor: Color {
        if isCorrect {
            return .green.opacity(0.2)
        } else if isWrong {
            return .red.opacity(0.2)
        } else if isSelected {
            return .blue.opacity(0.2)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isWrong {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return .clear
        }
    }
    
    private var iconName: String? {
        if isCorrect {
            return "checkmark.circle.fill"
        } else if isWrong {
            return "xmark.circle.fill"
        } else {
            return nil
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isCorrect ? .green : .red)
                }
                
                Text(text)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct ResultView: View {
    let isCorrect: Bool
    let explanation: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Result icon
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(isCorrect ? .green : .red)
                .scaleEffect(1.2)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isCorrect)
            
            // Result text
            Text(isCorrect ? "Great Job!" : "Not Quite Right")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(isCorrect ? .green : .red)
            
            // Explanation
            Text(explanation)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Continue button
            Button(action: onContinue) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Continue")
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
            }
            .padding(.horizontal, 32)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    QuizView(category: QuizCategory(
        id: "math",
        name: "Math Magic",
        description: "Numbers, shapes, and calculations",
        icon: "plus.circle.fill",
        color: "blue",
        difficulty: .easy,
        ageRange: AgeRange(min: 5, max: 12)
    ))
    .environmentObject(AppStore())
}
