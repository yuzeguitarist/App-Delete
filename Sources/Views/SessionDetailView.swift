import SwiftUI

struct SessionDetailView: View {
    @EnvironmentObject var sessionManager: MonitoringSessionManager
    let session: MonitoringSession
    @State private var showingUninstallConfirmation = false
    @State private var showingUninstallResult = false
    @State private var uninstallResultMessage = ""
    @State private var searchText = ""
    
    var filteredFiles: [MonitoredFile] {
        if searchText.isEmpty {
            return session.monitoredFiles
        }
        return session.monitoredFiles.filter { $0.path.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        Label("\(session.monitoredFiles.count) files", systemImage: "doc.fill")
                        Label(session.formattedSize, systemImage: "externaldrive.fill")
                        
                        if session.isActive {
                            HStack(spacing: 4) {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 8))
                                Text("Monitoring")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !session.isActive {
                    Button(action: {
                        showingUninstallConfirmation = true
                    }) {
                        Label("Uninstall Completely", systemImage: "trash.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.large)
                }
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Monitored Files")
                        .font(.headline)
                    
                    Spacer()
                    
                    TextField("Search files...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                }
                .padding()
                
                if filteredFiles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: session.isActive ? "magnifyingglass" : "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text(session.isActive ? "Monitoring for file changes..." : "No files recorded")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if session.isActive {
                            Text("Install or run the application to track its files")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(MonitoredFile.FileType.allCases, id: \.self) { fileType in
                            let filesOfType = filteredFiles.filter { $0.type == fileType }
                            if !filesOfType.isEmpty {
                                Section(header: Text(fileType.displayName)) {
                                    ForEach(filesOfType) { file in
                                        FileRow(file: file)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to completely uninstall \(session.name)?",
            isPresented: $showingUninstallConfirmation,
            titleVisibility: .visible
        ) {
            Button("Uninstall and Delete All Files", role: .destructive) {
                performUninstall()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \(session.monitoredFiles.count) files (\(session.formattedSize)). This action cannot be undone.")
        }
        .alert("Uninstall Result", isPresented: $showingUninstallResult) {
            Button("OK") {}
        } message: {
            Text(uninstallResultMessage)
        }
    }
    
    private func performUninstall() {
        sessionManager.uninstallSession(session) { result in
            switch result {
            case .success(let count):
                uninstallResultMessage = "Successfully deleted \(count) files."
                showingUninstallResult = true
            case .failure(let error):
                if let uninstallError = error as? UninstallError {
                    uninstallResultMessage = uninstallError.detailedDescription
                } else {
                    uninstallResultMessage = "Error during uninstall: \(error.localizedDescription)"
                }
                showingUninstallResult = true
            }
        }
    }
}

struct FileRow: View {
    let file: MonitoredFile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(file.path)
                .font(.system(.body, design: .monospaced))
            
            HStack {
                Text(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(file.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

extension MonitoredFile.FileType: CaseIterable {
    static var allCases: [MonitoredFile.FileType] {
        [.application, .support, .cache, .preference, .log, .config, .temporary, .other]
    }
    
    var displayName: String {
        switch self {
        case .application:
            return "Applications"
        case .support:
            return "Application Support"
        case .cache:
            return "Caches"
        case .preference:
            return "Preferences"
        case .log:
            return "Logs"
        case .config:
            return "Configuration Files"
        case .temporary:
            return "Temporary Files"
        case .other:
            return "Other Files"
        }
    }
}
