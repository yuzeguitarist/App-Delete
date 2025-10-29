import XCTest
@testable import DeepUninstaller

final class MonitoredFileTests: XCTestCase {
    
    func testFileInitialization() {
        let file = MonitoredFile(
            path: "/Applications/Test.app",
            size: 1024,
            type: .application
        )
        
        XCTAssertEqual(file.path, "/Applications/Test.app")
        XCTAssertEqual(file.size, 1024)
        XCTAssertEqual(file.type, .application)
        XCTAssertNotNil(file.id)
        XCTAssertNotNil(file.createdAt)
    }
    
    func testFileTypeDisplayNames() {
        XCTAssertEqual(MonitoredFile.FileType.application.displayName, "Applications")
        XCTAssertEqual(MonitoredFile.FileType.support.displayName, "Application Support")
        XCTAssertEqual(MonitoredFile.FileType.cache.displayName, "Caches")
        XCTAssertEqual(MonitoredFile.FileType.preference.displayName, "Preferences")
        XCTAssertEqual(MonitoredFile.FileType.log.displayName, "Logs")
        XCTAssertEqual(MonitoredFile.FileType.config.displayName, "Configuration Files")
        XCTAssertEqual(MonitoredFile.FileType.temporary.displayName, "Temporary Files")
        XCTAssertEqual(MonitoredFile.FileType.other.displayName, "Other Files")
    }
    
    func testFileEquality() {
        let id = UUID()
        let file1 = MonitoredFile(id: id, path: "/test1", size: 100, type: .application)
        let file2 = MonitoredFile(id: id, path: "/test2", size: 200, type: .cache)
        
        XCTAssertEqual(file1, file2, "Files with same ID should be equal")
    }
    
    func testFileInequality() {
        let file1 = MonitoredFile(path: "/test1", size: 100, type: .application)
        let file2 = MonitoredFile(path: "/test1", size: 100, type: .application)
        
        XCTAssertNotEqual(file1, file2, "Files with different IDs should not be equal")
    }
    
    func testFileHashability() {
        let file1 = MonitoredFile(path: "/test", size: 100, type: .application)
        let file2 = MonitoredFile(path: "/test", size: 100, type: .application)
        
        var set = Set<MonitoredFile>()
        set.insert(file1)
        set.insert(file2)
        
        XCTAssertEqual(set.count, 2, "Different files should be distinct in set")
    }
    
    func testFileTypeAllCases() {
        let allCases = MonitoredFile.FileType.allCases
        
        XCTAssertEqual(allCases.count, 8, "Should have all 8 file types")
        XCTAssertTrue(allCases.contains(.application))
        XCTAssertTrue(allCases.contains(.support))
        XCTAssertTrue(allCases.contains(.cache))
        XCTAssertTrue(allCases.contains(.preference))
        XCTAssertTrue(allCases.contains(.log))
        XCTAssertTrue(allCases.contains(.config))
        XCTAssertTrue(allCases.contains(.temporary))
        XCTAssertTrue(allCases.contains(.other))
    }
    
    func testFileCodable() throws {
        let originalFile = MonitoredFile(
            path: "/Applications/Test.app",
            size: 2048,
            type: .application
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalFile)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedFile = try decoder.decode(MonitoredFile.self, from: data)
        
        XCTAssertEqual(decodedFile.id, originalFile.id)
        XCTAssertEqual(decodedFile.path, originalFile.path)
        XCTAssertEqual(decodedFile.size, originalFile.size)
        XCTAssertEqual(decodedFile.type, originalFile.type)
    }
}
