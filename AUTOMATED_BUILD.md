# PawChat Automated Build Guide

This guide explains how the automated APK building system works.

## Overview

PawChat uses GitHub Actions to automatically build APKs and upload them to GitHub Releases. No manual building required!

## How It Works

### Workflow Trigger

When you create and push a **tag** with version format (e.g., `v1.0.1`):

```bash
git tag v1.0.1
git push origin v1.0.1
```

### Automated Process

GitHub Actions automatically:

1. ✅ **Detects the tag** - Triggers `release.yml` workflow
2. ✅ **Creates Release** - Creates GitHub Release from tag
3. ✅ **Sets up Flutter** - Installs Flutter 3.x
4. ✅ **Builds APKs** - Compiles debug and release APKs
5. ✅ **Uploads APKs** - Attaches APKs to Release as assets

### Timeline

| Step | Time | Status |
|------|------|--------|
| Tag push | 0s | ✅ Immediate |
| Workflow trigger | 5-10s | ✅ Automatic |
| Flutter setup | 1-2 min | 🔄 In progress |
| Build APKs | 3-5 min | 🔄 In progress |
| Upload to Release | 10-30s | ✅ Complete |
| **Total** | **5-8 min** | ✅ **Complete** |

## For Users: Downloading APKs

### Step 1: Go to Releases

Visit: https://github.com/pawpaw-agent/pawchat/releases

### Step 2: Find Latest Release

Look for the most recent release (e.g., v1.0.1)

### Step 3: Wait for Build

If you see **"Assets"** section with:
- ✅ `PawChat-1.0.1-debug.apk`
- ✅ `PawChat-1.0.1-release.apk`

→ Build is complete! Download and install.

If you **don't see APKs yet**:
- Build is still in progress
- Wait 5-10 minutes
- Refresh the page

### Step 4: Check Build Status

Click **"Actions"** tab to see build progress:
https://github.com/pawpaw-agent/pawchat/actions

Look for the running workflow with your tag name.

### Step 5: Download and Install

Once build completes:

1. Click `PawChat-1.0.1-release.apk` to download
2. Transfer to Android device
3. Install (enable "Unknown sources" if prompted)
4. Open and configure

## For Developers: Creating Releases

### Create a New Release

```bash
# 1. Update version in pubspec.yaml
version: 1.0.2+2

# 2. Commit changes
git add pubspec.yaml
git commit -m "bump: version to 1.0.2"
git push origin main

# 3. Create tag
git tag -a v1.0.2 -m "PawChat v1.0.2"

# 4. Push tag (triggers build)
git push origin v1.0.2
```

### GitHub Release Created Automatically

The workflow will:
- Create GitHub Release from tag
- Build APKs automatically
- Upload APKs to Release

### Manual Release Creation (Optional)

If you want to create release manually first:

```bash
gh release create v1.0.2 --title "PawChat v1.0.2" --generate-notes
git push origin v1.0.2
```

The workflow will still trigger and upload APKs.

## Workflow Files

### release.yml

Location: `.github/workflows/release.yml`

**Triggers:**
- Push to tags matching `v*`

**Jobs:**
1. `create-release` - Creates GitHub Release
2. `build` - Builds and uploads APKs

**Outputs:**
- Debug APK: `PawChat-{version}-debug.apk`
- Release APK: `PawChat-{version}-release.apk`

### build.yml

Location: `.github/workflows/build.yml`

**Triggers:**
- Push to main branch
- Pull requests
- Release published

**Purpose:**
- Continuous integration
- Build verification
- Artifact storage

## Build Configuration

### Flutter Version

```yaml
uses: subosito/flutter-action@v2
with:
  flutter-version: '3.x'
  channel: 'stable'
```

### Build Commands

```bash
# Install dependencies
flutter pub get

# Generate code (Hive adapters)
flutter pub run build_runner build

# Build APKs
flutter build apk --debug
flutter build apk --release
```

### APK Locations

After build:
```
build/app/outputs/flutter-apk/
├── app-debug.apk
└── app-release.apk
```

Uploaded as:
```
PawChat-{version}-debug.apk
PawChat-{version}-release.apk
```

## Troubleshooting

### Build Failed

**Check:**
1. Go to Actions tab
2. Click failed workflow
3. Review error logs

**Common issues:**
- Flutter version mismatch
- Dependency conflicts
- Code generation errors
- Test failures

### APKs Not Uploaded

**Possible causes:**
- Build still in progress (wait 5-10 min)
- Workflow failed (check Actions)
- Permission issues (GITHUB_TOKEN)

**Solution:**
1. Check Actions tab for status
2. Review workflow logs
3. Fix any errors
4. Delete failed release
5. Create new tag (e.g., v1.0.3)
6. Push tag to retry

### Need to Rebuild

**Option 1: Delete and recreate tag**

```bash
# Delete local tag
git tag -d v1.0.1

# Delete remote tag
git push origin :refs/tags/v1.0.1

# Recreate and push
git tag -a v1.0.1 -m "PawChat v1.0.1"
git push origin v1.0.1
```

**Option 2: Create new patch version**

```bash
git tag -a v1.0.2 -m "PawChat v1.0.2 (rebuild)"
git push origin v1.0.2
```

## Monitoring Builds

### GitHub Actions Tab

https://github.com/pawpaw-agent/pawchat/actions

Shows:
- All workflow runs
- Build status (success/failure)
- Build duration
- Logs and output

### Release Page

https://github.com/pawpaw-agent/pawchat/releases

Shows:
- Released versions
- Attached APK assets
- Release notes
- Download counts

## Best Practices

### Version Numbering

Follow semantic versioning:
- `v1.0.0` - Major release
- `v1.0.1` - Patch (bug fixes)
- `v1.1.0` - Minor (new features)

### Pre-releases

For beta/test versions:

```bash
git tag -a v1.0.0-beta.1 -m "PawChat v1.0.0 Beta 1"
git push origin v1.0.0-beta.1
```

### Release Notes

Always include meaningful release notes:

```bash
git tag -a v1.0.1 -m "PawChat v1.0.1

Changes:
- Fixed connection issue
- Improved error handling
- Updated dependencies"
```

## Cost

GitHub Actions is **free** for public repositories:
- ✅ Unlimited public workflows
- ✅ 2,000 minutes/month included
- ✅ 500 MB storage included

PawChat builds use ~5-8 minutes each.

## Security

### APK Signing

Current setup uses debug signing. For production:

1. Generate release key
2. Store in GitHub Secrets
3. Update workflow to sign APKs

### Secrets

Never commit sensitive data. Use GitHub Secrets:

```yaml
env:
  KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
```

## Future Enhancements

Planned improvements:
- [ ] Automatic version bumping
- [ ] Changelog generation
- [ ] Release key signing
- [ ] Play Store deployment
- [ ] Beta channel releases

## Support

Need help?

- **Documentation:** See [BUILDING.md](BUILDING.md)
- **Issues:** https://github.com/pawpaw-agent/pawchat/issues
- **Discussions:** https://github.com/pawpaw-agent/pawchat/discussions

---

**Last Updated:** 2026-03-10  
**Workflow Version:** 1.0  
**Status:** ✅ Operational
