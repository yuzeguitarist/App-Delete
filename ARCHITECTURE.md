# Deep Uninstaller Architecture

This document provides a detailed technical overview of Deep Uninstaller's architecture, design patterns, and implementation details.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interface                        │
│                      (SwiftUI Views)                         │
│  ┌──────────┐  ┌─────────┐  ┌──────────┐  ┌─────────────┐ │
│  │ Welcome  │  │ Session │  │  Session │  │    New      │ │
│  │   View   │  │  List   │  │  Detail  │  │   Session   │ │
│  └──────────┘  └─────────┘  └──────────┘  └─────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
                          │ @EnvironmentObject
                          │ @Published updates
┌─────────────────────────▼───────────────────────────────────┐
│                 MonitoringSessionManager                     │
│                    (Business Logic Layer)                    │
│  • Session lifecycle management                              │
│  • Coordinates FSEvents monitoring                           │
│  • Handles file change events                                │
│  • Manages session persistence                               │
│  • Executes uninstall operations                             │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
│  FSEvents    │  │   Storage   │  │    Data     │
│   Monitor    │  │   Manager   │  │   Models    │
│              │  │             │  │             │
│ • File       │  │ • JSON      │  │ • Session   │
│   system     │  │   encode/   │  │ • Files     │
│   events     │  │   decode    │  │             │
└──────────────┘  └─────────────┘  └─────────────┘
       │
       │ FSEvents API
       │
┌──────▼───────────────────────────────────────────────────────┐
│              macOS Core Services Framework                    │
│                    (FSEvents API)                            │
└──────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. User Interface Layer

#### View Hierarchy

```
ContentView (Root)
├── NavigationSplitView
│   ├── Sidebar: SessionListView
│   │   ├── Active Session Section
│   │   ├── Completed Sessions Section
│   │   └── Action Buttons (New, Stop)
│   │
│   └── Detail: SessionDetailView / WelcomeView
│       ├── Session Header (name, stats)
│       ├── File List (categorized)
│       ├── Search Bar
│       └── Uninstall Button
│
└── Sheet: NewSessionSheet
    ├── Name Input
    ├── Permission Info
    └── Action Buttons
```

#### State Management

**@EnvironmentObject:**
```swift
MonitoringSessionManager (shared across all views)
  ├── @Published sessions: [MonitoringSession]
  └── @Published activeSession: MonitoringSession?
```

**@State (Local):**
- UI-specific state (search text, selected items, sheet presentation)
- Temporary form data
- Loading/progress indicators

**Data Flow:**
```
User Action → State Change → UI Update
     ↓
SessionManager Method
     ↓
Business Logic
     ↓
@Published Property Change
     ↓
SwiftUI View Re-render
```

### 2. Business Logic Layer

#### MonitoringSessionManager

**Responsibilities:**
1. Session lifecycle (create, start, stop, delete)
2. FSEvents coordination
3. File change processing
4. Data persistence orchestration
5. Uninstall execution

**State Machine:**
```
[No Session] ──(startNew)──> [Active Session]
                                    │
                                    │ (monitoring)
                                    │
                              [Collecting Files]
                                    │
                                    │ (stop)
                                    ▼
                            [Completed Session]
                                    │
                            (uninstall) │ (delete)
                                    ▼
                              [Removed]
```

**Threading Model:**
- Main Thread: UI updates, @Published notifications
- Background Queue: File operations, uninstall
- FSEvents RunLoop: File system event processing

### 3. Service Layer

#### FSEventsMonitor

**Core Functionality:**

```c
FSEventStreamCreate(
    allocator,
    callback,          // Called on each file event
    context,           // Self reference
    pathsToWatch,      // 8 monitored directories
    sinceWhen,         // kFSEventStreamEventIdSinceNow
    latency: 0.1,      // 100ms event batching
    flags: kFSEventStreamCreateFlagFileEvents
)
```

**Event Processing Pipeline:**
```
File System Change
    ↓
FSEvents Kernel Notification
    ↓
FSEventStreamCallback
    ↓
Filter (shouldIncludePath)
    ↓
Callback to SessionManager
    ↓
Add to fileChangeQueue
    ↓
Batch Processing (5s timer)
    ↓
Add to session.monitoredFiles
```

**Monitored Paths:**
```swift
let paths = [
    "/Applications",                           // Main apps
    "~/Library/Application Support",           // App data
    "~/Library/Caches",                        // Cache
    "~/Library/Preferences",                   // Prefs
    "~/Library/Logs",                          // Logs
    "~/Library/WebKit",                        // Web data
    "~/.config",                               // ⭐ Key differentiator
    "/tmp"                                     // Temp files
]
```

**Filtering Logic:**
```swift
Excluded Patterns:
  - .DS_Store              // macOS metadata
  - .Spotlight-*           // Search index
  - .Trashes              // Trash metadata
  - .DocumentRevisions-*   // Versions
  - .fseventsd            // FSEvents metadata
  - com.apple.*           // System files
  - .TemporaryItems       // Temp
  - .apdisk               // AirPort Disk
```

#### StorageManager

**Persistence Strategy:**

