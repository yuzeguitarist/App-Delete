import Foundation

class StorageManager {
    private let sessionsFileName = "monitoring_sessions.json"
    
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
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    func loadSessions() -> [MonitoringSession] {
        guard FileManager.default.fileExists(atPath: sessionsFileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: sessionsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([MonitoringSession].self, from: data)
        } catch {
            print("Error loading sessions: \(error)")
            return []
        }
    }
}
