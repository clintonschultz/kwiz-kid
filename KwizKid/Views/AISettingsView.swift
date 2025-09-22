import SwiftUI

struct AISettingsView: View {
    @StateObject private var viewModel = AISettingsViewModel()
    @State private var showingTestResults = false
    @State private var testResults: String = ""
    
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
                            
                            if viewModel.selectedProvider == provider {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedProvider = provider
                        }
                    }
                }
                
                // API Configuration
                if viewModel.selectedProvider != .mock {
                    Section(header: Text("API Configuration")) {
                        if viewModel.selectedProvider == .openAI {
                            SecureField("OpenAI API Key", text: $viewModel.openAIKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else if viewModel.selectedProvider == .claude {
                            SecureField("Claude API Key", text: $viewModel.claudeKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else if viewModel.selectedProvider == .awsBedrock {
                            VStack(spacing: 12) {
                                SecureField("AWS Access Key", text: $viewModel.awsAccessKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                SecureField("AWS Secret Key", text: $viewModel.awsSecretKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("AWS Region", text: $viewModel.awsRegion)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                }
                
                // Test Connection
                Section(header: Text("Test Connection")) {
                    Button(action: {
                        Task {
                            let success = await viewModel.testConnection()
                            testResults = success ? "✅ Connection successful!" : "❌ Connection failed. Please check your API keys."
                            showingTestResults = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "wifi")
                            Text("Test Connection")
                        }
                    }
                    .disabled(viewModel.selectedProvider == .mock)
                    
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
                            await viewModel.generateTestQuestions()
                        }
                    }) {
                        HStack {
                            if viewModel.isGeneratingQuestions {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "brain.head.profile")
                            }
                            Text("Generate Test Questions")
                        }
                    }
                    .disabled(viewModel.isGeneratingQuestions)
                    
                    if viewModel.questionsGenerated > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Generation Results:")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            
                            Text("Questions Generated: \(viewModel.questionsGenerated)")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("Generation Time: \(String(format: "%.2f", viewModel.lastGenerationTime))s")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // AI Features
                Section(header: Text("AI Features")) {
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(
                            icon: "brain.head.profile",
                            title: "Dynamic Question Generation",
                            description: "AI creates unique questions for each quiz session"
                        )
                        
                        FeatureRow(
                            icon: "shield.checkered",
                            title: "Child Safety Filtering",
                            description: "Automatic content moderation for age-appropriate questions"
                        )
                        
                        FeatureRow(
                            icon: "person.2.fill",
                            title: "Age-Appropriate Language",
                            description: "Questions adapt to your child's age and reading level"
                        )
                        
                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Difficulty Adjustment",
                            description: "Questions automatically adjust based on performance"
                        )
                    }
                }
                
                // Save Button
                Section {
                    Button(action: {
                        viewModel.saveSettings()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Settings")
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - AI Provider Info
struct AIProviderInfoView: View {
    let provider: AIProviderType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForProvider(provider))
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text(provider.displayName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Spacer()
            }
            
            Text(provider.description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
            
            if provider != .mock {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Setup Instructions:")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    Text(setupInstructions(for: provider))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func iconForProvider(_ provider: AIProviderType) -> String {
        switch provider {
        case .openAI:
            return "brain.head.profile"
        case .claude:
            return "person.circle.fill"
        case .awsBedrock:
            return "cloud.fill"
        case .mock:
            return "gear"
        }
    }
    
    private func setupInstructions(for provider: AIProviderType) -> String {
        switch provider {
        case .openAI:
            return "1. Get an API key from OpenAI\n2. Enter your API key above\n3. Test the connection"
        case .claude:
            return "1. Get an API key from Anthropic\n2. Enter your API key above\n3. Test the connection"
        case .awsBedrock:
            return "1. Set up AWS Bedrock access\n2. Enter your AWS credentials\n3. Test the connection"
        case .mock:
            return "Mock provider for development and testing"
        }
    }
}

#Preview {
    AISettingsView()
}
