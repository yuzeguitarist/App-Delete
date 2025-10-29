# Development Guide

This guide is for developers who want to understand and contribute to Deep Uninstaller's codebase.

## Architecture Overview

Deep Uninstaller follows a clean architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│           SwiftUI Views (UI Layer)          │
│  - ContentView, SessionListView, etc.       │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│     MonitoringSessionManager (Business)     │
│  - Session lifecycle management             │
│  - Coordinates between monitoring & storage │
└─────────────────┬───────────────────────────┘
                  │
        ┌─────────┴──────────┐
        │                    │
┌───────▼─────────┐  ┌──────▼────────┐
│  FSEventsMonitor│  │StorageManager │
│  - File system  │  │- Persistence  │
│    monitoring   │  │- JSON I/O     │
└─────────────────┘  └───────────────┘
```

## Core Components

### 1. Models (`Models/`)

#### MonitoringSession
- **Purpose**: Represents a monitoring session with all tracked files
- **Key Properties**:
  - `id`: Unique identifier (UUID)
  - `name`: User-friendly session name
  - `startDate`/`endDate`: Session timeframe
  - `isActive`: Whether monitoring is ongoing
  - `monitoredFiles`: Array of tracked files
- **Computed Properties**:
  - `formattedStartDate`/`formattedEndDate`: Human-readable dates
  - `totalSize`: Sum of all file sizes
  - `formattedSize`: Human-readable size

#### MonitoredFile
- **Purpose**: Represents a single tracked file/directory
- **Key Properties**:
  - `path`: Absolute file system path
  - `size`: File size in bytes
  - `createdAt`: When file was detected
  - `type`: File category (application, cache, config, etc.)
- **File Types**:
  - `.application`: Main app bundles
  - `.support`: Application Support files
  - `.cache`: Cache directories
  - `.preference`: Preferences/settings
  - `.log`: Log files
  - `.config`: Files in ~/.config
  - `.temporary`: Temporary files
  - `.other`: Uncategorized

### 2. Services (`Services/`)

#### FSEventsMonitor
- **Purpose**: Wraps macOS FSEvents API for file system monitoring
- **Key Methods**:
  - `startMonitoring(onChange:)`: Begins monitoring with callback
  - `stopMonitoring()`: Stops monitoring and cleans up
  - `shouldIncludePath(_:)`: Filters out system noise
- **Implementation Details**:
  - Uses Core Services FSEvents API
  - Monitors 8 key directories
  - Filters `.DS_Store`, Spotlight, etc.
  - Runs on main run loop
  - Event latency: 0.1 seconds
  - Flags: `kFSEventStreamCreateFlagFileEvents` for file-level events

**Monitored Paths:**
```swift
/Applications
~/Library/Application Support
~/Library/Caches
~/Library/Preferences
~/Library/Logs
~/Library/WebKit
~/.config
/tmp
```

**Excluded Patterns:**
- `.DS_Store`
- `.Spotlight-*`
- `.Trashes`
- `.DocumentRevisions-*`
- `.fseventsd`
- `com.apple.*`
- `.TemporaryItems`
- `.apdisk`

#### MonitoringSessionManager
- **Purpose**: Manages all monitoring sessions and coordinates operations
- **Key Responsibilities**:
  - Session lifecycle (start/stop)
  - File change handling
  - Session persistence
  - Uninstall operations
- **Key Methods**:
  - `startNewSession(name:)`: Creates and starts monitoring
  - `stopActiveSession()`: Finalizes current session
  - `deleteSession(_:)`: Removes session from list
  - `uninstallSession(_:completion:)`: Deletes all tracked files
- **Implementation Details**:
  - Uses `@Published` for SwiftUI reactivity
  - Batches file changes with `fileChangeQueue`
  - Auto-saves every 5 seconds during monitoring
  - Performs depth-first deletion (deepest files first)

#### StorageManager
- **Purpose**: Handles session data persistence
- **Key Methods**:
  - `saveSessions(_:)`: Writes sessions to JSON
  - `loadSessions()`: Reads sessions from disk
- **Storage Location**:
  ```
  ~/Library/Application Support/DeepUninstaller/monitoring_sessions.json
  ```
- **Format**: JSON with ISO8601 date encoding

### 3. Views (`Views/`)

#### ContentView
- **Purpose**: Root view with navigation split layout
- **Structure**: Sidebar (sessions) + Detail (session info)

#### SessionListView
- **Purpose**: Sidebar showing all sessions
- **Features**:
  - Active session section
  - Completed sessions section
  - New/Stop monitoring buttons
  - Context menu for deletion

#### SessionDetailView
- **Purpose**: Detailed view of a single session
- **Features**:
  - Session statistics
  - File list categorized by type
  - Search/filter functionality
  - Uninstall button with confirmation
  - Shows real-time updates for active sessions

#### NewSessionSheet
- **Purpose**: Modal dialog for creating new sessions
- **Features**:
  - Session name input
  - Permission guidance
  - Link to system settings
  - Validation

#### WelcomeView
- **Purpose**: Empty state when no session selected
- **Features**:
  - Feature highlights
  - Quick start button

## Data Flow

### Starting Monitoring

```
User clicks "New Monitoring"
  ↓
