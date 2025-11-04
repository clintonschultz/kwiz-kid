import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var learningReminders: Bool = true
    @State private var achievementAlerts: Bool = true
    @State private var progressUpdates: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Learning Reminders") {
                    Toggle("Daily Learning Reminders", isOn: $learningReminders)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    if learningReminders {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                }
                
                Section("Achievements") {
                    Toggle("Achievement Notifications", isOn: $achievementAlerts)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Text("Get notified when your child earns new badges and achievements")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Progress Updates") {
                    Toggle("Weekly Progress Reports", isOn: $progressUpdates)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Text("Receive weekly summaries of your child's learning progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notification Preferences") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quiet Hours")
                            .font(.headline)
                        Text("Notifications are automatically disabled during sleep hours (10 PM - 7 AM)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Notifications")
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
        // Save notification settings
        if var user = store.state.user {
            user.preferences.notifications.learningReminders = learningReminders
            user.preferences.notifications.achievementAlerts = achievementAlerts
            user.preferences.notifications.progressUpdates = progressUpdates
            user.preferences.notifications.reminderTime = reminderTime
            
            store.dispatch(.updateUserPreferences(user.preferences))
        }
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(AppStore())
}


