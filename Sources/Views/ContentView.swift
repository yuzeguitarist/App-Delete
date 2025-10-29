import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: MonitoringSessionManager
    @State private var selectedSession: MonitoringSession?
    @State private var showNewSessionSheet = false
    
    var body: some View {
        NavigationSplitView {
            SessionListView(
                selectedSession: $selectedSession,
                showNewSessionSheet: $showNewSessionSheet
            )
        } detail: {
            if let session = selectedSession {
                SessionDetailView(session: session)
            } else {
                WelcomeView(showNewSessionSheet: $showNewSessionSheet)
            }
        }
        .sheet(isPresented: $showNewSessionSheet) {
            NewSessionSheet(isPresented: $showNewSessionSheet)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Monitoring Session") {
                    if sessionManager.activeSession == nil {
                        showNewSessionSheet = true
                    }
                }
                .keyboardShortcut("n", modifiers: .command)
                .disabled(sessionManager.activeSession != nil)
            }
        }
    }
}
