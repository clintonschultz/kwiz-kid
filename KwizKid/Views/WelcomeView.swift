import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var showBrainIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButtons = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .opacity(showBrainIcon ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8), value: showBrainIcon)
                    
                    Text("KwizKid")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .opacity(showTitle ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.3), value: showTitle)
                    
                    Text("Learn & Have Fun!")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(showSubtitle ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: showSubtitle)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        store.dispatch(.navigateTo(.categorySelection))
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Start Learning")
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
                    .scaleEffect(showButtons ? 1.0 : 0.8)
                    .opacity(showButtons ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2), value: showButtons)
                    
                    Button(action: {
                        // Handle settings/preferences
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(24)
                    }
                    .scaleEffect(showButtons ? 1.0 : 0.8)
                    .opacity(showButtons ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.4), value: showButtons)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .onAppear {
            // Start the animation sequence
            withAnimation(.easeInOut(duration: 0.8)) {
                showBrainIcon = true
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                showTitle = true
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.6)) {
                showSubtitle = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2)) {
                showButtons = true
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppStore())
}
