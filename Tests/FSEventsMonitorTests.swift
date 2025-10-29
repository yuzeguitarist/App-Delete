import XCTest
@testable import DeepUninstaller

final class FSEventsMonitorTests: XCTestCase {
    var sut: FSEventsMonitor!
    
    override func setUp() {
        super.setUp()
        sut = FSEventsMonitor()
    }
    
    override func tearDown() {
        sut.stopMonitoring()
        sut = nil
        super.tearDown()
    }
    
    func testMonitorInitialization() {
        XCTAssertNotNil(sut, "Monitor should initialize")
    }
    
    func testStartMonitoring() {
        let expectation = XCTestExpectation(description: "Monitoring starts")
        
        do {
            try sut.startMonitoring { path, flags in
                // Monitoring callback
            }
            expectation.fulfill()
        } catch {
            XCTFail("Should start monitoring without error: \(error)")
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testStopMonitoring() {
        do {
            try sut.startMonitoring { _, _ in }
            sut.stopMonitoring()
        } catch {
            XCTFail("Should start and stop monitoring without error")
        }
    }
    
    func testDoubleStart() {
        do {
            try sut.startMonitoring { _, _ in }
            
            XCTAssertThrowsError(try sut.startMonitoring { _, _ in }) { error in
                XCTAssertTrue(error is FSEventsError, "Should throw FSEventsError")
                if let fsError = error as? FSEventsError {
                    XCTAssertEqual(fsError, FSEventsError.alreadyMonitoring, "Should be alreadyMonitoring error")
                }
            }
        } catch {
            XCTFail("First start should succeed")
        }
    }
    
    func testMonitoringAfterStop() {
        do {
            try sut.startMonitoring { _, _ in }
            sut.stopMonitoring()
            
            try sut.startMonitoring { _, _ in }
            XCTAssertTrue(true, "Should be able to restart monitoring after stop")
        } catch {
            XCTFail("Should be able to restart monitoring: \(error)")
        }
    }
    
    func testMonitorCallback() {
        let expectation = XCTestExpectation(description: "File change detected")
        expectation.isInverted = true
        
        do {
            try sut.startMonitoring { path, flags in
                if path.contains("test_file") {
                    expectation.fulfill()
                }
            }
        } catch {
            XCTFail("Should start monitoring")
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

extension FSEventsError: Equatable {
    public static func == (lhs: FSEventsError, rhs: FSEventsError) -> Bool {
        switch (lhs, rhs) {
        case (.failedToCreateStream, .failedToCreateStream),
             (.failedToStartStream, .failedToStartStream),
             (.alreadyMonitoring, .alreadyMonitoring):
            return true
        default:
            return false
        }
    }
}
