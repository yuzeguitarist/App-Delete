# macOS Compatibility Testing Guide

## Overview

This document outlines the testing procedures to ensure Deep Uninstaller works correctly across different macOS versions.

## Supported Versions

- macOS 13.0 (Ventura) - Minimum supported version
- macOS 14.0 (Sonoma)
- macOS 15.0 (Sequoia)

## Testing Checklist

### Core Functionality Tests

For each supported macOS version, verify the following:

#### 1. Monitoring Session Creation
- [ ] Can create a new monitoring session
- [ ] Session name is properly stored
- [ ] Active monitoring indicator appears
- [ ] FSEvents monitoring starts successfully

#### 2. File System Monitoring
- [ ] Files created in `/Applications/` are detected
- [ ] Files in `~/Library/Application Support/` are tracked
- [ ] Cache files in `~/Library/Caches/` are captured
- [ ] Preferences in `~/Library/Preferences/` are monitored
- [ ] Files in `~/.config/` are detected (cross-platform apps)
- [ ] Temporary files in `/tmp/` are tracked
- [ ] Files are categorized correctly by type

#### 3. Session Management
- [ ] Can stop active monitoring session
- [ ] Session end date is set correctly
- [ ] Session persists after stopping
- [ ] Can create multiple sequential sessions
- [ ] Sessions survive app restart

#### 4. File Listing
- [ ] All monitored files are displayed
- [ ] File sizes are calculated correctly
- [ ] Total size is accurate
- [ ] Search functionality works
- [ ] Files are grouped by category
- [ ] File creation timestamps are accurate

#### 5. Uninstallation
- [ ] Move to Trash option works
- [ ] Permanent deletion option works
- [ ] Progress indicator updates correctly
- [ ] Files are deleted in correct order (depth-first)
- [ ] Error handling for locked files
- [ ] Confirmation dialog appears
- [ ] Success message is displayed

#### 6. User Interface
- [ ] Window renders correctly
- [ ] Navigation split view works
- [ ] List selection is responsive
- [ ] Buttons are properly enabled/disabled
- [ ] Drag and drop works for app selection
- [ ] Context menus appear correctly
- [ ] Keyboard shortcuts function (Cmd+N)

#### 7. Permissions
- [ ] Full Disk Access permission prompt appears
- [ ] App functions correctly with Full Disk Access
- [ ] Appropriate error messages without Full Disk Access
- [ ] System Settings link opens correctly

#### 8. Copy & Open in Finder
- [ ] Right-click context menu appears on file rows
- [ ] "Copy Path" copies full file path to clipboard
- [ ] "Reveal in Finder" opens Finder at file location
- [ ] Context menu works for all file types

### Performance Tests

- [ ] Can handle sessions with 100+ files
- [ ] Can handle sessions with 1000+ files
- [ ] UI remains responsive during large uninstallations
- [ ] Memory usage stays reasonable during monitoring
- [ ] App startup time is acceptable

### Edge Cases

- [ ] Handles files that no longer exist
- [ ] Handles files being deleted during uninstall
- [ ] Handles permission-denied errors gracefully
- [ ] Handles full disk scenarios
- [ ] Handles very long file paths
- [ ] Handles special characters in filenames

## Testing Procedure

### Manual Testing Steps

1. **Fresh Installation Test**
   ```bash
   swift build -c release
   .build/release/DeepUninstaller
   ```

2. **Create Test Session**
   - Start a new monitoring session
   - Name it "Test Application"
   - Install a known application or copy test files

3. **Verify File Detection**
   - Check that files appear in the session
   - Verify file categorization
   - Confirm file sizes and counts

4. **Test Uninstallation**
   - Stop the monitoring session
   - Review the file list
   - Test "Move to Trash" option
   - Verify files are in Trash
   - Empty Trash

5. **Test UI Features**
   - Test drag and drop
   - Test right-click menus
   - Test keyboard shortcuts
   - Test search functionality

### Automated Testing

Run the test suite:
```bash
swift test
```

All tests should pass on each supported macOS version.

## Test Applications

Use these applications for consistent testing:

1. **Small App** (~10 MB, ~10 files)
   - Example: Any simple utility app

2. **Medium App** (~100 MB, ~100 files)
   - Example: VS Code, Sublime Text

3. **Large App** (~500 MB, ~500+ files)
   - Example: Xcode, Docker Desktop

4. **Cross-Platform App** (uses ~/.config)
   - Example: Cursor, any Electron app

## Reporting Issues

When reporting compatibility issues, include:

- macOS version (e.g., "14.2.1 (23C71)")
- App version
- Detailed steps to reproduce
- Expected vs. actual behavior
- Console logs if applicable
- Screenshots or videos

## Version-Specific Notes

### macOS 13.0 (Ventura)
- Minimum supported version
- All features should work
- SwiftUI APIs may have slight differences

### macOS 14.0 (Sonoma)
- Enhanced permission dialogs
- Improved FSEvents performance
- Better Trash integration

### macOS 15.0 (Sequoia)
- Latest SwiftUI improvements
- Enhanced privacy controls
- Optimized for Apple Silicon

## Continuous Testing

### Before Each Release
- [ ] Test on all supported macOS versions
- [ ] Run full test suite
- [ ] Perform manual smoke tests
- [ ] Verify on both Intel and Apple Silicon (if available)

### Monthly Checks
- [ ] Test with latest macOS updates
- [ ] Verify with popular applications
- [ ] Check for new macOS security changes

## Known Limitations

- Cannot monitor system-protected files (expected behavior)
- Some apps may store files outside monitored directories
- Requires Full Disk Access for complete functionality
- Cannot retroactively track files from apps installed before monitoring

## Resources

- [Apple FSEvents Documentation](https://developer.apple.com/documentation/coreservices/file_system_events)
- [Full Disk Access Guide](https://support.apple.com/guide/mac-help/allow-access-to-system-files-mh15217/mac)
- [macOS Release Notes](https://developer.apple.com/documentation/macos-release-notes)
