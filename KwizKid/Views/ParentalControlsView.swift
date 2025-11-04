import SwiftUI

struct ParentalControlsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var dailyTimeLimit: Int = 60
    @State private var contentFilter: Bool = true
    @State private var progressTracking: Bool = true
    @State private var notifications: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Time Management") {
                    VStack(alignment: .leading) {
                        Text("Daily Time Limit")
                            .font(.headline)
                        Text("\(dailyTimeLimit) minutes per day")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Slider(value: Binding(
                            get: { Double(dailyTimeLimit) },
                            set: { dailyTimeLimit = Int($0) }
                        ), in: 15...180, step: 15)
                        .accentColor(.blue)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Content Settings") {
                    Toggle("Content Filter", isOn: $contentFilter)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Toggle("Progress Tracking", isOn: $progressTracking)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Section("Notifications") {
                    Toggle("Learning Reminders", isOn: $notifications)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Section("Privacy") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Collection")
                            .font(.headline)
                        Text("We collect minimal data to improve your child's learning experience. No personal information is shared with third parties.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Parental Controls")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveSettings() {
        // Save parental control settings
        if var user = store.state.user {
            user.preferences.parentalControls.dailyTimeLimit = dailyTimeLimit
            user.preferences.parentalControls.contentFilter = contentFilter
            user.preferences.parentalControls.progressTracking = progressTracking
            user.preferences.parentalControls.notifications = notifications
            
            store.dispatch(.updateUserPreferences(user.preferences))
        }
    }
}

#Preview {
    ParentalControlsView()
        .environmentObject(AppStore())
}


