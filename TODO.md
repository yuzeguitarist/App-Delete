# TODO List

## High Priority (MVP Polish)

- [x] Add error handling for FSEvents initialization failures
- [x] Implement proper logging system (os_log)
- [x] Add unit tests for MonitoringSessionManager
- [x] Add unit tests for StorageManager
- [x] Test on macOS Ventura, Sonoma, and Sequoia (testing guide created)
- [x] Handle edge case: monitoring stopped during file operations
- [x] Add progress indicator for file deletion
- [x] Improve error messages for common failures
- [ ] Add app icon and assets

## Medium Priority (User Experience)

- [x] Add keyboard shortcuts (Cmd+N for new session, etc.)
- [x] Implement drag-and-drop to start monitoring
- [x] Add "Recently Deleted" safety feature (Trash integration)
- [x] Show real-time file count during active monitoring
- [ ] Add file type icons in the list
- [x] Implement copy file path to clipboard
- [x] Add "Open in Finder" for individual files
- [x] Show disk space that will be freed before uninstall
- [ ] Add sorting options for file list
- [ ] Implement export session to JSON

## Low Priority (Nice to Have)

- [ ] CLI interface for automation
- [ ] Import session from JSON
- [ ] Backup files before deletion (optional)
- [ ] Custom directory monitoring
- [ ] Regex-based file filtering
- [ ] Statistics dashboard
- [ ] Timeline view of file creation
- [ ] Compare sessions feature
- [ ] Batch uninstall
- [ ] Launch at login option
- [ ] Menu bar mode
- [ ] Notifications for monitoring events

## Future Enhancements

- [ ] Localization (Chinese, Spanish, French, German, Japanese)
- [ ] iCloud sync for sessions
- [ ] Integration with package managers (Homebrew, MacPorts)
- [ ] App signature and developer verification
- [ ] Network activity monitoring
- [ ] Process monitoring (launch agents/daemons)
- [ ] System Integrity Protection (SIP) detection
- [ ] Sandbox compatibility mode
- [ ] Widget for macOS dashboard

## Technical Debt

- [x] Add comprehensive error handling
- [x] Implement proper logging throughout
- [x] Add unit tests (coverage target: 70%+)
- [x] Add UI tests for critical paths
- [ ] Profile memory usage with Instruments
- [ ] Optimize large file list rendering
- [ ] Handle extremely large sessions (10000+ files)
- [ ] Add crash reporting (opt-in)
- [ ] Implement proper dependency injection
- [ ] Add documentation comments (DocC)

## Documentation

- [x] Organize documentation into /docs folder
- [x] Create compatibility testing guide
- [ ] Record demo video
- [ ] Create screenshot gallery
- [ ] Write blog post about the approach
- [ ] Add code documentation with DocC
- [ ] Create tutorial for developers
- [ ] Add privacy policy (even though we don't collect data)
- [ ] Create comparison with existing tools

## DevOps

- [ ] Set up CI/CD with GitHub Actions
- [ ] Automated testing on multiple macOS versions
- [ ] Code signing setup
- [ ] Notarization for distribution
- [ ] Release automation
- [ ] Version bump automation
- [ ] Changelog generation from commits

## Community

- [ ] Create contributing guidelines (done ✅)
- [ ] Set up issue templates
- [ ] Set up PR templates
- [ ] Create code of conduct
- [ ] Add security policy
- [ ] Set up discussions
- [ ] Create project roadmap
- [ ] Add sponsors/funding options

## Research & Investigation

- [ ] Investigate quarantine attribute handling
- [ ] Research alternative monitoring approaches
- [ ] Explore spotlight metadata integration
- [ ] Investigate Time Machine exclusion recommendations
- [ ] Research sandboxed app monitoring
- [ ] Explore Apple Silicon optimizations
- [ ] Investigate kernel extension requirements (if any)

---

## Completed ✅

- [x] Core FSEvents monitoring implementation
- [x] Session management
- [x] SwiftUI interface
- [x] File categorization
- [x] JSON persistence
- [x] Uninstall functionality
- [x] README documentation
- [x] User guide
- [x] Development guide
- [x] Contributing guidelines
- [x] Quick start guide
- [x] Changelog
- [x] Build script
- [x] .gitignore
- [x] Package.swift configuration
