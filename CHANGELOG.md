# Changelog

All notable changes to Deep Uninstaller will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

### Added
- Initial release of Deep Uninstaller
- Real-time file system monitoring using macOS FSEvents API
- Support for monitoring 8 key directories including ~/.config
- Session-based monitoring workflow (start/stop)
- Complete file categorization by type
- One-click uninstall with file preview
- Search and filter functionality for tracked files
- Session persistence with JSON storage
- Full Disk Access permission integration
- Welcome screen with feature overview
- Detailed session statistics (file count, total size)
- Context menu for session deletion
- Confirmation dialogs for destructive operations
- System noise filtering (.DS_Store, Spotlight, etc.)
- Depth-first file deletion algorithm
- Auto-save during active monitoring (5-second interval)
- Support for macOS 13.0 (Ventura) and later
- Native SwiftUI interface
- Dark mode support
- Comprehensive documentation (README, User Guide, Development Guide)

### Security
- Full Disk Access permission requirement
- File deletion safety with confirmation dialogs
- No network access
- No telemetry or data collection
- Open source codebase for transparency

### Performance
- Efficient FSEvents monitoring (<1% CPU usage)
- Minimal memory footprint (~1-2 MB per session)
- Low disk I/O with batched saves
- Real-time UI updates with Combine

## [Unreleased]

### Planned
- Export/import monitoring sessions
- CLI interface for automation
- Backup system with restore capability
- Batch uninstall multiple apps
- Custom directory monitoring
- Regex-based file filtering
- Statistical analysis dashboard
- Integration with macOS Trash
- Localization support
- Unit and integration tests

### Under Consideration
- System Integrity Protection (SIP) detection
- Launch agent/daemon monitoring
- Network activity tracking
- Scheduled monitoring
- Cloud sync for sessions
- App signature verification
- Quarantine attribute handling

---

## Version History

- **1.0.0** (Current) - Initial MVP release with core monitoring and uninstall features
