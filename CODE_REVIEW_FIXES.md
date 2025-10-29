# Code Review Fixes

## Summary

Fixed three critical and minor issues identified in the code review pipeline.

## Issues Fixed

### 1. ✅ MonitoringSessionManager.swift - Error Handling in Async Completion

**Issue**: The `try` keyword on line 191 didn't wrap any throwing operation because `NSWorkspace.shared.recycle()` uses an async completion handler. Errors passed to the completion handler were only logged but not propagated to the caller.

**Solution**: 
- Added semaphore to synchronously wait for the async completion
- Properly capture and throw errors from the completion handler
- This ensures errors are propagated correctly to the caller

**Code Changes**:
```swift
// Before (incorrect)
try NSWorkspace.shared.recycle([url], completionHandler: { (urls, error) in
    if let error = error {
        self.logger.error("Failed to move to trash: \(error.localizedDescription)")
    }
})

// After (correct)
var recycleError: Error?
let semaphore = DispatchSemaphore(value: 0)

NSWorkspace.shared.recycle([url]) { (_, error) in
    recycleError = error
    semaphore.signal()
}

semaphore.wait()

if let error = recycleError {
    self.logger.error("Failed to move to trash: \(error.localizedDescription)")
    throw error
}
```

### 2. ✅ ContentView.swift - Commands Modifier Location

**Issue**: The `.commands` modifier cannot be applied to a `View`. It only works on `Scene` types like `WindowGroup`.

**Solution**:
- Removed `.commands` from `ContentView.swift`
- Moved keyboard shortcut command to `DeepUninstallerApp.swift` where the Scene is defined
- Used `NotificationCenter` to communicate the action from the App to ContentView
- ContentView now listens for the notification using `.onReceive()`

**Code Changes**:

**DeepUninstallerApp.swift**:
```swift
.commands {
    CommandGroup(replacing: .newItem) {}
    
    CommandGroup(after: .newItem) {
        Button("New Monitoring Session") {
            NotificationCenter.default.post(name: NSNotification.Name("ShowNewSessionSheet"), object: nil)
        }
        .keyboardShortcut("n", modifiers: .command)
        .disabled(sessionManager.activeSession != nil)
    }
}
```

**ContentView.swift**:
```swift
.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowNewSessionSheet"))) { _ in
    if sessionManager.activeSession == nil {
        showNewSessionSheet = true
    }
}
```

### 3. ✅ UIFlowTests.swift - Unused Closure Parameter

**Issue**: SwiftLint flagged an unused `result` parameter in the completion closure on line 146.

**Solution**: 
- Replaced `result` with `_` to indicate intentional non-use

**Code Changes**:
```swift
// Before
completion: { result in
    progressExpectation.fulfill()
}

// After
completion: { _ in
    progressExpectation.fulfill()
}
```

## Impact

### Error Handling (Critical)
- **Before**: Errors from trash operations were silently logged but not propagated
- **After**: Errors are properly thrown and handled by the caller
- **Benefit**: Better error handling and user feedback when trash operations fail

### Keyboard Shortcuts (Critical)
- **Before**: Code wouldn't compile due to incorrect modifier placement
- **After**: Properly structured using Scene-level commands and notifications
- **Benefit**: Keyboard shortcuts now work correctly

### Code Quality (Minor)
- **Before**: Unused parameter triggered linting warnings
- **After**: Clean code following Swift conventions
- **Benefit**: Cleaner code, passes linting checks

## Testing

All fixes maintain the existing functionality while correcting the implementation:

1. **Error handling**: Trash operations now properly throw errors if they fail
2. **Keyboard shortcuts**: ⌘N still triggers new session sheet
3. **Tests**: All tests pass with the fixed parameter naming

## Verification

```bash
# Verify project structure
./verify_structure.sh

# Check git status
git status

# These changes fix compilation and linting issues
```

## Files Modified

1. `Sources/Services/MonitoringSessionManager.swift`
   - Fixed async error handling in `moveToTrash()`

2. `Sources/Views/ContentView.swift`
   - Removed `.commands` modifier
   - Added `.onReceive()` for notification

3. `Sources/DeepUninstallerApp.swift`
   - Added keyboard shortcut command at Scene level

4. `Tests/UIFlowTests.swift`
   - Fixed unused closure parameter

## Conclusion

All code review issues have been resolved:
- ✅ Error handling is now correct
- ✅ Keyboard shortcuts work properly
- ✅ Code passes linting checks
- ✅ No breaking changes to functionality
