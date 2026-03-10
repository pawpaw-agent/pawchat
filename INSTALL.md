# PawChat Installation Guide

This guide covers installation methods for PawChat on Android devices.

## Installation Methods

Choose the method that works best for you:

1. **Pre-built APK** (Easiest) - Download from GitHub Releases
2. **Build from Source** (Advanced) - Compile yourself
3. **Google Play Store** (Future) - Coming soon

---

## Method 1: Pre-built APK (Recommended)

### Step 1: Download APK

1. Go to [GitHub Releases](https://github.com/pawpaw-agent/pawchat/releases)
2. Find the latest release (e.g., v1.0.0)
3. Download `app-release.apk` under "Assets"

### Step 2: Enable Unknown Sources

Android blocks apps from unknown sources by default. Enable it:

#### Android 8.0+

1. When prompted during installation, tap **Settings**
2. Enable **Allow from this source**
3. Go back and tap **Install**

#### Android 7.0 and earlier

1. Go to **Settings** → **Security**
2. Enable **Unknown sources**
3. Confirm the warning

### Step 3: Install APK

1. Open **Downloads** folder or file manager
2. Tap `app-release.apk`
3. Tap **Install**
4. Wait for installation to complete
5. Tap **Open** to launch PawChat

### Step 4: Verify Installation

1. Find PawChat in app drawer
2. Icon should show a paw/chat bubble
3. Tap to open
4. You should see the splash screen

---

## Method 2: Build from Source

See [BUILDING.md](BUILDING.md) for detailed build instructions.

### Quick Build

```bash
# Clone
git clone https://github.com/pawpaw-agent/pawchat.git
cd pawchat

# Build
./build-apk.sh

# Install
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Method 3: Install via ADB (Developers)

For developers and testers:

### Prerequisites

- Android device with USB debugging enabled
- ADB installed on computer
- USB cable

### Steps

```bash
# Connect device
adb devices

# Verify device is connected
# Should show device ID

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install and replace existing
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## System Requirements

### Android Version

- **Minimum:** Android 5.0 (API 21)
- **Recommended:** Android 10+ (API 29+)

### Device Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 2 GB | 4 GB |
| Storage | 100 MB | 500 MB |
| Screen | 480x800 | 1080x1920 |
| Network | WiFi | WiFi + Mobile Data |

### Network Requirements

- **Local Network:** Same LAN as OpenClaw Gateway
- **Remote Access:** Tailscale or VPN (optional)

---

## Post-Installation Setup

### 1. Find Gateway IP

On your computer running OpenClaw:

```bash
openclaw gateway status
```

Note the IP address (e.g., `192.168.1.100`).

### 2. Configure PawChat

1. Open PawChat
2. Enter Gateway Name (e.g., "Home")
3. Enter Host IP (e.g., `192.168.1.100`)
4. Enter Port (default: `8080`)
5. Enable TLS if using WSS
6. Tap **Connect**

### 3. Test Connection

1. Wait for "Connected" status
2. Type a test message
3. You should receive a response from OpenClaw

---

## Troubleshooting

### Installation Failed

**Problem:** "App not installed" error

**Solutions:**
- Uninstall any previous version first
- Check available storage space
- Verify APK is not corrupted (re-download)
- Enable "Install from unknown sources"

### App Crashes on Launch

**Problem:** App closes immediately

**Solutions:**
- Check Android version (must be 5.0+)
- Clear app data: Settings → Apps → PawChat → Storage → Clear Data
- Reinstall the app
- Check logcat for errors: `adb logcat | grep pawchat`

### Cannot Connect to Gateway

**Problem:** Connection fails or times out

**Solutions:**
1. **Check network:**
   - Both devices on same WiFi network
   - No guest network isolation
   - Try pinging gateway from phone

2. **Check gateway:**
   - Gateway is running: `openclaw gateway status`
   - Port 8080 is not blocked by firewall
   - Gateway IP is correct

3. **Check settings:**
   - IP address is correct
   - Port is correct (default: 8080)
   - TLS setting matches gateway configuration

### Messages Not Sending

**Problem:** Messages stuck in "sending" state

**Solutions:**
- Check connection status indicator
- Reconnect to gateway
- Check gateway logs for errors
- Verify gateway is accepting messages

### App Runs Slowly

**Problem:** Lag or slow performance

**Solutions:**
- Close other apps
- Clear app cache: Settings → Apps → PawChat → Storage → Clear Cache
- Restart device
- Check available storage space

---

## Uninstallation

### Via Settings

1. Go to **Settings** → **Apps**
2. Find **PawChat**
3. Tap **Uninstall**
4. Confirm

### Via ADB

```bash
adb uninstall com.pawpaw.pawchat
```

### Manual

1. Long-press PawChat icon
2. Drag to **Uninstall** or tap **Ⓧ**
3. Confirm

---

## Updates

### Manual Update

1. Download new APK from [Releases](https://github.com/pawpaw-agent/pawchat/releases)
2. Install over existing version
3. Data is preserved (messages, settings)

### Automatic Update (Future)

In-app update checker coming in v1.2.0.

---

## Data Backup

### Local Data Location

PawChat stores data locally:
- Messages: Hive database
- Settings: SharedPreferences
- Tokens: Android Keystore (encrypted)

### Backup Methods

#### Method 1: ADB Backup

```bash
# Backup app data
adb backup -f pawchat-backup.ab com.pawpaw.pawchat

# Restore app data
adb restore pawchat-backup.ab
```

#### Method 2: Root Required

Copy data files from:
```
/data/data/com.pawpaw.pawchat/
```

### Note

Currently, PawChat does not have cloud sync. Data is device-specific.

---

## Security Considerations

### APK Verification

Verify APK integrity:

```bash
# Check SHA256 checksum
sha256sum app-release.apk

# Compare with checksum in release notes
```

### Permissions

PawChat requests minimal permissions:
- **Network:** Required for WebSocket connection
- **Storage:** For local message storage (optional on Android 10+)

No camera, microphone, or location access required.

### Unknown Sources Warning

Installing from unknown sources is safe when:
- Downloading from official GitHub Releases
- Verifying checksum
- Building from source yourself

**Never** install APKs from untrusted sources.

---

## Getting Help

### Resources

- **Documentation:** [README.md](README.md)
- **Build Guide:** [BUILDING.md](BUILDING.md)
- **Issues:** https://github.com/pawpaw-agent/pawchat/issues
- **Discussions:** https://github.com/pawpaw-agent/pawchat/discussions

### Report Issues

When reporting installation issues, include:

1. Android version
2. Device model
3. PawChat version
4. Installation method
5. Error messages
6. Steps to reproduce

---

## Next Steps

After successful installation:

1. ✅ Configure gateway connection
2. ✅ Test messaging
3. ✅ Explore features
4. ✅ Read [README.md](README.md) for usage guide

---

**Installation Support:** https://github.com/pawpaw-agent/pawchat/issues
