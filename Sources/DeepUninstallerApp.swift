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
            
            CommandGroup(after: .newItem) {
                Button("New Monitoring Session") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowNewSessionSheet"), object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
                .disabled(sessionManager.activeSession != nil)
            }
        }
    }
}