```
Location: ~/Library/Application Support/DeepUninstaller/
File: monitoring_sessions.json

Format: JSON
  ├── Array of MonitoringSession
  │   ├── id: UUID
  │   ├── name: String
  │   ├── dates: ISO8601
  │   ├── isActive: Bool
  │   └── monitoredFiles: Array
  │       ├── path: String
  │       ├── size: Int64
  │       ├── createdAt: ISO8601
  │       └── type: Enum
```

**Encoding/Decoding:**
```swift
JSONEncoder/JSONDecoder
  ├── dateEncodingStrategy: .iso8601
  ├── keyEncodingStrategy: .useDefaultKeys
  └── Error handling: Fallback to empty array
```

### 4. Data Model Layer

#### MonitoringSession

```swift
struct MonitoringSession: Identifiable, Codable {
    // Identity
    let id: UUID
    let name: String
    
    // Lifecycle
    let startDate: Date
    var endDate: Date?
    var isActive: Bool
    
    // Data
    var monitoredFiles: [MonitoredFile]
    
    // Computed Properties
    var totalSize: Int64
    var formattedSize: String
    var formattedStartDate: String
    var formattedEndDate: String?
}
```

#### MonitoredFile

```swift
struct MonitoredFile: Identifiable, Codable {
    let id: UUID
    let path: String
    let size: Int64
    let createdAt: Date
    let type: FileType
    
    enum FileType: String, Codable {
        case application
        case support
        case cache
        case preference
        case log
        case config      // ⭐ ~/.config files
        case temporary
        case other
    }
}
```

**File Type Detection:**
```swift
func determineFileType(path: String) -> FileType {
    if path.hasPrefix("/Applications") && path.hasSuffix(".app")
        → .application
    else if path.contains("/Application Support")
        → .support
    else if path.contains("/Caches")
        → .cache
    else if path.contains("/Preferences")
        → .preference
    else if path.contains("/Logs")
        → .log
    else if path.contains("/.config")    // ⭐
        → .config
    else if path.hasPrefix("/tmp")
        → .temporary
    else
        → .other
}
```

## Key Algorithms

### 1. File Change Batching

**Problem:** FSEvents fires rapidly; need to batch changes to avoid excessive processing.

**Solution:**
```swift
var fileChangeQueue: Set<String> = []
var saveTimer: Timer?

// On file change
func handleFileChange(path: String, flags: Flags) {
    fileChangeQueue.insert(path)  // Set prevents duplicates
}

// Every 5 seconds
saveTimer = Timer.scheduledTimer(...) {
    let newFiles = fileChangeQueue
        .filter { !alreadyExists($0) }
        .compactMap { createMonitoredFile($0) }
    
    session.monitoredFiles.append(contentsOf: newFiles)
    fileChangeQueue.removeAll()
    saveToDisk()
}
```

**Benefits:**
- Reduces disk I/O
- Prevents duplicate tracking
- Better performance with high-frequency changes

### 2. Depth-First Deletion

**Problem:** Deleting parent before child causes errors.

**Solution:**
```swift
// Sort by path depth (deepest first)
let sorted = files.sorted { file1, file2 in
    let depth1 = file1.path.components(separatedBy: "/").count
    let depth2 = file2.path.components(separatedBy: "/").count
    return depth1 > depth2
}

// Delete deepest files first
for file in sorted {
    FileManager.default.removeItem(atPath: file.path)
}
```

**Example:**
```
Delete order:
1. /Applications/App.app/Contents/MacOS/binary
2. /Applications/App.app/Contents/MacOS/
3. /Applications/App.app/Contents/
4. /Applications/App.app/
```

**Benefits:**
- No "directory not empty" errors
- Proper cleanup of nested structures
- Handles symbolic links correctly

### 3. File Type Categorization

**Problem:** Need to organize thousands of files meaningfully.

**Solution:**
```swift
// 1. Detect type during tracking
let type = determineFileType(path)
let file = MonitoredFile(path: path, ..., type: type)

// 2. Group in UI
ForEach(FileType.allCases) { type in
    let filesOfType = files.filter { $0.type == type }
    if !filesOfType.isEmpty {
        Section(header: Text(type.displayName)) {
            ForEach(filesOfType) { file in
                FileRow(file)
            }
        }
    }
}
```

**Benefits:**
- Logical organization
- Easy to review by category
- Better user understanding

## Design Patterns

### 1. Observer Pattern (via Combine)

```swift
class MonitoringSessionManager: ObservableObject {
    @Published var sessions: [MonitoringSession]
    @Published var activeSession: MonitoringSession?
}

// Views automatically update when @Published changes
struct SessionListView: View {
    @EnvironmentObject var manager: MonitoringSessionManager
    
    var body: some View {
        List(manager.sessions) { session in
            // Auto-updates on manager.sessions change
        }
    }
}
```

### 2. Strategy Pattern (File Type Detection)

Different strategies for determining file type based on path.

### 3. Command Pattern (Uninstall Operation)

