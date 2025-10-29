import Foundation
import Combine
import AppKit
import os.log

struct UninstallError: Error, LocalizedError {
    let failedFiles: [(path: String, error: Error)]
    let successCount: Int
    
    var errorDescription: String? {
        "Failed to delete \(failedFiles.count) files. Successfully deleted \(successCount) files."
    }
    
    var detailedDescription: String {
        var details = "Successfully deleted \(successCount) files.\n\nFailed to delete \(failedFiles.count) files:\n\n"
        for (path, error) in failedFiles.prefix(10) {
            details += "• \(path)\n  Error: \(error.localizedDescription)\n\n"
        }
        if failedFiles.count > 10 {
            details += "... and \(failedFiles.count - 10) more files."
        }
        return details
    }
}

struct UninstallProgress {
    let current: Int
    let total: Int
    let currentFile: String
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
}

class MonitoringSessionManager: ObservableObject {
    @Published var sessions: [MonitoringSession] = []
    @Published var activeSession: MonitoringSession?
    
    private var fsEventsMonitor: FSEventsMonitor?
    private let storageManager = StorageManager()
    private var fileChangeQueue = Set<String>()
    private var saveTimer: Timer?
    private let syncQueue = DispatchQueue(label: "com.deepuninstaller.sessionmanager", qos: .userInitiated)
    private let logger = Logger(subsystem: "com.deepuninstaller.app", category: "MonitoringSessionManager")
    
    init() {
        loadSessions()
    }
    
