import SwiftUI

struct AISettingsView: View {
    @EnvironmentObject var aiConfig: AIConfiguration
    @State private var selectedProvider: AIProviderType
    @State private var apiKey: String = ""
    @State private var contentModerationLevel: ContentModerationLevel
    @State private var testTopic: String = "Space"
    @State private var testQuestionResult: String = "No test run yet."
    @State private var isTestingConnection = false
    @State private var isGeneratingTestQuestion = false
    @State private var showingTestResults = false
    @State private var testResults: String = ""
    
    // MARK: - Initializer
    init() {
        _selectedProvider = State(initialValue: .openAI)
        _contentModerationLevel = State(initialValue: .strict)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // AI Provider Selection
                Section(header: Text("AI Provider")) {
                    ForEach(AIProviderType.allCases, id: \.self) { provider in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(provider.displayName)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                
                                Text(provider.description)
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedProvider == provider {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedProvider = provider
                            aiConfig.setProvider(provider)
                        }
                    }
                }
                
                // API Configuration
                if selectedProvider != .mock {
                    Section(header: Text("API Configuration")) {
                        if selectedProvider == .openAI {
                            SecureField("OpenAI API Key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: apiKey) { newKey in
                                    aiConfig.saveAPIKey(newKey, for: selectedProvider)
                                }
                        } else if selectedProvider == .claude {
                            SecureField("Claude API Key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: apiKey) { newKey in
                                    aiConfig.saveAPIKey(newKey, for: selectedProvider)
                                }
                        } else if selectedProvider == .bedrock {
                            VStack(spacing: 12) {
                                SecureField("AWS Access Key", text: $apiKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("AWS Region", text: $apiKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                }
                
                // Test Connection
                Section(header: Text("Test Connection")) {
                    Button(action: {
                        Task {
                            let success = await testConnection()
                            testResults = success ? "✅ Connection successful!" : "❌ Connection failed. Please check your API keys."
                            showingTestResults = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "wifi")
                            Text("Test Connection")
                        }
                    }
                    .disabled(selectedProvider == .mock || isTestingConnection)
                    
                    if isTestingConnection {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Testing connection...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if showingTestResults {
                        Text(testResults)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(testResults.contains("✅") ? .green : .red)
                    }
                }
                
                // Generate Test Questions
                Section(header: Text("Test Question Generation")) {
                    Button(action: {
                        Task {
                            await generateTestQuestions()
                        }
                    }) {
                        HStack {
                            if isGeneratingTestQuestion {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "brain.head.profile")
                            }
                            Text("Generate Test Questions")
                        }
                    }
                    .disabled(isGeneratingTestQuestion || selectedProvider == .mock)
                    
                    TextField("Test Topic (e.g., 'Space')", text: $testTopic)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !testQuestionResult.isEmpty && testQuestionResult != "No test run yet." {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Test Results:")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(testQuestionResult)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Content Moderation
                Section(header: Text("Content Moderation")) {
                    Picker("Level", selection: $contentModerationLevel) {
                        ForEach(ContentModerationLevel.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .onChange(of: contentModerationLevel) { newLevel in
                        aiConfig.setContentModerationLevel(newLevel)
                    }
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            selectedProvider = aiConfig.currentProvider
            contentModerationLevel = aiConfig.getContentModerationLevel()
            apiKey = aiConfig.getAPIKey(for: selectedProvider) ?? ""
        }
    }
    
    // MARK: - Private Methods
    private func testConnection() async -> Bool {
        isTestingConnection = true
        defer { isTestingConnection = false }
        
        do {
            let success = try await aiConfig.testConnection(for: selectedProvider)
            return success
        } catch {
            print("Connection test failed: \(error)")
            return false
        }
    }
    
    private func generateTestQuestions() async {
        isGeneratingTestQuestion = true
        defer { isGeneratingTestQuestion = false }
        
        do {
            let questions = try await AIQuestionGenerator.shared.generateQuestions(
                for: testTopic,
                difficulty: .easy,
                ageRange: AgeRange(min: 6, max: 8),
                count: 1
            )
            
            if let question = questions.first {
                testQuestionResult = "Generated Question: \(question.text)\nOptions: \(question.options.joined(separator: ", "))\nCorrect: \(question.options[question.correctAnswer])"
            } else {
                testQuestionResult = "No question generated."
            }
        } catch {
            testQuestionResult = "Generation error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AISettingsView()
        .environmentObject(AIConfiguration.shared)
}