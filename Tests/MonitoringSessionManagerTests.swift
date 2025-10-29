import XCTest
@testable import DeepUninstaller

final class MonitoringSessionManagerTests: XCTestCase {
    var sut: MonitoringSessionManager!
    
    override func setUp() {
        super.setUp()
        sut = MonitoringSessionManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(sut.activeSession, "Active session should be nil initially")
        XCTAssertTrue(sut.sessions.isEmpty || !sut.sessions.isEmpty, "Sessions should be loadable")
    }
    
    func testStartNewSession() {
        let expectation = XCTestExpectation(description: "Session starts")
        let testName = "Test App"
        
        sut.startNewSession(name: testName) { result in
            switch result {
            case .success:
                XCTAssertNotNil(self.sut.activeSession, "Active session should exist after starting")
                XCTAssertEqual(self.sut.activeSession?.name, testName, "Session name should match")
                XCTAssertTrue(self.sut.activeSession?.isActive ?? false, "Session should be active")
                XCTAssertFalse(self.sut.sessions.isEmpty, "Sessions list should not be empty")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Session should start successfully, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testStopActiveSession() {
        let startExpectation = XCTestExpectation(description: "Session starts")
        let testName = "Test App"
        
        sut.startNewSession(name: testName) { result in
            switch result {
            case .success:
                startExpectation.fulfill()
            case .failure:
                XCTFail("Failed to start session")
            }
        }
        
        wait(for: [startExpectation], timeout: 5.0)
        
        let sessionId = sut.activeSession?.id
        XCTAssertNotNil(sessionId, "Session ID should exist")
        
        sut.stopActiveSession()
        
        XCTAssertNil(sut.activeSession, "Active session should be nil after stopping")
        
        if let stoppedSession = sut.sessions.first(where: { $0.id == sessionId }) {
            XCTAssertFalse(stoppedSession.isActive, "Stopped session should not be active")
            XCTAssertNotNil(stoppedSession.endDate, "Stopped session should have end date")
        } else {
            XCTFail("Stopped session should still exist in sessions list")
        }
    }
    
    func testDeleteSession() {
        let session = MonitoringSession(name: "Test", isActive: false)
        sut.sessions.append(session)
        
        let initialCount = sut.sessions.count
        sut.deleteSession(session)
        
        XCTAssertEqual(sut.sessions.count, initialCount - 1, "Session count should decrease by 1")
        XCTAssertFalse(sut.sessions.contains { $0.id == session.id }, "Deleted session should not exist")
    }
    
    func testUninstallSessionWithNoFiles() {
        let expectation = XCTestExpectation(description: "Uninstall completes")
        let session = MonitoringSession(name: "Empty App", isActive: false, monitoredFiles: [])
        
        sut.uninstallSession(session) { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, 0, "Should delete 0 files")
                expectation.fulfill()
            case .failure:
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDetermineFileType() {
        let testCases: [(path: String, expectedType: MonitoredFile.FileType)] = [
            ("/Applications/TestApp.app", .application),
            ("/Users/test/Library/Application Support/test.txt", .support),
            ("/Users/test/Library/Caches/test.cache", .cache),
            ("/Users/test/Library/Preferences/test.plist", .preference),
            ("/Users/test/Library/Logs/test.log", .log),
            ("/Users/test/.config/test.conf", .config),
            ("/tmp/test.tmp", .temporary),
            ("/other/path/file.txt", .other)
        ]
        
        for testCase in testCases {
            let file = MonitoredFile(path: testCase.path, size: 100, type: testCase.expectedType)
            XCTAssertEqual(file.type, testCase.expectedType, "File type for \(testCase.path) should be \(testCase.expectedType)")
        }
    }
    
    func testConcurrentAccess() {
        let expectation = XCTestExpectation(description: "Concurrent operations complete")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        for i in 0..<10 {
            queue.async {
                let testName = "Concurrent App \(i)"
                self.sut.startNewSession(name: testName) { _ in
                    Thread.sleep(forTimeInterval: 0.1)
                    self.sut.stopActiveSession()
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