```swift
func uninstallSession(_ session, completion: (Result<Int, Error>) -> Void) {
    // Command encapsulates entire uninstall operation
    DispatchQueue.global(qos: .userInitiated).async {
        // Execute
        let result = performDeletion(session.files)
        
        // Callback with result
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
```

### 4. Repository Pattern (StorageManager)

Abstracts data persistence away from business logic.

```swift
protocol Storage {
    func save(_ sessions: [Session])
    func load() -> [Session]
}

class StorageManager: Storage {
    // JSON implementation
}

// Could add:
// class CloudStorageManager: Storage { }
// class CoreDataStorageManager: Storage { }
```

## Performance Characteristics

### Time Complexity

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Add file to queue | O(1) | Set insertion |
| Check if file exists | O(n) | Linear search in array |
| Sort for deletion | O(n log n) | Comparison sort |
| Delete files | O(n) | Linear iteration |
| Save to disk | O(n) | JSON encoding |
| Load from disk | O(n) | JSON decoding |
| UI rendering | O(n) | SwiftUI List |

### Space Complexity

| Component | Size | Notes |
|-----------|------|-------|
| Session in memory | ~1-2 MB | 1000 files |
| FSEvents monitor | ~100 KB | Static allocation |
| File change queue | ~10-100 KB | Depends on change rate |
| Total app memory | ~5-10 MB | For typical usage |

### I/O Operations

| Operation | Frequency | Size |
|-----------|-----------|------|
| Session auto-save | Every 5s (when active) | 5-50 KB |
| Session load | On app launch | 5-50 KB per session |
| File metadata read | On file detection | ~1 KB per file |
| File deletion | On uninstall | N/A |

## Security Architecture

### Permission Model

```
User
  ↓
  Grants Full Disk Access
  ↓
Deep Uninstaller
  ↓
  ├─> Read file metadata (size, dates)
  ├─> Monitor file system events
  └─> Delete tracked files
```

### Trust Boundaries

```
┌─────────────────────────────────────┐
│   Trusted: Deep Uninstaller Code    │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Untrusted: User Input         │ │
│  │ - Session names              │ │
│  │ - File paths (from FSEvents) │ │
│  └───────────────────────────────┘ │
│                                     │
│  Validation & Sanitization         │
└─────────────────────────────────────┘
```

### Attack Surface

**Potential Risks:**
1. Malicious file paths from FSEvents
2. User deleting wrong session
3. Race conditions during uninstall
4. Corrupted session data

**Mitigations:**
1. Path filtering and validation
2. Confirmation dialogs
3. Synchronous deletion with locks
4. Error handling and fallbacks

## Scalability Considerations

### File Count Limits

| Scenario | File Count | Behavior |
|----------|-----------|----------|
| Typical app | 50-500 | Optimal |
| Large app | 500-2000 | Good |
| Electron app | 2000-5000 | Acceptable |
| Extreme | 5000+ | May slow down |

### Optimization Strategies

**For Large File Counts:**
1. Lazy loading in UI (List with pagination)
2. Background file metadata fetching
3. Incremental UI updates
4. Index session data for fast search

**For Multiple Sessions:**
1. Limit sessions kept in memory
2. Lazy load session details
3. Archive old sessions
4. Implement session cleanup

## Testing Strategy

### Unit Tests (Planned)

```swift
// MonitoringSessionManagerTests
- testStartNewSession()
- testStopActiveSession()
- testHandleFileChange()
- testDetermineFileType()
- testDepthFirstDeletion()

// StorageManagerTests
- testSaveSessions()
- testLoadSessions()
- testCorruptedDataHandling()

// FSEventsMonitorTests
- testStartMonitoring()
- testStopMonitoring()
- testShouldIncludePath()
- testEventFiltering()
```

### Integration Tests (Planned)

```swift
// End-to-end workflows
- testCompleteMonitoringSession()
- testFileTrackingAccuracy()
- testUninstallProcess()
- testPersistenceAcrossSessions()
```

### Manual Test Cases

See DEVELOPMENT.md for detailed manual testing procedures.

## Future Architectural Improvements

### 1. Plugin System

```swift
protocol FileMonitorPlugin {
    func shouldMonitorPath(_ path: String) -> Bool
    func didDetectFile(_ file: MonitoredFile)
    func willDeleteFile(_ file: MonitoredFile) -> Bool
}

// Allow users to extend functionality
```

### 2. Event Sourcing

```swift
// Track all events, not just current state
enum SessionEvent {
    case started(name: String)
    case fileAdded(path: String)
    case stopped
    case uninstalled
}

// Benefits: Audit trail, undo capability, replay
```

### 3. Reactive Streams

```swift
// More sophisticated event processing
let fileChanges: AnyPublisher<FileChange, Never>
let sessionUpdates: AnyPublisher<Session, Never>

// Better handling of async operations
```

## Conclusion

Deep Uninstaller's architecture prioritizes:
- **Simplicity**: Clean separation of concerns
- **Reliability**: Robust error handling
- **Performance**: Efficient algorithms and data structures
- **Maintainability**: Clear code organization
- **Extensibility**: Easy to add new features

The use of native Apple frameworks (FSEvents, SwiftUI, Combine) ensures optimal performance and future compatibility.
