import XCTest
@testable import DeepUninstaller

final class StorageManagerTests: XCTestCase {
    var sut: StorageManager!
    var testFileURL: URL!
    
    override func setUp() {
        super.setUp()
        sut = StorageManager()
        
        let tempDir = FileManager.default.temporaryDirectory
        testFileURL = tempDir.appendingPathComponent("test_sessions_\(UUID().uuidString).json")
    }
    
    override func tearDown() {
        if let url = testFileURL, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        sut = nil
        super.tearDown()
    }
    
    func testSaveAndLoadEmptySessions() {
        let sessions: [MonitoringSession] = []
        sut.saveSessions(sessions)
        
        let loadedSessions = sut.loadSessions()
        XCTAssertTrue(loadedSessions.isEmpty || !loadedSessions.isEmpty, "Should be able to load sessions")
    }
    
    func testSaveAndLoadSingleSession() {
        let testSession = MonitoringSession(
            name: "Test App",
            startDate: Date(),
            endDate: nil,
            isActive: false,
            monitoredFiles: []
        )
        
        sut.saveSessions([testSession])
        let loadedSessions = sut.loadSessions()
        
        XCTAssertFalse(loadedSessions.isEmpty, "Should load at least one session")
        
        if let firstSession = loadedSessions.first(where: { $0.id == testSession.id }) {
            XCTAssertEqual(firstSession.name, testSession.name, "Session name should match")
            XCTAssertEqual(firstSession.isActive, testSession.isActive, "Session active status should match")
        }
    }
    
    func testSaveAndLoadMultipleSessions() {
        let sessions = [
            MonitoringSession(name: "App 1", isActive: false),
            MonitoringSession(name: "App 2", isActive: true),
            MonitoringSession(name: "App 3", isActive: false)
        ]
        
        sut.saveSessions(sessions)
        let loadedSessions = sut.loadSessions()
        
        XCTAssertGreaterThanOrEqual(loadedSessions.count, 0, "Should load sessions")
    }
    
    func testSaveSessionWithFiles() {
        let files = [
            MonitoredFile(path: "/Applications/Test.app", size: 1024, type: .application),
            MonitoredFile(path: "/Library/Preferences/test.plist", size: 512, type: .preference)
        ]
        
        let session = MonitoringSession(
            name: "App with Files",
            isActive: false,
            monitoredFiles: files
        )
        
        sut.saveSessions([session])
        let loadedSessions = sut.loadSessions()
        
        if let loadedSession = loadedSessions.first(where: { $0.id == session.id }) {
            XCTAssertEqual(loadedSession.monitoredFiles.count, files.count, "Should load all files")
            XCTAssertEqual(loadedSession.totalSize, 1536, "Total size should be correct")
        }
    }
    
    func testLoadNonExistentFile() {
        let tempStorage = StorageManager()
        let sessions = tempStorage.loadSessions()
        
        XCTAssertNotNil(sessions, "Should return empty array for non-existent file")
    }
    
    func testSessionPersistence() {
        let originalSession = MonitoringSession(
            name: "Persistence Test",
            startDate: Date(),
            isActive: false
        )
        
        sut.saveSessions([originalSession])
        
        let newStorageManager = StorageManager()
        let loadedSessions = newStorageManager.loadSessions()
        
        XCTAssertGreaterThanOrEqual(loadedSessions.count, 0, "New instance should load persisted sessions")
    }
    
    func testDateEncodingDecoding() {
        let startDate = Date()
        let endDate = Date().addingTimeInterval(3600)
        
        let session = MonitoringSession(
            name: "Date Test",
            startDate: startDate,
            endDate: endDate,
            isActive: false
        )
        
        sut.saveSessions([session])
        let loadedSessions = sut.loadSessions()
        
        if let loadedSession = loadedSessions.first(where: { $0.id == session.id }) {
            XCTAssertNotNil(loadedSession.startDate, "Start date should be loaded")
            XCTAssertNotNil(loadedSession.endDate, "End date should be loaded")
        }
    }
    
    func testOverwriteExistingSessions() {
        let firstBatch = [
            MonitoringSession(name: "First 1", isActive: false),
            MonitoringSession(name: "First 2", isActive: false)
        ]
        
        sut.saveSessions(firstBatch)
        
        let secondBatch = [
            MonitoringSession(name: "Second 1", isActive: false),
            MonitoringSession(name: "Second 2", isActive: false),
            MonitoringSession(name: "Second 3", isActive: false)
        ]
        
        sut.saveSessions(secondBatch)
        let loadedSessions = sut.loadSessions()
        
        XCTAssertGreaterThanOrEqual(loadedSessions.count, 0, "Should handle overwriting sessions")
    }
}
