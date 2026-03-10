# PawChat Release Guide

This guide explains how to create releases with automated APK builds.

## Quick Start

```bash
# Create release v1.0.0
./scripts/create-release.sh 1.0.0
```

This will:
1. Commit changes
2. Create tag v1.0.0
3. Push tag to GitHub
4. Trigger automated APK build
5. Upload APKs to Release

## Manual Release Process

### Step 1: Update Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1  # version+build_number
```

### Step 2: Commit Changes

```bash
git add pubspec.yaml
git commit -m "release: v1.0.0"
git push origin main
```

### Step 3: Create Tag

```bash
git tag -a v1.0.0 -m "PawChat v1.0.0"
```

### Step 4: Push Tag

```bash
git push origin v1.0.0
```

This triggers GitHub Actions to:
- Build debug APK
- Build release APK
- Upload both to GitHub Release

### Step 5: Monitor Build

Visit: https://github.com/pawpaw-agent/pawchat/actions

Wait 5-8 minutes for build to complete.

### Step 6: Verify Release

Visit: https://github.com/pawpaw-agent/pawchat/releases/tag/v1.0.0

Check that APKs are attached:
- ✅ `PawChat-1.0.0-debug.apk`
- ✅ `PawChat-1.0.0-release.apk`

## GitHub Actions Workflow

### What Happens Automatically

```
Push Tag v1.0.0
    ↓
GitHub Actions Triggered
    ↓
Checkout Code
    ↓
Setup Flutter 3.x
    ↓
Install Dependencies (flutter pub get)
    ↓
Generate Code (build_runner)
    ↓
Build Debug APK
    ↓
Build Release APK
    ↓
Create GitHub Release
    ↓
Upload Debug APK
    ↓
Upload Release APK
    ↓
✅ Complete!
```

### Workflow File

Location: `.github/workflows/release-automated.yml`

**Trigger:** Push to tags matching `v*`

**Jobs:**
1. Build debug APK
2. Build release APK
3. Create Release
4. Upload both APKs

## Troubleshooting

### APKs Not Appearing

**Wait:** Build takes 5-8 minutes

**Check Actions:** https://github.com/pawpaw-agent/pawchat/actions

**Look for:** Workflow run with tag name

**If failed:**
1. Click failed workflow
2. Review logs
3. Fix issues
4. Delete tag: `git tag -d v1.0.0`
5. Create new tag: `git tag -a v1.0.1 -m "v1.0.1"`
6. Push: `git push origin v1.0.1`

### Build Failed

**Common issues:**

1. **Flutter version** - Ensure workflow uses correct version
2. **Dependencies** - Run `flutter pub get` locally first
3. **Code generation** - Run `build_runner` locally first
4. **Tests failing** - Fix test errors

**Solution:**
```bash
# Test locally first
flutter pub get
flutter pub run build_runner build
flutter test
flutter build apk --release

# If local build succeeds, push tag
git push origin v1.0.0
```

### Need to Rebuild

**Option 1: Delete and recreate tag**

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0

# Recreate
git tag -a v1.0.0 -m "PawChat v1.0.0 (rebuild)"
git push origin v1.0.0
```

**Option 2: Create patch version**

```bash
git tag -a v1.0.1 -m "PawChat v1.0.1"
git push origin v1.0.1
```

## Release Checklist

Before creating release:

- [ ] All tests pass locally
- [ ] Code generation complete
- [ ] Version updated in pubspec.yaml
- [ ] CHANGELOG.md updated
- [ ] README.md updated if needed
- [ ] Local build succeeds

After creating release:

- [ ] GitHub Actions triggered
- [ ] Build completed successfully
- [ ] APKs uploaded to Release
- [ ] Release notes complete
- [ ] Download links work

## Version Numbering

Follow semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR** - Breaking changes (2.0.0)
- **MINOR** - New features (1.1.0)
- **PATCH** - Bug fixes (1.0.1)

**Examples:**
- `v1.0.0` - Initial release
- `v1.0.1` - Bug fix
- `v1.1.0` - New feature
- `v2.0.0` - Major update

## Pre-releases

For beta/test versions:

```bash
git tag -a v1.0.0-beta.1 -m "PawChat v1.0.0 Beta 1"
git push origin v1.0.0-beta.1
```

GitHub Actions will still build and upload APKs.

## Release Notes

GitHub automatically generates release notes from:
- Commit messages
- Pull requests
- Tag message

To customize, edit release after creation or include in tag message:

```bash
git tag -a v1.0.0 -m "PawChat v1.0.0

New Features:
- Feature 1
- Feature 2

Bug Fixes:
- Fix 1
- Fix 2"
```

## Security Notes

### APK Signing

Current setup uses debug signing. For production releases:

1. Generate release keystore
2. Add keystore to GitHub Secrets
3. Update workflow to sign APKs

### Secrets

Never commit sensitive data. Use GitHub Secrets:

```yaml
env:
  KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
```

## Examples

### First Release (v1.0.0)

```bash
# Update version
# pubspec.yaml: version: 1.0.0+1

# Commit
git add pubspec.yaml
git commit -m "release: v1.0.0"
git push origin main

# Tag
git tag -a v1.0.0 -m "PawChat v1.0.0 - Initial Release"
git push origin v1.0.0
```

### Bug Fix Release (v1.0.1)

```bash
# Fix bugs, commit changes
git add -A
git commit -m "fix: connection issue"
git push origin main

# Tag
git tag -a v1.0.1 -m "PawChat v1.0.1 - Bug Fix"
git push origin v1.0.1
```

### Feature Release (v1.1.0)

```bash
# Add features, commit
git add -A
git commit -m "feat: add session management"
git push origin main

# Tag
git tag -a v1.1.0 -m "PawChat v1.1.0 - Session Management"
git push origin v1.1.0
```

## Monitoring

### GitHub Actions

https://github.com/pawpaw-agent/pawchat/actions

Shows:
- All workflow runs
- Build status
- Build duration
- Logs

### Releases

https://github.com/pawpaw-agent/pawchat/releases

Shows:
- All releases
- APK assets
- Download counts
- Release notes

## Support

Issues with releases?

- **Guide:** This document
- **Automation:** [AUTOMATED_BUILD.md](AUTOMATED_BUILD.md)
- **Issues:** https://github.com/pawpaw-agent/pawchat/issues

---

**Last Updated:** 2026-03-10  
**Workflow Version:** 2.0  
**Status:** ✅ Ready for Release
