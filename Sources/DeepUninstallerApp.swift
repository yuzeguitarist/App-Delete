import SwiftUI

@main
struct DeepUninstallerApp: App {
    @StateObject private var sessionManager = MonitoringSessionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
