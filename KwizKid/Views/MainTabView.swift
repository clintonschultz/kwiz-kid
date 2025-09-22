import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab: CurrentTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Quiz Hub
            CategorySelectionView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(CurrentTab.home)
            
            // Progress & Achievements
            CustomProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(CurrentTab.progress)
            
            // Profile & User Info
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(CurrentTab.profile)
            
            // Settings
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(CurrentTab.settings)
        }
        .accentColor(.blue)
        .onChange(of: selectedTab) { newTab in
            store.dispatch(.selectTab(newTab))
        }
        .onAppear {
            selectedTab = store.state.selectedTab
        }
    }
}


#Preview {
    MainTabView()
        .environmentObject(AppStore())
}
