import SwiftUI
import PhotosUI

struct AdminToolView: View {
    @StateObject private var database = QuestionDatabase.shared
    @StateObject private var aiGenerator = AIQuestionGenerator.shared
    
    @State private var selectedCategory = "math"
    @State private var selectedDifficulty = Difficulty.easy
    @State private var ageMin = 8
    @State private var ageMax = 12
    @State private var questionCount = 10
    @State private var includeImages = true
    
    @State private var isGenerating = false
    @State private var generationProgress = ""
    @State private var lastError: String?
    
    @State private var showQuestionPreview = false
    @State private var previewQuestions: [QuestionRecord] = []
    
    // Image management
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var imagePrompt = ""
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Generation Settings
                Section("Question Generation Settings") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(database.categories, id: \.id) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                    
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue.capitalized).tag(difficulty)
                        }
                    }
                    
                    HStack {
                        Text("Age Range:")
                        Spacer()
                        Stepper("Min: \(ageMin)", value: $ageMin, in: 5...16)
                        Stepper("Max: \(ageMax)", value: $ageMax, in: ageMin...16)
                    }
                    
                    Stepper("Questions to Generate: \(questionCount)", value: $questionCount, in: 1...100)
                    
                    Toggle("Include Images", isOn: $includeImages)
                }
                
                // MARK: - Image Management
                if includeImages {
                    Section("Image Settings") {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            HStack {
                                Image(systemName: "photo")
                                Text(selectedImageData != nil ? "Image Selected" : "Select Image")
                                Spacer()
                                if selectedImageData != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .onChange(of: selectedImage) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                        
                        TextField("Image Prompt (for AI generation)", text: $imagePrompt)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // MARK: - Generation Actions
                Section("Actions") {
                    Button(action: generateQuestions) {
                        Label("Generate Questions", systemImage: "plus.circle.fill")
                    }
                    .disabled(isGenerating)
                    
                    Button(action: showPreview) {
                        Label("Preview Questions", systemImage: "eye.fill")
                    }
                    .disabled(isGenerating)
                    
                    Button(action: clearDatabase) {
                        Label("Clear All Questions", systemImage: "trash.fill")
                    }
                    .foregroundColor(.red)
                }
                
                // MARK: - Progress
                if isGenerating {
                    Section("Generation Progress") {
                        ProgressView()
                        Text(generationProgress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let error = lastError {
                    Section("Error") {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // MARK: - Database Statistics
                Section("Database Statistics") {
                    HStack {
                        Text("Total Questions")
                        Spacer()
                        Text("\(database.totalQuestions)")
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(database.categories, id: \.id) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            Text("\(database.getQuestionCount(by: category.id))")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                        Button("Test: Show All Questions") {
                            let allQuestions = database.fetchQuestions(limit: 100)
                            print("🔍 All questions in database: \(allQuestions.count)")
                            for (index, question) in allQuestions.enumerated() {
                                print("  \(index + 1). \(question.questionText) (Category: \(question.category), Difficulty: \(question.difficulty), Age: \(question.ageMin)-\(question.ageMax))")
                            }
                        }
                        
                        Button("Test: Database Connection") {
                            print("🔧 Database Connection Test:")
                            print("  - Is Connected: \(database.isConnected)")
                            print("  - Total Questions: \(database.totalQuestions)")
                            print("  - Categories: \(database.categories.count)")
                        }
                        
                        Button("Fix: Activate All Questions") {
                            database.activateAllQuestions()
                        }
                }
            }
            .navigationTitle("Question Admin")
            .sheet(isPresented: $showQuestionPreview) {
                QuestionPreviewView(questions: previewQuestions)
            }
        }
    }
    
    // MARK: - Question Generation
    private func generateQuestions() {
        isGenerating = true
        generationProgress = "Starting generation..."
        lastError = nil
        
        Task {
            do {
                for i in 1...questionCount {
                    generationProgress = "Generating question \(i) of \(questionCount)..."
                    
                    // Generate question using AI
                    let questions = try await aiGenerator.generateQuestions(
                        for: selectedCategory,
                        difficulty: selectedDifficulty,
                        ageRange: AgeRange(min: ageMin, max: ageMax),
                        count: 1
                    )
                    
                    guard let question = questions.first else { continue }
                    
                    // Create image if needed
                    var imagePath: String?
                    var imagePrompt: String?
                    
                    if includeImages {
                        if let imageData = selectedImageData {
                            // Use selected image
                            imagePath = saveImageToDocuments(imageData, questionId: question.id)
                        } else if !self.imagePrompt.isEmpty {
                            // Use AI-generated image prompt
                            imagePrompt = self.imagePrompt
                        }
                    }
                    
                    // Create question record
                    let questionRecord = QuestionRecord(
                        id: question.id,
                        category: selectedCategory,
                        difficulty: selectedDifficulty.rawValue,
                        ageMin: ageMin,
                        ageMax: ageMax,
                        questionText: question.text,
                        options: question.options,
                        correctAnswer: question.correctAnswer,
                        explanation: question.explanation,
                        hasImage: includeImages,
                        imagePath: imagePath,
                        imagePrompt: imagePrompt,
                        tags: generateTags(for: selectedCategory),
                        createdAt: Date(),
                        isActive: true,
                        usageCount: 0
                    )
                    
                    // Insert into database
                    await MainActor.run {
                        database.insertQuestion(questionRecord)
                    }
                    
                    print("✅ Generated question \(i): \(question.text)")
                }
                
                await MainActor.run {
                    isGenerating = false
                    generationProgress = "Generation complete!"
                    database.updateStatistics()
                }
                
            } catch {
                await MainActor.run {
                    isGenerating = false
                    lastError = "Generation failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func showPreview() {
        print("🔍 Preview Parameters:")
        print("  - Category: \(selectedCategory)")
        print("  - Difficulty: \(selectedDifficulty.rawValue)")
        print("  - Age Range: \(ageMin)-\(ageMax)")
        
        let questions = database.fetchQuestions(
            category: selectedCategory,
            difficulty: selectedDifficulty,
            ageRange: AgeRange(min: ageMin, max: ageMax),
            limit: 5
        )
        
        print("🔍 Preview: Found \(questions.count) questions for \(selectedCategory)")
        
        if questions.isEmpty {
            print("⚠️ No questions found in database. Generate some questions first!")
            // Try a broader search without filters
            let allQuestions = database.fetchQuestions(limit: 10)
            print("🔍 Total questions in database: \(allQuestions.count)")
        }
        
        previewQuestions = questions
        showQuestionPreview = true
    }
    
    private func clearDatabase() {
        // This would need to be implemented in QuestionDatabase
        print("🗑️ Clearing database...")
    }
    
    // MARK: - Helper Methods
    private func saveImageToDocuments(_ imageData: Data, questionId: String) -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesPath = documentsPath.appendingPathComponent("QuestionImages")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: imagesPath, withIntermediateDirectories: true)
        
        let imagePath = imagesPath.appendingPathComponent("\(questionId).jpg")
        try? imageData.write(to: imagePath)
        
        return imagePath.path
    }
    
    private func generateTags(for category: String) -> [String] {
        switch category {
        case "math":
            return ["numbers", "arithmetic", "problem-solving"]
        case "science":
            return ["nature", "experiments", "discovery"]
        case "reading":
            return ["language", "comprehension", "literature"]
        case "history":
            return ["past", "events", "historical"]
        case "geography":
            return ["world", "countries", "places"]
        case "art":
            return ["creativity", "colors", "artistic"]
        default:
            return ["general", "education"]
        }
    }
}

// MARK: - Question Preview View
struct QuestionPreviewView: View {
    let questions: [QuestionRecord]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            if questions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Questions Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Generate some questions first using the 'Generate Questions' button.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .navigationTitle("Question Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            } else {
                List(questions, id: \.id) { question in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(question.questionText)
                            .font(.headline)
                        
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            HStack {
                                Text("\(["A", "B", "C", "D"][index]): \(option)")
                                if index == question.correctAnswer {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        Text("Explanation: \(question.explanation)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if question.hasImage {
                            HStack {
                                Image(systemName: "photo")
                                Text("Has Image")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle("Question Preview (\(questions.count))")
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
}

#Preview {
    AdminToolView()
}
