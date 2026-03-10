# GitHub Release v1.0.0 - Updated Notes

**Note to releaser:** Use these updated release notes to edit the v1.0.0 release on GitHub.

---

## 🐾 PawChat v1.0.0 - Initial Release (Source Code)

**Release Type:** Source Code Release (APK must be built from source)  
**Date:** 2026-03-10  
**License:** MIT

### ⚠️ Important: Source Code Release

This is a **source code release**. Pre-built APK binaries are not included.

**To use PawChat, you must build the APK yourself.** See instructions below.

**Why source-only?**
- This is an initial release for testing and feedback
- Allows users to verify code before building
- Enables customization for different environments
- CI/CD pipeline will provide pre-built APKs in future releases

### 📦 Installation Options

#### Option 1: Build APK Yourself (Current)

**Quick Build:**

```bash
# Clone repository
git clone https://github.com/pawpaw-agent/pawchat.git
cd pawchat

# Run build script
chmod +x build-apk.sh
./build-apk.sh

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Requirements:**
- Flutter SDK 3.x
- Android Studio / Android SDK
- JDK 17+

**Full Instructions:** See [BUILDING.md](BUILDING.md) and [INSTALL.md](INSTALL.md)

#### Option 2: Wait for Pre-built APK (Future)

Pre-built APKs will be available in future releases (v1.1.0+).

Watch this repository for updates: https://github.com/pawpaw-agent/pawchat

### ✨ Features

- 🔌 **WebSocket Connection** - Connect to OpenClaw Gateway over LAN
- 💬 **Real-time Chat** - Send/receive messages with OpenClaw agents  
- 📱 **Session Management** - Create and manage multiple chat sessions
- 💾 **Local Storage** - Messages stored locally with Hive
- 🔒 **Secure Auth** - Ed25519 device identity + token authentication
- 🎨 **Modern UI** - Material Design 3 with smooth animations
- 🔐 **TLS Support** - WSS for encrypted transport

### 🏗️ Architecture

**Clean Architecture Pattern:**
- **Presentation Layer:** Screens & Widgets (Flutter UI)
- **Business Logic:** Services (WebSocket, Chat, Auth, Storage)
- **Data Layer:** Models & Repositories (Hive, Secure Storage)

**Tech Stack:**
- Flutter 3.x, Dart 3.x
- web_socket_channel ^2.4.0
- provider ^6.0.0
- hive ^2.2.3
- flutter_secure_storage ^9.0.0

### 📋 Building Instructions

#### Prerequisites

1. **Flutter SDK** - https://docs.flutter.dev/get-started/install
2. **Android Studio** - https://developer.android.com/studio
3. **JDK 17+** - https://adoptium.net/

#### Build Steps

```bash
# 1. Clone repository
git clone https://github.com/pawpaw-agent/pawchat.git
cd pawchat

# 2. Install dependencies
flutter pub get

# 3. Generate code (Hive adapters)
flutter pub run build_runner build

# 4. Build release APK
flutter build apk --release

# 5. Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### Automated Build

Use the included build script:

```bash
chmod +x build-apk.sh
./build-apk.sh
```

This script handles all steps automatically.

### 📖 Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | Project overview and usage |
| [INSTALL.md](INSTALL.md) | Installation guide |
| [BUILDING.md](BUILDING.md) | Build instructions |
| [PAWCHAT-ARCHITECTURE.md](PAWCHAT-ARCHITECTURE.md) | Architecture design |
| [SECURITY_REVIEW.md](SECURITY_REVIEW.md) | Security audit |
| [CODE_REVIEW.md](CODE_REVIEW.md) | Code review |

### 🔒 Security

- ✅ Security reviewed and approved
- ✅ Code reviewed and approved
- ✅ Ed25519 device identity (placeholder in v1.0.0)
- ✅ Secure token storage (Android Keystore)
- ✅ TLS/WSS support
- ✅ Input validation

**Note:** Enable TLS (WSS) for non-LAN deployments.

### 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

**Test Coverage:** ~60% (14 test cases)

### 📊 Stats

- **Total Files:** 32
- **Lines of Code:** ~4,500
- **Test Files:** 3
- **Documentation:** 8 files
- **Build Scripts:** 2
- **CI/CD:** GitHub Actions configured

### ⚠️ Known Limitations (v1.0.0)

1. **Source-only release** - No pre-built APK
2. **Ed25519 crypto** - Placeholder implementation
3. **Test coverage** - At ~60%, target 80% for v1.1.0
4. **No integration tests** - Planned for v1.1.0

### 🚧 Roadmap

**v1.1.0:**
- [ ] Pre-built APK releases
- [ ] Complete Ed25519 crypto implementation
- [ ] Integration tests
- [ ] Increased test coverage (80%)

**v1.2.0:**
- [ ] Biometric authentication
- [ ] Message encryption option
- [ ] Certificate pinning
- [ ] Play Integrity API

### 🔗 Links

- **Source Code:** https://github.com/pawpaw-agent/pawchat
- **Issues:** https://github.com/pawpaw-agent/pawchat/issues
- **Discussions:** https://github.com/pawpaw-agent/pawchat/discussions
- **OpenClaw:** https://openclaw.ai
- **Flutter:** https://flutter.dev

### 📝 Changelog

**v1.0.0 - Initial Release (2026-03-10)**

- ✅ WebSocket connection to OpenClaw Gateway
- ✅ Real-time chat functionality
- ✅ Session management
- ✅ Local message storage
- ✅ Secure authentication flow
- ✅ Material Design 3 UI
- ✅ Connection status monitoring
- ✅ TLS/WSS support
- ✅ Build automation scripts
- ✅ CI/CD pipeline
- ✅ Comprehensive documentation

### 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Powered by [OpenClaw](https://openclaw.ai)
- Protocol: OpenClaw Gateway Protocol v3

### 📄 License

MIT License - See [LICENSE](LICENSE) file.

---

**Build Date:** 2026-03-10  
**Release Type:** Source Code  
**Min Android:** API 21+ (5.0)  
**Protocol:** OpenClaw Gateway Protocol v3

**Need help building?** See [BUILDING.md](BUILDING.md) or open an issue.
