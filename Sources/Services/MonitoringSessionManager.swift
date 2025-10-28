import Foundation
import Combine

class MonitoringSessionManager: ObservableObject {
    @Published var sessions: [MonitoringSession] = []
    @Published var activeSession: MonitoringSession?
    
    private var fsEventsMonitor: FSEventsMonitor?
    private let storageManager = StorageManager()
    private var fileChangeQueue = Set<String>()
    private var saveTimer: Timer?
    
    init() {
        loadSessions()
    }
    
    func startNewSession(name: String) {
        stopActiveSession()
        
        let newSession = MonitoringSession(name: name)
        activeSession = newSession
        sessions.insert(newSession, at: 0)
        
        fsEventsMonitor = FSEventsMonitor()
        fsEventsMonitor?.startMonitoring { [weak self] path, flags in
            self?.handleFileChange(path: path, flags: flags)
        }
        
        saveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.saveActiveSession()
        }
        
        saveSessions()
    }
    
    func stopActiveSession() {
        guard var session = activeSession else { return }
        
        fsEventsMonitor?.stopMonitoring()
        fsEventsMonitor = nil
        
        saveTimer?.invalidate()
        saveTimer = nil
        
        session.isActive = false
        session.endDate = Date()
        
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        }
        
        activeSession = nil
        saveSessions()
    }
    
    func deleteSession(_ session: MonitoringSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }
    
    func uninstallSession(_ session: MonitoringSession, completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var deletedCount = 0
            var lastError: Error?
            
            let sortedFiles = session.monitoredFiles.sorted { file1, file2 in
                file1.path.components(separatedBy: "/").count > file2.path.components(separatedBy: "/").count
            }
            
            for file in sortedFiles {
                do {
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: file.path) {
                        try fileManager.removeItem(atPath: file.path)
                        deletedCount += 1
                    }
                } catch {
                    print("Error deleting file \(file.path): \(error)")
                    lastError = error
                }
            }
            
            DispatchQueue.main.async {
                if let error = lastError {
                    completion(.failure(error))
                } else {
                    self.deleteSession(session)
                    completion(.success(deletedCount))
                }
            }
        }
    }
    
    private func handleFileChange(path: String, flags: FSEventStreamEventFlags) {
        guard activeSession != nil else { return }
        
        let isCreated = (flags & UInt32(kFSEventStreamEventFlagItemCreated)) != 0
        let isModified = (flags & UInt32(kFSEventStreamEventFlagItemModified)) != 0
        
        if isCreated || isModified {
            fileChangeQueue.insert(path)
        }
    }
    
    private func saveActiveSession() {
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
        
        session.monitoredFiles.append(contentsOf: newFiles)
        fileChangeQueue.removeAll()
        
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        }
        activeSession = session
        
        saveSessions()
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