NewSessionSheet appears
  ↓
User enters name and confirms
  ↓
MonitoringSessionManager.startNewSession(name:)
  ↓
Creates MonitoringSession with isActive=true
  ↓
Initializes FSEventsMonitor
  ↓
FSEventsMonitor.startMonitoring(onChange:)
  ↓
File system events → handleFileChange()
  ↓
Files added to fileChangeQueue
  ↓
Timer fires every 5s → saveActiveSession()
  ↓
Files added to session.monitoredFiles
  ↓
Session saved to disk
  ↓
UI updates via @Published
```

### Stopping Monitoring

```
User clicks "Stop"
  ↓
MonitoringSessionManager.stopActiveSession()
  ↓
FSEventsMonitor.stopMonitoring()
  ↓
Timer invalidated
  ↓
Session marked isActive=false
  ↓
Session.endDate = Date()
  ↓
Session saved
  ↓
UI updates
```

### Uninstalling

```
User clicks "Uninstall Completely"
  ↓
Confirmation dialog shown
  ↓
User confirms
  ↓
MonitoringSessionManager.uninstallSession(_:completion:)
  ↓
Background queue
  ↓
Files sorted by depth (deepest first)
  ↓
For each file: FileManager.removeItem(atPath:)
  ↓
Success/error counted
  ↓
Main queue: completion called
  ↓
Session deleted from list
  ↓
