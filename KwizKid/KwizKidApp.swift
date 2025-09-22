import SwiftUI

@main
struct KwizKidApp: App {
    @StateObject private var store = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
