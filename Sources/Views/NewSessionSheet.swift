import SwiftUI

struct NewSessionSheet: View {
    @EnvironmentObject var sessionManager: MonitoringSessionManager
    @Binding var isPresented: Bool
    @State private var sessionName = ""
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Start New Monitoring Session")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter the name of the application you're about to install or run.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Application Name")
                    .font(.headline)
                
                TextField("e.g., Cursor", text: $sessionName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Important")
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• This app requires Full Disk Access to monitor file changes")
                    Text("• After starting monitoring, install or run the application")
                    Text("• Stop monitoring once you've finished testing the app")
                    Text("• The tool will track all files created in monitored directories")
                }
                .font(.callout)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Check Permissions") {
                    showingPermissionAlert = true
                }
                .buttonStyle(.bordered)
                
                Button("Start Monitoring") {
                    startMonitoring()
                }
                .buttonStyle(.borderedProminent)
                .disabled(sessionName.trimmingCharacters(in: .whitespaces).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 600, height: 500)
        .alert("Full Disk Access Required", isPresented: $showingPermissionAlert) {
            Button("Open System Settings") {
                openSystemSettings()
            }
            Button("Continue Anyway") {
                showingPermissionAlert = false
            }
        } message: {
            Text("For complete monitoring, this app needs Full Disk Access.\n\n1. Open System Settings > Privacy & Security > Full Disk Access\n2. Enable access for Deep Uninstaller\n3. Restart the app")
        }
    }
    
    private func startMonitoring() {
        let trimmedName = sessionName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        sessionManager.startNewSession(name: trimmedName)
        isPresented = false
    }
    
    private func openSystemSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }
}
