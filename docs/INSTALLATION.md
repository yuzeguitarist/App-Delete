# Installation Guide

This guide covers different ways to install and run Deep Uninstaller.

## Prerequisites

Before installing, ensure you have:

- **macOS 13.0 (Ventura) or later**
- **Xcode 15.0+** or **Swift 5.9+** (for building from source)
- **Administrator access** to your Mac

## Installation Methods

### Method 1: Build from Source (Recommended)

This is the recommended method for transparency and security.

#### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/deep-uninstaller.git
cd deep-uninstaller
```

#### Step 2: Build the Application

**Option A: Using the build script**
```bash
chmod +x build.sh
./build.sh
```

**Option B: Using Swift Package Manager directly**
```bash
swift build -c release
```

**Option C: Using Xcode**
```bash
open Package.swift
# Build from Xcode: Product → Build (Cmd+B)
```

#### Step 3: Run the Application

**From command line:**
```bash
swift run
```

**Or run the binary directly:**
```bash
.build/release/DeepUninstaller
```

**From Xcode:**
```bash
# Run from Xcode: Product → Run (Cmd+R)
```

### Method 2: Install Pre-built Binary (Future)

Pre-built binaries will be available in future releases.

```bash
# Download from GitHub Releases
# Extract and move to Applications
```

---

## Post-Installation Setup

### Step 1: Grant Full Disk Access

Deep Uninstaller requires Full Disk Access to function properly.

1. **Open System Settings**
   - Click the Apple menu → System Settings
   - Or press Cmd+Space, type "System Settings", press Enter

2. **Navigate to Privacy & Security**
   - Click "Privacy & Security" in the sidebar
   - Scroll down to "Full Disk Access"

3. **Add Deep Uninstaller**
   - Click the lock icon 🔒 (bottom left)
   - Enter your password to unlock
   - Click the **+** button
   - Navigate to Deep Uninstaller:
     - If built from source: `.build/release/DeepUninstaller`
     - If installed: `/Applications/DeepUninstaller.app`
   - Select and click "Open"

4. **Enable the Toggle**
   - Ensure the toggle next to Deep Uninstaller is **ON** ✅

5. **Restart the Application**
   - Quit Deep Uninstaller completely
   - Reopen the application

### Step 2: Verify Installation

1. Launch Deep Uninstaller
2. You should see the welcome screen
3. Try clicking "Start New Monitoring Session"
4. If you can enter a name and start monitoring, installation is successful

---

## Troubleshooting

### Issue: "Command not found" when running `swift`

**Solution:** Install Xcode Command Line Tools

```bash
xcode-select --install
```

Or install full Xcode from the Mac App Store.

### Issue: Build fails with "No such module"

**Solution:** Ensure you're using Swift 5.9 or later

```bash
swift --version
```

If version is too old, update Xcode or Swift toolchain.

### Issue: App crashes on launch

**Possible Causes:**
- Full Disk Access not granted
- Corrupted build
- macOS version too old

**Solutions:**
1. Verify Full Disk Access is enabled
2. Clean build:
   ```bash
   rm -rf .build
   swift build -c release
   ```
3. Check macOS version:
   ```bash
   sw_vers
   ```
   Must be 13.0+

### Issue: Permission denied errors

**Solution:** Grant Full Disk Access (see setup steps above)

### Issue: Can't find .build directory

**Cause:** Haven't built the project yet

**Solution:**
```bash
swift build -c release
```

### Issue: App won't quit

**Solution:**
```bash
# Force quit
killall DeepUninstaller

# Or use Activity Monitor
# Applications → Utilities → Activity Monitor
# Find DeepUninstaller → Quit Process
```

---

## Building for Distribution

### Code Signing

For distribution outside the Mac App Store, you need to sign the app.

```bash
# Build
swift build -c release

# Sign
codesign --force --deep --sign "Developer ID Application: Your Name" \
  .build/release/DeepUninstaller
```

### Notarization

For macOS 10.15+ compatibility:

```bash
# Create ZIP
ditto -c -k --sequesterRsrc --keepParent \
  .build/release/DeepUninstaller \
  DeepUninstaller.zip

# Submit for notarization
xcrun notarytool submit DeepUninstaller.zip \
  --keychain-profile "AC_PASSWORD" \
  --wait

