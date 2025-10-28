import SwiftUI

struct SessionListView: View {
    @EnvironmentObject var sessionManager: MonitoringSessionManager
    @Binding var selectedSession: MonitoringSession?
    @Binding var showNewSessionSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selectedSession) {
                if let activeSession = sessionManager.activeSession {
                    Section(header: Text("Active Monitoring")) {
                        SessionRow(session: activeSession)
                            .tag(activeSession)
                    }
                }
                
                if !sessionManager.sessions.filter({ !$0.isActive }).isEmpty {
                    Section(header: Text("Completed Sessions")) {
                        ForEach(sessionManager.sessions.filter { !$0.isActive }) { session in
                            SessionRow(session: session)
                                .tag(session)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        sessionManager.deleteSession(session)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            
            Divider()
            
            HStack(spacing: 12) {
                Button(action: {
                    showNewSessionSheet = true
                }) {
                    Label("New Monitoring", systemImage: "plus")
                }
                .disabled(sessionManager.activeSession != nil)
                
                if sessionManager.activeSession != nil {
                    Button(action: {
                        sessionManager.stopActiveSession()
                    }) {
                        Label("Stop", systemImage: "stop.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Deep Uninstaller")
    }
}

struct SessionRow: View {
    let session: MonitoringSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.name)
                    .font(.headline)
                
                if session.isActive {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 8))
                }
            }
            
            Text("\(session.monitoredFiles.count) files • \(session.formattedSize)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(session.formattedStartDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
