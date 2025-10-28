# Contributing to Deep Uninstaller

Thank you for your interest in contributing to Deep Uninstaller! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9+
- Git

### Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/deep-uninstaller.git
   cd deep-uninstaller
   ```

3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. Build and run:
   ```bash
   swift build
   swift run
   ```

## Project Structure

```
deep-uninstaller/
├── Sources/
│   ├── DeepUninstallerApp.swift    # App entry point
│   ├── Models/
│   │   └── MonitoringSession.swift  # Data models
│   ├── Services/
│   │   ├── FSEventsMonitor.swift    # File system monitoring
│   │   ├── MonitoringSessionManager.swift  # Session management
│   │   └── StorageManager.swift     # Data persistence
│   └── Views/
│       ├── ContentView.swift        # Main view
│       ├── SessionListView.swift    # Session list sidebar
│       ├── SessionDetailView.swift  # Session details
│       ├── NewSessionSheet.swift    # New session dialog
│       └── WelcomeView.swift        # Welcome screen
├── Package.swift                    # Swift Package Manager config
└── README.md                        # Documentation
```

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation
- Keep lines under 120 characters
- Use meaningful variable and function names
- Add comments for complex logic

### SwiftUI Best Practices

- Keep views small and focused
- Extract reusable components
- Use `@State`, `@Binding`, and `@EnvironmentObject` appropriately
- Prefer declarative code

### File Organization

- One type per file when possible
- Group related functionality
- Keep view models separate from views

## Making Changes

### Before You Start

1. Check existing issues for similar work
2. Open an issue to discuss major changes
3. Ensure your fork is up to date

### Development Workflow

1. Write clean, documented code
2. Test your changes thoroughly
3. Ensure the app builds without warnings
4. Test on multiple macOS versions if possible

### Testing Checklist

- [ ] App builds successfully
- [ ] No compiler warnings
- [ ] Monitoring starts and stops correctly
- [ ] Files are tracked accurately
- [ ] Uninstall removes files safely
- [ ] UI is responsive and intuitive
- [ ] No crashes or hangs

### Commit Messages

Use clear, descriptive commit messages:

```
Add feature to export monitoring sessions

- Implement JSON export functionality
- Add export button to session detail view
- Include date and file count in export
```

## Pull Request Process

1. Update documentation for any changed functionality
2. Add comments to complex code sections
3. Test your changes thoroughly
4. Push to your fork
5. Create a pull request with:
   - Clear description of changes
   - Screenshots for UI changes
   - References to related issues

### PR Title Format

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

## Areas for Contribution

### High Priority
- Unit tests for core services
- Integration tests for FSEvents monitoring
- Error handling improvements
- Performance optimizations

### Features
- Export/import sessions
- Backup before deletion
- CLI interface
- Custom directory monitoring
- Statistics and analytics

### Documentation
- Tutorial videos
- Use case examples
- API documentation
- Localization

### UI/UX
- Dark mode optimizations
- Accessibility improvements
- Keyboard shortcuts
- Drag-and-drop support

## Security Considerations

- Never commit sensitive data
- Validate all file paths before operations
- Handle Full Disk Access errors gracefully
- Test file deletion carefully

## Code Review

All submissions require review. We aim to:
- Provide constructive feedback
- Respond within 48 hours
- Help improve code quality
- Maintain project standards

## Questions?

- Open an issue for bugs or feature requests
- Use discussions for questions
- Check existing documentation first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be acknowledged in the project README. Thank you for helping improve Deep Uninstaller!
