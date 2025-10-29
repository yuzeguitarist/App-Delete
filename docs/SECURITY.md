# Security Policy

## Supported Versions

Currently supported versions for security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Security Considerations

### Full Disk Access

Deep Uninstaller requires **Full Disk Access** to function properly. This is a powerful permission that gives the application the ability to read and write files throughout your system.

**What we do with this access:**
- Monitor file system changes in specified directories
- Read file metadata (path, size, creation date)
- Delete files tracked during monitoring sessions

**What we DON'T do:**
- Access files outside monitored directories
- Read file contents
- Send data over the network
- Collect telemetry or analytics
- Store sensitive information

### Data Privacy

**Local Storage Only:**
- All data is stored locally on your Mac
- Session data stored in: `~/Library/Application Support/DeepUninstaller/`
- No cloud synchronization (in current version)
- No network communication whatsoever

**Data We Store:**
- Application names (user-provided)
- File paths of tracked files
- File sizes and creation dates
- Session start/end timestamps

**Data We Don't Store:**
- File contents
- User credentials
- Personal information
- System passwords
- Network activity

### File Deletion Safety

**Safeguards:**
- Confirmation dialog before any deletion
- Preview of all files to be deleted
- User must explicitly confirm action
- Session review before uninstall
- No silent or automatic deletions

**What Could Go Wrong:**
- User error: Deleting wrong session
- Mistaken confirmation
- Monitoring wrong application

**Recommendations:**
- Always review file lists before uninstalling
- Use descriptive session names
- Keep backup of important data
- Test with non-critical apps first

### Code Transparency

**Open Source:**
- All source code is publicly available
- Anyone can audit the code
- Community review encouraged
- No hidden functionality
- No obfuscation

**Build From Source:**
- Users can build from source
- No binary-only distributions
- Reproducible builds
- No telemetry or phone-home

## Reporting a Vulnerability

If you discover a security vulnerability in Deep Uninstaller, please report it responsibly:

### How to Report

1. **DO NOT** open a public issue for security vulnerabilities
2. Email the maintainer directly (see GitHub profile for contact)
3. Or use GitHub's private security advisory feature:
   - Go to the Security tab
   - Click "Report a vulnerability"
   - Fill in the details

### What to Include

Please include in your report:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)
- Your contact information (optional)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Validation**: Within 1 week
- **Fix Development**: Within 2 weeks (depending on severity)
- **Public Disclosure**: After fix is released

### Disclosure Policy

- We will work with you to understand and validate the issue
- We will develop and test a fix
- We will release a patch as soon as safely possible
- We will credit you in the release notes (unless you prefer anonymity)
- We will disclose the vulnerability publicly after fix is available

## Security Best Practices

### For Users

**Before Using:**
1. Review the source code (if you're technical)
2. Build from source (optional but recommended)
3. Understand Full Disk Access implications
4. Only monitor apps you trust

**During Use:**
1. Only monitor applications you're installing
2. Never monitor system applications
3. Review file lists carefully before uninstalling
4. Keep sessions organized and labeled
5. Don't share session files with sensitive paths

**After Use:**
1. Review what was deleted
2. Verify app is completely removed
3. Check for unexpected behavior
4. Report any issues

### For Developers

**When Contributing:**
1. Never commit sensitive data (API keys, passwords, etc.)
2. Validate all file paths before operations
3. Use safe file handling practices
4. Test error conditions thoroughly
5. Document security implications of changes

**Code Review Checklist:**
- [ ] No hardcoded credentials
- [ ] Proper error handling
- [ ] Input validation for user data
- [ ] Safe file operations
- [ ] No arbitrary code execution
- [ ] No SQL injection (not applicable but good practice)
- [ ] No command injection
- [ ] Proper permission checks

## Known Limitations

### System Integrity Protection (SIP)

Deep Uninstaller respects macOS System Integrity Protection:
- Cannot monitor system-protected directories
- Cannot delete system-protected files
- Cannot bypass SIP restrictions
- This is by design and cannot be changed

### Sandboxing

Current version is not sandboxed:
- Requires Full Disk Access
- Not distributed through Mac App Store (would require sandboxing)
- Future versions may explore sandbox compatibility

### Permissions

Deep Uninstaller requires:
- Full Disk Access (mandatory)
- Administrator rights for some deletions (prompted by macOS)

Deep Uninstaller does NOT require:
- Accessibility access
- Screen recording
- Camera/microphone access
- Location services
- Contacts/calendar access

## Security Updates

We are committed to addressing security issues promptly:
- Security patches released as soon as validated
- Critical issues: Within 48 hours
- High severity: Within 1 week
- Medium severity: Within 2 weeks
- Low severity: Next regular release

## Third-Party Dependencies

**Current Status:**
- **Zero** third-party dependencies
- Only uses Apple's native frameworks
- No external packages or libraries

This minimizes supply chain risks and security vulnerabilities.

## Compliance

### Privacy Regulations

Deep Uninstaller is designed with privacy in mind:
- No data collection (GDPR compliant by design)
- No tracking or analytics
- No network communication
- All processing happens locally

### Licensing

- MIT License (see LICENSE file)
- Open source and auditable
- Free to use, modify, and distribute

## Questions?

If you have questions about security:
- Review this document
- Check the documentation
- Open a discussion (not an issue)
- Contact maintainers directly for sensitive matters

## Acknowledgments

We thank security researchers and users who help identify and responsibly report security issues. Your contributions make Deep Uninstaller safer for everyone.

---

**Last Updated:** January 2025
