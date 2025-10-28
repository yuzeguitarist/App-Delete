# Quick Start Guide

Get started with Deep Uninstaller in 5 minutes!

## Prerequisites

- macOS 13.0 (Ventura) or later
- Administrator access to your Mac

## Installation

### Option 1: Run from Source (Recommended for Development)

```bash
# Clone the repository
git clone <repository-url>
cd deep-uninstaller

# Build and run
swift run
```

### Option 2: Build Release Binary

```bash
# Build release version
./build.sh

# Run the application
.build/release/DeepUninstaller
```

## Initial Setup

### 1. Grant Full Disk Access

When you first launch Deep Uninstaller:

1. Open **System Settings**
2. Go to **Privacy & Security** → **Full Disk Access**
3. Click the lock 🔒 and authenticate
4. Click **+** and select **Deep Uninstaller**
5. Enable the toggle ✅
6. **Restart** Deep Uninstaller

> ⚠️ **Important**: Without Full Disk Access, the app won't be able to monitor or delete files in protected directories.

## First Monitoring Session

### Example: Installing a Test Application

Let's say you want to install **Cursor** (or any other app):

#### Step 1: Start Monitoring

1. Launch Deep Uninstaller
2. Click **"Start New Monitoring Session"** (or the **+** button)
3. Enter session name: `Cursor`
4. Click **"Start Monitoring"**

✅ A green indicator shows monitoring is active

#### Step 2: Install the App

1. Download Cursor (or your chosen app)
2. Drag to Applications folder
3. Launch the app
4. Complete initial setup
5. Use the app briefly to create config files

#### Step 3: Stop Monitoring

1. Return to Deep Uninstaller
2. Click the **"Stop"** button (red)

✅ Session is now in "Completed Sessions"

#### Step 4: Review Files

1. Click on the **"Cursor"** session
2. See all tracked files organized by category:
   - Applications
   - Application Support
   - Caches
   - Configuration Files
   - etc.

#### Step 5: Uninstall (When Ready)

1. Click **"Uninstall Completely"** (red button)
2. Review the confirmation dialog
3. Click **"Uninstall and Delete All Files"**

✅ App and all files are permanently removed!

## Common Use Cases

### Testing a New App

```
1. Start monitoring: "TestApp"
2. Install and test the app
3. Stop monitoring
4. Review what files were created
5. Uninstall if you don't want to keep it
```

### Cleaning Up After Trial Software

```
1. Start monitoring: "TrialApp"
2. Install the trial version
3. Use it during trial period
4. Stop monitoring before trial expires
5. Uninstall completely after trial
```

### Tracking Electron Apps

```
1. Start monitoring: "ElectronApp"
2. Install the Electron-based app
3. Note files in ~/.config (common for Electron)
4. Stop monitoring
5. Review extensive file list
6. Uninstall to clean everything
```

## Tips for Success

### ✅ Best Practices

- **Start monitoring BEFORE installing** - Can't track existing files
- **Use the app after installing** - Creates all config files
- **Descriptive names** - Helps identify sessions later
- **Review before uninstalling** - Double-check file list

### ❌ Common Mistakes

- Starting monitoring after installation (too late!)
- Not using the app enough (misses config files)
- Uninstalling while app is running (may fail)
- Forgetting to grant Full Disk Access

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New Session | Cmd+N (when available) |
| Confirm Dialog | Enter ⏎ |
| Cancel Dialog | Esc |

## Troubleshooting

### No Files Tracked?

- ✅ Check Full Disk Access is enabled
- ✅ Actually use the application
- ✅ Wait a few seconds for files to appear

### Can't Delete Files?

- ✅ Quit the application first
- ✅ Check Full Disk Access
- ✅ Restart Deep Uninstaller

### Monitoring Won't Start?

- ✅ Stop any active session first
- ✅ Check permissions
- ✅ Restart the app

## What Gets Monitored?

Deep Uninstaller watches these directories:

```
/Applications/                      ← Main apps
~/Library/Application Support/      ← App data
~/Library/Caches/                   ← Cache files
~/Library/Preferences/              ← Settings
~/Library/Logs/                     ← Log files
~/Library/WebKit/                   ← Web data
~/.config/                          ← Cross-platform configs ⭐
/tmp/                               ← Temporary files
```

## File Categories

Files are organized into these categories:

- **Applications** - Main .app bundles
- **Application Support** - App-specific data
- **Caches** - Temporary cached data
- **Preferences** - Settings and preferences
- **Logs** - Debug and activity logs
- **Configuration Files** - Files in ~/.config
- **Temporary Files** - Files in /tmp
- **Other Files** - Everything else

## Example Session Output

After monitoring Cursor, you might see:

```
Session: Cursor
Files: 247 files
Size: 1.2 GB
Started: Jan 15, 2025 at 2:30 PM
Ended: Jan 15, 2025 at 2:35 PM

Categories:
  Applications (1 file, 150 MB)
    /Applications/Cursor.app
  
  Application Support (45 files, 800 MB)
    ~/Library/Application Support/Cursor/...
  
  Caches (180 files, 200 MB)
    ~/Library/Caches/com.cursor.app/...
  
  Configuration Files (15 files, 2 MB)
    ~/.config/cursor/settings.json
    ...
  
  Preferences (6 files, 50 KB)
    ~/Library/Preferences/com.cursor.plist
    ...
```

## Next Steps

- Read the [User Guide](USER_GUIDE.md) for detailed instructions
- Check [DEVELOPMENT.md](DEVELOPMENT.md) for technical details
- Review [CONTRIBUTING.md](CONTRIBUTING.md) to contribute

## Getting Help

- Check [USER_GUIDE.md](USER_GUIDE.md) FAQ section
- Review error messages in Console.app
- Open an issue on GitHub with details

---

**That's it!** You're ready to track and completely remove any macOS application. Happy uninstalling! 🗑️
