import Foundation
import CoreServices

class FSEventsMonitor {
    private var eventStream: FSEventStreamRef?
    private let monitoredPaths: [String]
    private var onFileChange: ((String, FSEventStreamEventFlags) -> Void)?
    private var isMonitoring = false
    
    init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        self.monitoredPaths = [
            "/Applications",
            "\(homeDirectory)/Library/Application Support",
            "\(homeDirectory)/Library/Caches",
            "\(homeDirectory)/Library/Preferences",
            "\(homeDirectory)/Library/Logs",
            "\(homeDirectory)/Library/WebKit",
            "\(homeDirectory)/.config",
            "/tmp"
        ]
    }
    
    func startMonitoring(onChange: @escaping (String, FSEventStreamEventFlags) -> Void) {
        guard !isMonitoring else { return }
        
        self.onFileChange = onChange
        
        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        let callback: FSEventStreamCallback = { (
            streamRef: ConstFSEventStreamRef,
            clientCallBackInfo: UnsafeMutableRawPointer?,
            numEvents: Int,
            eventPaths: UnsafeMutableRawPointer,
            eventFlags: UnsafePointer<FSEventStreamEventFlags>,
            eventIds: UnsafePointer<FSEventStreamEventId>
        ) in
            guard let info = clientCallBackInfo else { return }
            let monitor = Unmanaged<FSEventsMonitor>.fromOpaque(info).takeUnretainedValue()
            
            let paths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String]
            
            for i in 0..<numEvents {
                let path = paths[i]
                let flags = eventFlags[i]
                
                if monitor.shouldIncludePath(path) {
                    monitor.onFileChange?(path, flags)
                }
            }
        }
        
        let pathsToWatch = monitoredPaths as CFArray
        
        eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.1,
            UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagNoDefer)
        )
        
        guard let stream = eventStream else {
            print("Failed to create FSEventStream")
            return
        }
        
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        
        if FSEventStreamStart(stream) {
            isMonitoring = true
            print("FSEvents monitoring started for paths: \(monitoredPaths)")
        } else {
            print("Failed to start FSEventStream")
        }
    }
    
    func stopMonitoring() {
        guard isMonitoring, let stream = eventStream else { return }
        
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        
        eventStream = nil
        isMonitoring = false
        onFileChange = nil
        
        print("FSEvents monitoring stopped")
    }
    
    private func shouldIncludePath(_ path: String) -> Bool {
        let excludedPatterns = [
            ".DS_Store",
            ".Spotlight-",
            ".Trashes",
            "/.DocumentRevisions-",
            "/.fseventsd",
            "/com.apple.",
            "/.TemporaryItems",
            "/.apdisk"
        ]
        
        for pattern in excludedPatterns {
            if path.contains(pattern) {
                return false
            }
        }
        
        return true
    }
    
    deinit {
        stopMonitoring()
    }
}
