import Foundation
import os.log

class StorageManager {
    private let sessionsFileName = "monitoring_sessions.json"
    private let logger = Logger(subsystem: "com.deepuninstaller.app", category: "StorageManager")
    
    private var sessionsFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("DeepUninstaller", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        
        return appDirectory.appendingPathComponent(sessionsFileName)
    }
    
    func saveSessions(_ sessions: [MonitoringSession]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessions)
            try data.write(to: sessionsFileURL)
            logger.debug("Saved \(sessions.count) sessions to disk")
        } catch {
            logger.error("Error saving sessions: \(error.localizedDescription)")
        }
    }
    
    func loadSessions() -> [MonitoringSession] {
        guard FileManager.default.fileExists(atPath: sessionsFileURL.path) else {
            logger.info("No sessions file found, starting fresh")
            return []
        }
        
        do {
            let data = try Data(contentsOf: sessionsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let sessions = try decoder.decode([MonitoringSession].self, from: data)
            logger.info("Loaded \(sessions.count) sessions from disk")
            return sessions
        } catch {
            logger.error("Error loading sessions: \(error.localizedDescription)")
            return []
        }
    }
}
