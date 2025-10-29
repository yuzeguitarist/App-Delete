# Deep Uninstaller for macOS

A powerful macOS application that uses active file system monitoring to ensure complete removal of applications and their associated files.

## Overview

Unlike traditional uninstaller tools that rely on passive scanning and predefined rules, Deep Uninstaller actively monitors your file system in real-time to track exactly what files an application creates. This approach is particularly effective for:

- Cross-platform applications (Electron, Linux ports)
- Apps that use non-standard directories (e.g., `~/.config`)
- Applications with scattered configuration files

## Key Features

### 🔍 Active Monitoring
Start monitoring before installing an application to capture all file system changes in real-time using macOS FSEvents API.

### 📁 Non-Standard Path Detection
Tracks files in unconventional locations that other uninstallers miss:
- `~/.config/` (common for cross-platform apps)
- `/tmp/` temporary files
- Custom application directories

### 🗑️ Safe Removal
One-click uninstall with Trash integration:
- Move to Trash by default (recommended for safety)
- Option to delete permanently if preferred
- Real-time progress indicator for large uninstalls
- The application bundle (`/Applications/*.app`)
- Application Support files
- Caches
- Preferences
- Logs
- Configuration files
- All other tracked files

### 📊 Detailed Insights
View comprehensive information about monitored applications:
- Total number of files
- Total size
- File categorization by type
- Search and filter capabilities
- Right-click to copy path or reveal in Finder
- Drag-and-drop to start monitoring

## How It Works

1. **Start Monitoring**: Create a monitoring session - type the app name or drag the app from Finder
2. **Install & Use**: Install and briefly use the application while monitoring is active
3. **Stop Monitoring**: Stop the monitoring session to finalize the file list
4. **Review Files**: Browse all detected files categorized by type, right-click for more options
5. **Uninstall**: Choose to move to Trash (recommended) or delete permanently with progress tracking

## Monitored Directories

The tool monitors these key directories:
- `/Applications/`
- `~/Library/Application Support/`
- `~/Library/Caches/`
- `~/Library/Preferences/`
- `~/Library/Logs/`
- `~/Library/WebKit/`
- `~/.config/` *(critical for cross-platform apps)*
- `/tmp/`

## System Requirements

- macOS 13.0 (Ventura) or later
- **Full Disk Access** permission required

## Permissions

This application requires **Full Disk Access** to:
- Monitor protected system directories (`~/Library/*`)
- Delete files from protected locations
- Track all application file changes

### Granting Full Disk Access

1. Open **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Click the **+** button
3. Navigate to and select **Deep Uninstaller**
4. Enable the toggle switch
5. Restart the application

## Building from Source

### Prerequisites
- Xcode 15.0 or later
- macOS 13.0+ SDK
- Swift 5.9+

### Build Instructions

```bash
# Clone the repository
git clone <repository-url>
cd deep-uninstaller

# Build using Swift Package Manager
swift build -c release

# Or open in Xcode
open Package.swift
```

### Running
```bash
swift run
```

## Technical Architecture

### Core Components

- **FSEventsMonitor**: Wraps macOS FSEvents API for efficient file system monitoring
- **MonitoringSessionManager**: Manages monitoring sessions and coordinates file tracking
- **StorageManager**: Persists session data to disk using JSON
- **SwiftUI Views**: Modern, native macOS interface

### File Filtering

The monitor automatically filters out system noise:
- `.DS_Store` files
- Spotlight indexes
- Document Revisions
- FSEvents metadata
- Apple system files

## Safety Features

- **Trash by Default**: Files are moved to Trash instead of permanently deleted
- **Progress Tracking**: Real-time progress indicator shows what's happening
- **Preview Before Delete**: Always shows what will be deleted before execution
- **Confirmation Dialog**: Requires explicit confirmation for uninstall
- **Session Persistence**: Sessions are saved and survive app restarts
- **Sorted Deletion**: Deletes files depth-first to handle nested structures
- **Keyboard Shortcuts**: Standard macOS shortcuts (⌘N for new session)

## Limitations

- Only tracks files created **after** monitoring starts
- Cannot track files created by apps that were installed before monitoring
- Requires Full Disk Access for complete functionality
- Some system-protected files may not be deletable

## Use Cases

### Ideal For:
- Testing new applications safely
- Managing Electron applications
- Removing cross-platform apps completely
- Tracking apps with unconventional file structures

### Not Recommended For:
- System applications
- Apps already installed (can't retroactively track)
- Apps requiring frequent reinstallation

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - see LICENSE file for details

## Disclaimer

This tool moves files to Trash by default for safety, but also offers permanent deletion. Always review the file list before confirming uninstallation. The authors are not responsible for accidental data loss.

## Documentation

- [User Guide](docs/USER_GUIDE.md) - Detailed usage instructions
- [Quick Start](docs/QUICKSTART.md) - Get started in 5 minutes
- [Installation Guide](docs/INSTALLATION.md) - Installation instructions
- [Architecture](docs/ARCHITECTURE.md) - Technical architecture details
- [Development Guide](docs/DEVELOPMENT.md) - Contributing guidelines
- [Security Policy](docs/SECURITY.md) - Security practices and reporting
- [Changelog](docs/CHANGELOG.md) - Version history

## Future Enhancements (Roadmap)

- [ ] Export/import monitoring sessions
- [ ] Batch uninstall multiple apps
- [ ] Automatic backup before deletion
- [ ] CLI interface for automation
- [ ] Custom directory monitoring
- [ ] Regex-based file filtering
- [ ] Statistical analysis of app behavior
