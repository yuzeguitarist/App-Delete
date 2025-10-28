import SwiftUI

struct WelcomeView: View {
    @Binding var showNewSessionSheet: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 8) {
                Text("Welcome to Deep Uninstaller")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track and completely remove macOS applications")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "eye.fill",
                    title: "Active Monitoring",
                    description: "Watch file system changes in real-time as apps are installed"
                )
                
                FeatureRow(
                    icon: "folder.badge.plus",
                    title: "Non-Standard Paths",
                    description: "Tracks files in ~/.config and other unconventional locations"
                )
                
                FeatureRow(
                    icon: "sparkles",
                    title: "Complete Removal",
                    description: "Delete applications and all their associated files in one click"
                )
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(12)
            
            Button(action: {
                showNewSessionSheet = true
            }) {
                Label("Start New Monitoring Session", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