# Staple the ticket
xcrun stapler staple .build/release/DeepUninstaller
```

---

## Uninstalling Deep Uninstaller

### Ironic, right?

To uninstall Deep Uninstaller itself:

1. **Quit the application**
   ```bash
   killall DeepUninstaller
   ```

2. **Remove the binary or app bundle**
   ```bash
   # If installed to Applications
   rm -rf /Applications/DeepUninstaller.app
   
   # If built from source
   cd deep-uninstaller
   rm -rf .build
   ```

3. **Remove application data**
   ```bash
   rm -rf ~/Library/Application\ Support/DeepUninstaller
   ```

4. **Remove from Full Disk Access**
   - System Settings → Privacy & Security → Full Disk Access
   - Select Deep Uninstaller
   - Click **-** button

---

## Development Setup

For developers who want to contribute:

### 1. Fork and Clone

```bash
# Fork on GitHub first, then:
git clone https://github.com/yourusername/deep-uninstaller.git
cd deep-uninstaller
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Open in Xcode

```bash
open Package.swift
```

### 4. Make Changes

Edit code, test, commit.

### 5. Run Tests (when available)

```bash
swift test
```

### 6. Submit Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## System Requirements

### Minimum Requirements

- **Operating System:** macOS 13.0 (Ventura)
- **Architecture:** Intel or Apple Silicon
- **RAM:** 100 MB free
- **Disk Space:** 50 MB for app, plus space for session data
- **Permissions:** Full Disk Access

### Recommended Requirements

- **Operating System:** macOS 14.0 (Sonoma) or later
- **Architecture:** Apple Silicon (M1/M2/M3)
- **RAM:** 200 MB free
- **Disk Space:** 100 MB

### Tested Configurations

| macOS Version | Architecture | Status |
|---------------|--------------|--------|
| 13.0 Ventura | Intel | ✅ Should work |
| 13.0 Ventura | Apple Silicon | ✅ Should work |
| 14.0 Sonoma | Intel | ✅ Should work |
| 14.0 Sonoma | Apple Silicon | ✅ Should work |
| 15.0 Sequoia | Apple Silicon | ✅ Should work |

*Note: These are expected compatibility based on API usage. Actual testing needed.*

---

## Upgrading

### From Source

```bash
cd deep-uninstaller
git pull origin main
swift build -c release
```

Your session data will be preserved in:
```
~/Library/Application Support/DeepUninstaller/
```

### Future Versions

Check [CHANGELOG.md](CHANGELOG.md) for breaking changes and migration guides.

---

## Environment Variables (Optional)

None required for basic usage. For development:

```bash
# Increase logging verbosity
export DEEPUNINSTALLER_DEBUG=1

# Custom data directory
export DEEPUNINSTALLER_DATA_DIR=~/custom/path
```

---

## Docker / Virtualization

**Note:** Deep Uninstaller requires macOS-specific APIs (FSEvents) and cannot run in Docker or most virtualization environments. It must run on actual macOS.

For testing on multiple macOS versions, use:
- Separate Mac hardware
- macOS VMs in VMware Fusion or Parallels
- GitHub Actions with macOS runners

---

## Continuous Integration

For automated builds in CI/CD:

```yaml
# .github/workflows/build.yml
- name: Build
  run: swift build -c release

- name: Test (when available)
  run: swift test
```

See [.github/workflows/build.yml](.github/workflows/build.yml) for full configuration.

---

## FAQ

### Q: Do I need Xcode to run Deep Uninstaller?

**A:** No, if you use a pre-built binary. Yes, if building from source.

### Q: Can I run this on macOS 12 (Monterey)?

**A:** No, minimum is macOS 13 (Ventura) due to SwiftUI requirements.

### Q: Is the app sandboxed?

**A:** No, Deep Uninstaller requires Full Disk Access and cannot be sandboxed.

### Q: Can I distribute this through the Mac App Store?

**A:** Not in current form. The app requires Full Disk Access and is not sandboxed, which conflicts with Mac App Store guidelines.

### Q: How do I update to the latest version?

**A:** Pull the latest code and rebuild:
```bash
git pull
swift build -c release
```

### Q: Where is my data stored?

**A:** Session data is stored in:
```
~/Library/Application Support/DeepUninstaller/monitoring_sessions.json
```

---

## Getting Help

If you encounter installation issues:

1. Check this guide thoroughly
2. Review [TROUBLESHOOTING](USER_GUIDE.md#troubleshooting) in the User Guide
3. Search existing [GitHub Issues](../../issues)
4. Open a new issue with:
   - macOS version
   - Installation method
   - Error messages
   - Steps to reproduce

---

## Next Steps

After installation:

1. ✅ Read [QUICKSTART.md](QUICKSTART.md) for a 5-minute tutorial
2. ✅ Review [USER_GUIDE.md](USER_GUIDE.md) for detailed usage
3. ✅ Check [SECURITY.md](SECURITY.md) to understand permissions
4. ✅ Star the repo if you find it useful! ⭐

---

**Congratulations! Deep Uninstaller is now installed and ready to use.**