UI updated
```

## Key Design Decisions

### 1. Why FSEvents Instead of fswatch?

- **Native Integration**: Direct API access, no external dependencies
- **Performance**: Lower overhead, better resource usage
- **Reliability**: Backed by Apple's file system infrastructure
- **File-Level Events**: Can track individual file changes, not just directory changes

### 2. Why Depth-First Deletion?

Files are deleted from deepest to shallowest to:
- Avoid deleting parent directories before children
- Handle nested structures correctly
- Reduce chances of "directory not empty" errors

### 3. Why 5-Second Save Interval?

Balance between:
- **Too Frequent**: Excessive disk I/O, performance impact
- **Too Infrequent**: Risk of data loss if app crashes
- **5 Seconds**: Good compromise for most use cases

### 4. Why Single Active Session?

- **Simplicity**: Easier to understand for users
- **Clarity**: Clear which files belong to which app
- **Resource Usage**: Lower memory and CPU impact
- **UX**: Prevents confusion about overlapping sessions

### 5. Why No Automatic Backup?

- **Scope**: MVP focuses on core monitoring/uninstall
- **Trust**: Users should review files before deleting
- **Complexity**: Backup management adds significant complexity
- **Future**: Can be added as optional feature

## Testing Strategies

### Manual Testing

1. **Monitoring Test**:
   ```
   1. Start monitoring session
   2. Install test app (e.g., free app from web)
   3. Launch and configure app
   4. Stop monitoring
   5. Verify files detected in expected categories
   ```

2. **Uninstall Test**:
   ```
   1. Select completed session
   2. Review file list
   3. Confirm uninstall
   4. Verify app and files removed
   5. Check for orphaned files
   ```

3. **Permission Test**:
   ```
   1. Disable Full Disk Access
   2. Start monitoring
   3. Install app
   4. Verify files in protected locations not tracked
   5. Re-enable access
   6. Verify complete tracking
   ```

### Recommended Test Apps

- **Electron Apps**: Visual Studio Code, Slack, Discord
- **Cross-Platform**: Firefox, VLC, Transmission
- **Native macOS**: Any small utility
- **Config-Heavy**: Apps that use ~/.config

### Edge Cases to Test

- App installed before monitoring started
- Monitoring stopped during file operations
- App with thousands of files
- App creating files in unusual locations
- Uninstall with app still running
- Multiple rapid start/stop cycles
- Disk space full during monitoring
- Permission changes mid-session

## Performance Considerations

### Memory Usage

- Sessions kept in memory while app runs
- Large file lists (1000+ files) use ~1-2 MB
- FSEvents uses minimal memory (~100 KB)

### CPU Usage

- FSEvents monitoring: <1% CPU
- UI updates: negligible
- File deletion: varies with file count

### Disk I/O

- Session saves: ~5-50 KB per save
- Auto-save every 5 seconds during monitoring
- Minimal read I/O (only on app launch)

## Security Considerations

### Full Disk Access

Required for:
- Reading files in ~/Library/*
- Monitoring protected directories
- Deleting system-protected files

Risks:
- App has broad file system access
- Could theoretically access any file
- Requires user trust

Mitigations:
- Clear permission explanation
- Open source code
- No network access
- No telemetry
- Auditable behavior

### File Deletion Safety

Protections:
- Confirmation dialog before deletion
- File list preview
- No access to /System
- Filters system files
- Depth-first deletion

Risks:
- User error (deleting wrong session)
- No undo mechanism
- Permanent deletion

Mitigations:
- Clear UI warnings
- Session naming
- Detailed file preview
- Explicit confirmation

## Future Enhancements

### Planned Features

1. **Export/Import**:
   - Export sessions as JSON
   - Share sessions between Macs
   - Backup session data

2. **CLI Interface**:
   ```bash
   deepuninstaller start "AppName"
   deepuninstaller stop
   deepuninstaller list
   deepuninstaller uninstall "AppName"
   ```

3. **Backup System**:
   - Optional backup before deletion
   - Restore capability
   - Configurable backup location

4. **Advanced Filtering**:
   - Regex patterns
   - Size thresholds
   - Custom exclude rules

5. **Analytics**:
   - File type statistics
   - Size breakdowns
   - Timeline visualization

### Technical Debt

- Add unit tests for core services
- Add UI tests
- Implement error recovery
- Add logging system
- Improve error messages
- Add crash reporting (opt-in)

## Debugging

### Console Logs

Monitor relevant logs:
```bash
log stream --predicate 'process == "DeepUninstaller"' --level debug
```

### Common Issues

**FSEvents not firing:**
- Check Full Disk Access
- Verify monitored paths exist
- Check Console for SIP restrictions

**Files not deleted:**
- Check file permissions
- Verify app is quit
- Look for locked files

**High memory usage:**
- Check session file count
- Look for memory leaks
- Profile with Instruments

## Resources

- [FSEvents Programming Guide](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/FSEvents_ProgGuide/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [macOS File System](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/)

## Getting Help

- Check existing issues on GitHub
- Review Console.app for errors
- Test with verbose logging
- Create minimal reproducible examples
- Include system information in bug reports

---

This guide is a living document. Please update it as the codebase evolves!
