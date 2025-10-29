import XCTest
@testable import DeepUninstaller

final class UIFlowTests: XCTestCase {
    var sessionManager: MonitoringSessionManager!
    
    override func setUp() {
        super.setUp()
        sessionManager = MonitoringSessionManager()
    }
    
    override func tearDown() {
        sessionManager.stopActiveSession()
        for session in sessionManager.sessions {
            sessionManager.deleteSession(session)
        }
        sessionManager = nil
        super.tearDown()
    }
    
    func testNewSessionCreation() {
        let expectation = XCTestExpectation(description: "Session creation")
        
        sessionManager.startNewSession(name: "Test App") { result in
            switch result {
            case .success:
                XCTAssertNotNil(self.sessionManager.activeSession)
                XCTAssertEqual(self.sessionManager.activeSession?.name, "Test App")
                XCTAssertTrue(self.sessionManager.activeSession?.isActive ?? false)
                XCTAssertEqual(self.sessionManager.sessions.count, 1)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Session creation failed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testStopActiveSession() {
        let createExpectation = XCTestExpectation(description: "Session creation")
        
        sessionManager.startNewSession(name: "Test App") { result in
            if case .success = result {
                createExpectation.fulfill()
            }
        }
        
        wait(for: [createExpectation], timeout: 5.0)
        
        sessionManager.stopActiveSession()
        
        XCTAssertNil(sessionManager.activeSession)
        XCTAssertEqual(sessionManager.sessions.count, 1)
        XCTAssertFalse(sessionManager.sessions[0].isActive)
        XCTAssertNotNil(sessionManager.sessions[0].endDate)
    }
    
    func testCannotStartMultipleSessions() {
        let firstExpectation = XCTestExpectation(description: "First session creation")
        
        sessionManager.startNewSession(name: "First App") { result in
            if case .success = result {
                firstExpectation.fulfill()
            }
        }
        
        wait(for: [firstExpectation], timeout: 5.0)
        
        XCTAssertNotNil(sessionManager.activeSession)
        let firstSessionId = sessionManager.activeSession?.id
        
        let secondExpectation = XCTestExpectation(description: "Second session creation")
        
        sessionManager.startNewSession(name: "Second App") { result in
            if case .success = result {
                secondExpectation.fulfill()
            }
        }
        
        wait(for: [secondExpectation], timeout: 5.0)
        
        XCTAssertNotNil(sessionManager.activeSession)
        XCTAssertNotEqual(sessionManager.activeSession?.id, firstSessionId)
        XCTAssertEqual(sessionManager.activeSession?.name, "Second App")
    }
    
    func testDeleteSession() {
        let expectation = XCTestExpectation(description: "Session creation")
        
        sessionManager.startNewSession(name: "Test App") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        sessionManager.stopActiveSession()
        
        XCTAssertEqual(sessionManager.sessions.count, 1)
        let session = sessionManager.sessions[0]
        
        sessionManager.deleteSession(session)
        
        XCTAssertEqual(sessionManager.sessions.count, 0)
    }
    
    func testUninstallProgressTracking() {
        let createExpectation = XCTestExpectation(description: "Session creation")
        
        sessionManager.startNewSession(name: "Test App") { result in
            if case .success = result {
                createExpectation.fulfill()
            }
        }
        
        wait(for: [createExpectation], timeout: 5.0)
        
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        for i in 1...5 {
            let filePath = tempDir.appendingPathComponent("test\(i).txt")
            try? "Test content".write(to: filePath, atomically: true, encoding: .utf8)
        }
        
        Thread.sleep(forTimeInterval: 6.0)
        
        sessionManager.stopActiveSession()
        
        guard let session = sessionManager.sessions.first else {
            XCTFail("No session found")
            return
        }
        
        let progressExpectation = XCTestExpectation(description: "Progress updates")
        var progressUpdates: [UninstallProgress] = []
        
        sessionManager.uninstallSession(
            session,
            moveToTrash: false,
            progress: { progress in
                progressUpdates.append(progress)
            },
            completion: { result in
                progressExpectation.fulfill()
            }
        )
        
        wait(for: [progressExpectation], timeout: 10.0)
        
        XCTAssertGreaterThan(progressUpdates.count, 0)
        
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func testSessionPersistence() {
        let createExpectation = XCTestExpectation(description: "Session creation")
        
        sessionManager.startNewSession(name: "Test App") { result in
            if case .success = result {
                createExpectation.fulfill()
            }
        }
        
        wait(for: [createExpectation], timeout: 5.0)
        
        sessionManager.stopActiveSession()
        
        let originalSessionId = sessionManager.sessions[0].id
        
        let newManager = MonitoringSessionManager()
        
        XCTAssertEqual(newManager.sessions.count, sessionManager.sessions.count)
        XCTAssertTrue(newManager.sessions.contains { $0.id == originalSessionId })
        
        if let session = newManager.sessions.first(where: { $0.id == originalSessionId }) {
            newManager.deleteSession(session)
        }
    }
}