    func startNewSession(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        stopActiveSession()
        
        let newSession = MonitoringSession(name: name)
        
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.fileChangeQueue.removeAll()
            
            DispatchQueue.main.async {
                self.activeSession = newSession
                self.sessions.insert(newSession, at: 0)
            }
            
            let monitor = FSEventsMonitor()
            do {
                try monitor.startMonitoring { [weak self] path, flags in
                    self?.handleFileChange(path: path, flags: flags)
                }
                
                DispatchQueue.main.async {
                    self.fsEventsMonitor = monitor
                    
                    self.saveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                        self?.saveActiveSession()
                    }
                    
                    self.saveSessions()
                    self.logger.info("Session '\(name)' started successfully")
                    completion(.success(()))
                }
            } catch {
                self.logger.error("Failed to start monitoring: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activeSession = nil
                    self.sessions.removeAll { $0.id == newSession.id }
                    completion(.failure(error))
                }
            }
        }
    }
    
    func stopActiveSession() {
        guard var session = activeSession else { return }
        
        saveTimer?.invalidate()
        saveTimer = nil
        
        fsEventsMonitor?.stopMonitoring()
        fsEventsMonitor = nil
        
        syncQueue.sync {
            saveActiveSessionInternal()
        }
        
        session.isActive = false
        session.endDate = Date()
        
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        }
        
        activeSession = nil
        saveSessions()
        logger.info("Session '\(session.name)' stopped")
    }
    
    func deleteSession(_ session: MonitoringSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }
    
    func uninstallSession(_ session: MonitoringSession, 
                          moveToTrash: Bool = true,
                          progress: ((UninstallProgress) -> Void)? = nil,
                          completion: @escaping (Result<Int, Error>) -> Void) {
        logger.info("Starting uninstall for session '\(session.name)' with \(session.monitoredFiles.count) files (moveToTrash: \(moveToTrash))")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var deletedCount = 0
            var failedFiles: [(path: String, error: Error)] = []
            
            let sortedFiles = session.monitoredFiles.sorted { file1, file2 in
                file1.path.components(separatedBy: "/").count > file2.path.components(separatedBy: "/").count
            }
            
            let totalFiles = sortedFiles.count
            
            for (index, file) in sortedFiles.enumerated() {
                let currentProgress = UninstallProgress(
                    current: index + 1,
                    total: totalFiles,
                    currentFile: file.path
                )
                
                DispatchQueue.main.async {
                    progress?(currentProgress)
                }
                
                do {
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: file.path) {
                        if moveToTrash {
                            try self.moveToTrash(path: file.path)
                        } else {
                            try fileManager.removeItem(atPath: file.path)
                        }
                        deletedCount += 1
                        self.logger.debug("Deleted: \(file.path)")
                    } else {
                        self.logger.debug("File not found (skipped): \(file.path)")
                    }
                } catch {
                    self.logger.error("Error deleting file \(file.path): \(error.localizedDescription)")
                    failedFiles.append((path: file.path, error: error))
                }
            }
            
            DispatchQueue.main.async {
                if !failedFiles.isEmpty {
                    let uninstallError = UninstallError(failedFiles: failedFiles, successCount: deletedCount)
                    self.logger.warning("Uninstall completed with \(failedFiles.count) errors")
                    completion(.failure(uninstallError))
                } else {
                    self.logger.info("Uninstall successful: \(deletedCount) files deleted")
                    self.deleteSession(session)
                    completion(.success(deletedCount))
                }
            }
        }
    }
    
    private func moveToTrash(path: String) throws {
        let url = URL(fileURLWithPath: path)
        
        if #available(macOS 11.0, *) {
            var recycleError: Error?
            let semaphore = DispatchSemaphore(value: 0)
            
            NSWorkspace.shared.recycle([url]) { (_, error) in
                recycleError = error
                semaphore.signal()
            }
            
            semaphore.wait()
            
            if let error = recycleError {
                self.logger.error("Failed to move to trash: \(error.localizedDescription)")
                throw error
            }
        } else {
            let fileManager = FileManager.default
            try fileManager.trashItem(at: url, resultingItemURL: nil)
        }
    }
    
    private func handleFileChange(path: String, flags: FSEventStreamEventFlags) {
        let isCreated = (flags & UInt32(kFSEventStreamEventFlagItemCreated)) != 0
        let isModified = (flags & UInt32(kFSEventStreamEventFlagItemModified)) != 0
        
        if isCreated || isModified {
            syncQueue.async { [weak self] in
                guard let self = self, self.activeSession != nil else { return }
                self.fileChangeQueue.insert(path)
            }
        }
    }
    
    private func saveActiveSession() {
        syncQueue.async { [weak self] in
            self?.saveActiveSessionInternal()
        }
    }
    
    private func saveActiveSessionInternal() {
        guard var session = activeSession else { return }
        
        let newFiles = fileChangeQueue.compactMap { path -> MonitoredFile? in
            let alreadyExists = session.monitoredFiles.contains { $0.path == path }
            guard !alreadyExists else { return nil }
            
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: path) else { return nil }
            
            var size: Int64 = 0
            if let attributes = try? fileManager.attributesOfItem(atPath: path) {
                size = attributes[.size] as? Int64 ?? 0
            }
            
            let fileType = determineFileType(path: path)
            
            return MonitoredFile(path: path, size: size, type: fileType)
        }
        
        guard !newFiles.isEmpty else { return }
        
        session.monitoredFiles.append(contentsOf: newFiles)
        fileChangeQueue.removeAll()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.sessions.firstIndex(where: { $0.id == session.id }) {
                self.sessions[index] = session
            }
            self.activeSession = session
            self.saveSessions()
            self.logger.debug("Saved \(newFiles.count) new files to active session")
        }
    }
    
    private func determineFileType(path: String) -> MonitoredFile.FileType {
        if path.hasPrefix("/Applications") && path.hasSuffix(".app") {
            return .application
        } else if path.contains("/Application Support") {
            return .support
        } else if path.contains("/Caches") {
            return .cache
        } else if path.contains("/Preferences") {
            return .preference
        } else if path.contains("/Logs") {
            return .log
        } else if path.contains("/.config") {
            return .config
        } else if path.hasPrefix("/tmp") {
            return .temporary
        } else {
            return .other
        }
    }
    
    private func saveSessions() {
        storageManager.saveSessions(sessions)
    }
    
    private func loadSessions() {
        sessions = storageManager.loadSessions()
    }
}
