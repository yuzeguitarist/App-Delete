import XCTest
@testable import DeepUninstaller

final class MonitoringSessionTests: XCTestCase {
    
    func testSessionInitialization() {
        let session = MonitoringSession(name: "Test App")
        
        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.name, "Test App")
        XCTAssertNotNil(session.startDate)
        XCTAssertNil(session.endDate)
        XCTAssertTrue(session.isActive)
        XCTAssertTrue(session.monitoredFiles.isEmpty)
    }
    
    func testSessionWithCustomValues() {
        let startDate = Date()
        let endDate = Date().addingTimeInterval(3600)
        let files = [
            MonitoredFile(path: "/test1", size: 100, type: .application),
            MonitoredFile(path: "/test2", size: 200, type: .cache)
        ]
        
        let session = MonitoringSession(
            name: "Custom Session",
            startDate: startDate,
            endDate: endDate,
            isActive: false,
            monitoredFiles: files
        )
        
        XCTAssertEqual(session.name, "Custom Session")
        XCTAssertEqual(session.startDate, startDate)
        XCTAssertEqual(session.endDate, endDate)
        XCTAssertFalse(session.isActive)
        XCTAssertEqual(session.monitoredFiles.count, 2)
    }
    
    func testTotalSize() {
        let files = [
            MonitoredFile(path: "/test1", size: 1024, type: .application),
            MonitoredFile(path: "/test2", size: 2048, type: .cache),
            MonitoredFile(path: "/test3", size: 512, type: .preference)
        ]
        
        let session = MonitoringSession(name: "Size Test", monitoredFiles: files)
        
        XCTAssertEqual(session.totalSize, 3584, "Total size should be sum of all files")
    }
    
    func testTotalSizeWithEmptyFiles() {
        let session = MonitoringSession(name: "Empty Test")
        
        XCTAssertEqual(session.totalSize, 0, "Total size should be 0 for no files")
    }
    
    func testFormattedSize() {
        let files = [MonitoredFile(path: "/test", size: 1024, type: .application)]
        let session = MonitoringSession(name: "Format Test", monitoredFiles: files)
        
        let formattedSize = session.formattedSize
        XCTAssertFalse(formattedSize.isEmpty, "Formatted size should not be empty")
        XCTAssertTrue(formattedSize.contains("KB") || formattedSize.contains("bytes"), "Formatted size should contain unit")
    }
    
    func testFormattedStartDate() {
        let session = MonitoringSession(name: "Date Test")
        
        let formattedDate = session.formattedStartDate
        XCTAssertFalse(formattedDate.isEmpty, "Formatted start date should not be empty")
    }
    
    func testFormattedEndDate() {
        let session = MonitoringSession(name: "End Date Test")
        
        XCTAssertNil(session.formattedEndDate, "Formatted end date should be nil for active session")
        
        var modifiedSession = session
        modifiedSession.endDate = Date()
        
        XCTAssertNotNil(modifiedSession.formattedEndDate, "Formatted end date should exist after setting end date")
    }
    
    func testSessionCodable() throws {
        let files = [
            MonitoredFile(path: "/test1", size: 1024, type: .application),
            MonitoredFile(path: "/test2", size: 2048, type: .cache)
        ]
        
        let originalSession = MonitoringSession(
            name: "Codable Test",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            isActive: false,
            monitoredFiles: files
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalSession)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedSession = try decoder.decode(MonitoringSession.self, from: data)
        
        XCTAssertEqual(decodedSession.id, originalSession.id)
        XCTAssertEqual(decodedSession.name, originalSession.name)
        XCTAssertEqual(decodedSession.isActive, originalSession.isActive)
        XCTAssertEqual(decodedSession.monitoredFiles.count, originalSession.monitoredFiles.count)
        XCTAssertEqual(decodedSession.totalSize, originalSession.totalSize)
    }
    
    func testSessionIdentifiable() {
        let session1 = MonitoringSession(name: "Session 1")
        let session2 = MonitoringSession(name: "Session 2")
        
        XCTAssertNotEqual(session1.id, session2.id, "Different sessions should have different IDs")
    }
    
    func testSessionMutation() {
        var session = MonitoringSession(name: "Mutable Test")
        
        XCTAssertTrue(session.isActive)
        XCTAssertNil(session.endDate)
        
        session.isActive = false
        session.endDate = Date()
        
        XCTAssertFalse(session.isActive)
        XCTAssertNotNil(session.endDate)
    }
    
    func testAddingFilesToSession() {
        var session = MonitoringSession(name: "File Test")
        
        XCTAssertTrue(session.monitoredFiles.isEmpty)
        
        let file = MonitoredFile(path: "/test", size: 1024, type: .application)
        session.monitoredFiles.append(file)
        
        XCTAssertEqual(session.monitoredFiles.count, 1)
        XCTAssertEqual(session.totalSize, 1024)
    }
}
