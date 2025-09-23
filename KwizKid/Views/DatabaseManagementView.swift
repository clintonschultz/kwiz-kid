import SwiftUI

struct DatabaseManagementView: View {
    @StateObject private var batchGenerator = QuestionBatchGenerator.shared
    @StateObject private var databaseService = AWSDatabaseService.shared
    @State private var showingGenerationConfig = false
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "server.rack")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Question Database")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("Manage your question database")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Connection Status
                HStack {
                    Circle()
                        .fill(databaseService.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(databaseService.isConnected ? "Connected to AWS" : "Disconnected")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(databaseService.isConnected ? .green : .red)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // Generation Progress
                if batchGenerator.isGenerating {
                    VStack(spacing: 16) {
                        ProgressView(value: batchGenerator.progress?.percentage ?? 0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        if let progress = batchGenerator.progress {
                            Text("\(Int(progress.percentage * 100))% Complete")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            
                            Text(progress.currentTask)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Error Display
                if let error = batchGenerator.generationError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        
                        Text("Generation Error")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        
                        Text(error)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Generate Questions Button
                    Button(action: {
                        showingGenerationConfig = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Generate Questions")
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
                    .disabled(batchGenerator.isGenerating)
                    
                    // Clear Database Button
                    Button(action: {
                        showingClearConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                            Text("Clear Database")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                    }
                    .disabled(batchGenerator.isGenerating)
                    
                    // Database Stats Button
                    Button(action: {
                        // TODO: Show database statistics
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("View Statistics")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingGenerationConfig) {
            GenerationConfigView()
        }
        .alert("Clear Database", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task {
                    try await batchGenerator.clearDatabase()
                }
            }
        } message: {
            Text("This will permanently delete all questions in the database. This action cannot be undone.")
        }
    }
}

struct GenerationConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var batchGenerator = QuestionBatchGenerator.shared
    
    @State private var questionsPerCategory = 50
    @State private var selectedCategories: Set<String> = ["Science", "Math", "History", "Geography", "Animals", "Space"]
    @State private var selectedDifficulties: Set<Difficulty> = [.easy, .medium, .hard]
    @State private var selectedAgeRanges: Set<AgeRange> = [
        AgeRange(min: 5, max: 8),
        AgeRange(min: 9, max: 12),
        AgeRange(min: 13, max: 16)
    ]
    
    private let availableCategories = ["Science", "Math", "History", "Geography", "Animals", "Space", "Art", "Music", "Sports", "Technology"]
    private let availableDifficulties: [Difficulty] = [.easy, .medium, .hard]
    private let availableAgeRanges = [
        AgeRange(min: 5, max: 8),
        AgeRange(min: 9, max: 12),
        AgeRange(min: 13, max: 16),
        AgeRange(min: 17, max: 18)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Generation Configuration")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("Configure how many questions to generate")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Questions per category
                VStack(alignment: .leading, spacing: 12) {
                    Text("Questions per Category")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    HStack {
                        Slider(value: Binding(
                            get: { Double(questionsPerCategory) },
                            set: { questionsPerCategory = Int($0) }
                        ), in: 10...100, step: 10)
                        .accentColor(.blue)
                        
                        Text("\(questionsPerCategory)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(width: 40)
                    }
                }
                .padding(.horizontal, 20)
                
                // Categories Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Categories")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(availableCategories, id: \.self) { category in
                            CategoryToggleView(
                                category: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Difficulties Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulties")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    HStack(spacing: 16) {
                        ForEach(availableDifficulties, id: \.self) { difficulty in
                            DifficultyToggleView(
                                difficulty: difficulty,
                                isSelected: selectedDifficulties.contains(difficulty)
                            ) {
                                if selectedDifficulties.contains(difficulty) {
                                    selectedDifficulties.remove(difficulty)
                                } else {
                                    selectedDifficulties.insert(difficulty)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Generate Button
                Button(action: {
                    let config = BatchGenerationConfig(
                        questionsPerCategory: questionsPerCategory,
                        categories: Array(selectedCategories),
                        difficulties: Array(selectedDifficulties),
                        ageRanges: Array(selectedAgeRanges)
                    )
                    
                    Task {
                        await batchGenerator.generateQuestionDatabase(config: config)
                    }
                    
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Start Generation")
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
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryToggleView: View {
    let category: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text(category)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DifficultyToggleView: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text(difficulty.rawValue.capitalized)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DatabaseManagementView()
}
