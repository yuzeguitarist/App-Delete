# Deep Uninstaller User Guide

Welcome to Deep Uninstaller! This guide will help you get the most out of the application.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Setting Up Permissions](#setting-up-permissions)
3. [Creating a Monitoring Session](#creating-a-monitoring-session)
4. [Installing Applications](#installing-applications)
5. [Stopping Monitoring](#stopping-monitoring)
6. [Reviewing Tracked Files](#reviewing-tracked-files)
7. [Uninstalling Applications](#uninstalling-applications)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)
10. [FAQ](#faq)

---

## Getting Started

Deep Uninstaller tracks file system changes to help you completely remove applications from your Mac. Unlike traditional uninstallers that guess where files might be, Deep Uninstaller watches exactly what files an application creates.

### First Launch

1. Open Deep Uninstaller
2. You'll see the welcome screen with an overview of features
3. Click "Start New Monitoring Session" when ready

---

## Setting Up Permissions

### Why Full Disk Access is Required

Deep Uninstaller needs Full Disk Access to:
- Monitor protected directories like `~/Library/`
- Track files in system locations
- Delete files from restricted areas

### Granting Full Disk Access

1. **Open System Settings**
   - Click Apple menu → System Settings
   - Navigate to Privacy & Security

2. **Enable Full Disk Access**
   - Scroll down and click "Full Disk Access"
   - Click the lock icon and authenticate
   - Click the **+** button
   - Find and select Deep Uninstaller
   - Enable the toggle switch

3. **Restart the App**
   - Quit Deep Uninstaller completely
   - Reopen the application

> **Note**: Without Full Disk Access, monitoring may be incomplete and file deletion may fail.

---

## Creating a Monitoring Session

### When to Start Monitoring

Start a monitoring session **before** you install or first run a new application. This ensures all file changes are captured from the beginning.

### Steps to Create a Session

1. **Click "New Monitoring"** (+ button in sidebar)

2. **Enter Application Name**
   - Type the name of the app you'll install
   - Example: "Cursor", "Discord", "Slack"
   - This name helps you identify the session later

3. **Review Important Information**
   - Read the permission requirements
   - Understand what will be monitored
   - Click "Check Permissions" if unsure about access

4. **Start Monitoring**
   - Click "Start Monitoring" button
   - A green indicator shows monitoring is active
   - The app is now watching for file changes

---

## Installing Applications

### While Monitoring is Active

1. **Install the Application**
   - Download the app (if not already done)
   - Drag to Applications folder
   - Or run the installer

2. **Launch and Use the App**
   - Open the newly installed application
   - Go through initial setup
   - Use key features briefly
   - This ensures all configuration files are created

3. **Watch for Tracked Files**
   - Deep Uninstaller automatically tracks changes
   - Files appear in the session detail view
   - No manual action required

### What Gets Tracked

- Application bundle (`.app` file)
- Configuration files
- Cache files
- Preferences
- Support files
- Logs
- Temporary files
- Files in `~/.config` and other non-standard locations

---

## Stopping Monitoring

### When to Stop

Stop monitoring after:
- Application is fully installed
- You've completed initial setup
- You've tested key features
- All expected files are created

### How to Stop

1. **Click "Stop" Button**
   - Red stop button in the sidebar
   - Or click on the active session

2. **Session is Finalized**
   - Monitoring ends immediately
   - Session moves to "Completed Sessions"
   - Files are saved permanently
   - You can now review or uninstall

> **Tip**: You can stop and restart monitoring anytime, but new sessions are recommended for each app.

---

## Reviewing Tracked Files

### Viewing Session Details

1. **Select a Session**
   - Click on any completed session in the sidebar
   - Details appear in the main area

2. **Session Overview**
   - Application name
   - Number of tracked files
   - Total size of all files
   - Date monitoring started/ended

### File List

Files are organized by category:

- **Applications**: Main `.app` bundles
- **Application Support**: App-specific data
- **Caches**: Temporary cached data
- **Preferences**: Settings and preferences
- **Logs**: Debug and activity logs
- **Configuration Files**: Files in `~/.config`
- **Temporary Files**: Files in `/tmp`
- **Other Files**: Uncategorized files

### Search and Filter

- **Search Box**: Filter files by path
- Type to instantly filter the list
- Search is case-insensitive

### File Information

Each file shows:
- Full file path
- File size
- How long ago it was created

---

## Uninstalling Applications

### Before You Uninstall

1. **Quit the Application**
   - Ensure the app is not running
   - Close all app windows
   - Quit from menu or Activity Monitor

2. **Review Files to Delete**
   - Check the complete file list
   - Verify nothing important will be deleted
   - Use search to find specific files

### Uninstall Process

1. **Click "Uninstall Completely"**
   - Red button in top-right of detail view
   - Only available for completed sessions

2. **Confirm Deletion**
   - Dialog shows file count and total size
   - Warning that action is permanent
   - Review carefully

3. **Execute Uninstall**
   - Click "Uninstall and Delete All Files"
   - Deep Uninstaller removes all tracked files
   - Progress shown in real-time

4. **View Results**
   - Success message shows files deleted
   - Session is removed from list
   - Application is completely removed

### What Happens During Uninstall

- Files deleted in depth-first order (deepest first)
- Empty directories are removed
- Session data is cleaned up
- Operation cannot be undone

---

## Best Practices

### Do's ✅

- **Start monitoring before installation**
  - Capture all files from the start
  
- **Use descriptive session names**
  - Makes identification easier later
  
- **Test the app thoroughly while monitoring**
  - Ensures all files are created
  
- **Quit apps before uninstalling**
  - Prevents file locks and errors
  
- **Review files before deleting**
  - Verify nothing unexpected is included
  
- **Keep sessions for reference**
  - Don't uninstall immediately if unsure

### Don'ts ❌

- **Don't monitor system applications**
  - Risk of system instability
  
- **Don't start monitoring after installation**
  - Won't capture existing files
  
- **Don't uninstall apps you're still using**
  - Obviously, but worth mentioning
  
- **Don't run multiple monitoring sessions**
  - Only one session can be active at a time
  
- **Don't delete sessions you might need**
  - Keep for future reference if unsure

---

## Troubleshooting

### "No Files Tracked"

**Possible Causes:**
- Full Disk Access not granted
- Application hasn't created files yet
- Monitoring started after installation

**Solutions:**
- Check permissions in System Settings
- Use the application more thoroughly
- Create new session and reinstall app

### "Permission Denied" During Uninstall

**Possible Causes:**
- Application is still running
- Files are locked by system
- Insufficient permissions

**Solutions:**
- Quit the application completely
- Restart Deep Uninstaller
- Check Full Disk Access is enabled
- Try running with administrator rights

### "Some Files Could Not Be Deleted"

**Possible Causes:**
- Files protected by System Integrity Protection
- Files in use by other processes
- Incorrect file paths

**Solutions:**
- Close all related applications
- Restart your Mac
- Manually delete remaining files

### Monitoring Not Starting

**Possible Causes:**
- Another session is active
- App lacks necessary permissions
- System resources exhausted

**Solutions:**
- Stop any active sessions first
- Verify Full Disk Access
- Restart the application
- Check Console.app for errors

---

## FAQ

### Q: Can I monitor multiple apps at once?

**A:** No, only one monitoring session can be active at a time. This prevents confusion about which files belong to which app.

### Q: What if I forgot to start monitoring before installation?

**A:** You'll need to uninstall the app manually, create a new monitoring session, and reinstall. Deep Uninstaller can't retroactively track files.

### Q: Is it safe to uninstall any application?

**A:** Deep Uninstaller is safe, but you should only uninstall applications you installed yourself. Never monitor or uninstall system applications or utilities.

### Q: Can I recover files after uninstalling?

**A:** No, deletion is permanent. Files are not moved to Trash. Always review the file list before confirming.

### Q: Does this work with App Store apps?

**A:** Yes, but App Store apps can also be uninstalled through Launchpad. Deep Uninstaller is most useful for apps installed outside the App Store.

### Q: Will this slow down my Mac?

**A:** No, FSEvents monitoring is very efficient and uses minimal resources. You won't notice any performance impact.

### Q: Can I export monitoring data?

**A:** Not in the current version. This feature is planned for a future release.

### Q: What happens if I close Deep Uninstaller during monitoring?

**A:** The monitoring stops when the app quits. Sessions are saved, but file tracking only occurs while monitoring is active.

### Q: Can I edit the list of monitored directories?

**A:** Not currently. The monitored directories are carefully selected to balance coverage and performance.

### Q: Why can't I see files in `/System/`?

**A:** Deep Uninstaller intentionally avoids system directories to prevent accidental system damage.

---

## Support

If you encounter issues not covered in this guide:

1. Check the README.md for technical details
2. Review Console.app for error messages
3. Open an issue on GitHub
4. Include macOS version and error details

---

## Tips for Advanced Users

- Monitor Electron apps carefully—they often create many files
- Check `~/.config` specifically for cross-platform apps
- Review logs after monitoring to understand app behavior
- Keep completed sessions as a reference for similar apps
- Use monitoring to audit app behavior and privacy

---

Thank you for using Deep Uninstaller! For more information, visit the project repository.
