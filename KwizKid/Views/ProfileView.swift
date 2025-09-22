import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingEditProfile = false
    @State private var showingParentalControls = false
    @State private var showingAccountSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderView()
                    
                    // Account Information
                    AccountInfoSection()
                    
                    // Learning Preferences
                    LearningPreferencesSection()
                    
                    // Parental Controls
                    ParentalControlsSection()
                    
                    // Account Actions
                    AccountActionsSection()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingParentalControls) {
            ParentalControlsView()
        }
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView()
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(store.state.user?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(store.state.user?.name ?? "Guest User")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Age \(store.state.user?.age ?? 0)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Account Information Section
struct AccountInfoSection: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                InfoRow(title: "Name", value: store.state.user?.name ?? "Not set")
                InfoRow(title: "Age", value: "\(store.state.user?.age ?? 0) years old")
                InfoRow(title: "Member Since", value: "January 2024")
                InfoRow(title: "Subscription", value: "Premium")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Learning Preferences Section
struct LearningPreferencesSection: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Preferences")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                PreferenceRow(
                    icon: "brain.head.profile",
                    title: "Difficulty Level",
                    value: store.state.user?.preferences.difficulty.displayName ?? "Easy",
                    color: .blue
                )
                
                PreferenceRow(
                    icon: "clock.fill",
                    title: "Session Length",
                    value: "\(store.state.user?.preferences.sessionLength ?? 15) minutes",
                    color: .green
                )
                
                PreferenceRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound Effects",
                    value: store.state.user?.preferences.soundEffects == true ? "On" : "Off",
                    color: .orange
                )
                
                PreferenceRow(
                    icon: "paintbrush.fill",
                    title: "Theme",
                    value: "Colorful",
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
}

// MARK: - Parental Controls Section
struct ParentalControlsSection: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Parental Controls")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Manage") {
                    // Handle parental controls
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                ControlRow(
                    icon: "clock.fill",
                    title: "Daily Time Limit",
                    value: "\(store.state.user?.preferences.parentalControls.dailyTimeLimit ?? 60) minutes",
                    isEnabled: true
                )
                
                ControlRow(
                    icon: "shield.checkered",
                    title: "Content Filtering",
                    value: "Strict",
                    isEnabled: true
                )
                
                ControlRow(
                    icon: "bell.fill",
                    title: "Progress Notifications",
                    value: "Daily",
                    isEnabled: true
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
}

// MARK: - Account Actions Section
struct AccountActionsSection: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Actions")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ActionButton(
                    icon: "pencil.circle.fill",
                    title: "Edit Profile",
                    subtitle: "Update your information",
                    color: .blue
                ) {
                    // Handle edit profile
                }
                
                ActionButton(
                    icon: "gear.circle.fill",
                    title: "Account Settings",
                    subtitle: "Manage your account",
                    color: .gray
                ) {
                    // Handle account settings
                }
                
                ActionButton(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "Get help and contact us",
                    color: .green
                ) {
                    // Handle help
                }
                
                ActionButton(
                    icon: "arrow.right.square.fill",
                    title: "Sign Out",
                    subtitle: "Sign out of your account",
                    color: .red
                ) {
                    // Handle sign out
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
}

// MARK: - Supporting Views

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

struct PreferenceRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

struct ControlRow: View {
    let icon: String
    let title: String
    let value: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isEnabled ? .green : .gray)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sheet Views

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Edit Profile")
                .navigationTitle("Edit Profile")
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


struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Account Settings")
                .navigationTitle("Account Settings")
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

#Preview {
    ProfileView()
        .environmentObject(AppStore())
}