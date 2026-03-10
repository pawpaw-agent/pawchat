# PawChat Building Guide

This guide explains how to build PawChat APK from source.

## Prerequisites

### Required Software

1. **Flutter SDK** (3.x or later)
   - Installation: https://docs.flutter.dev/get-started/install
   - Verify: `flutter --version`

2. **Android Studio** (for Android SDK)
   - Installation: https://developer.android.com/studio
   - Required components:
     - Android SDK Platform (API 21+)
     - Android SDK Build-Tools
     - Android SDK Command-line Tools

3. **Java Development Kit** (JDK 17 or later)
   - Installation: https://adoptium.net/
   - Verify: `java -version`

4. **Git**
   - Installation: https://git-scm.com/
   - Verify: `git --version`

### Environment Setup

#### Linux/macOS

Add Flutter to your PATH:

```bash
export PATH="$PATH:/path/to/flutter/bin"
```

Add to `~/.bashrc` or `~/.zshrc` for persistence.

#### Windows

Add Flutter to PATH through System Properties → Environment Variables.

## Quick Build

### Using Build Script (Recommended)

```bash
# Clone repository
git clone https://github.com/pawpaw-agent/pawchat.git
cd pawchat

# Make build script executable
chmod +x build-apk.sh

# Run build script
./build-apk.sh
```

The script will:
1. Install dependencies
2. Generate code (Hive adapters)
3. Analyze code
4. Run tests
5. Build debug APK
6. Build release APK

### Manual Build

```bash
# Clone repository
git clone https://github.com/pawpaw-agent/pawchat.git
cd pawchat

# Create Android project (if first build)
flutter create --platforms=android .

# Install dependencies
flutter pub get

# Generate code (Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests (optional)
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## Build Outputs

After successful build, APKs are located at:

```
build/app/outputs/flutter-apk/
├── app-debug.apk      # Debug build (for testing)
└── app-release.apk    # Release build (for distribution)
```

## Installation

### Via ADB (Android Debug Bridge)

```bash
# Install debug APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Install release APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Install and replace existing
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Direct Transfer

1. Copy APK to Android device
2. Open file manager on device
3. Tap APK file
4. Allow installation from unknown sources if prompted
5. Install

## Troubleshooting

### Flutter Doctor Issues

Run `flutter doctor` to check your setup:

```bash
flutter doctor -v
```

Fix any issues reported before building.

### Common Issues

#### 1. "Flutter command not found"

**Solution:** Add Flutter to PATH

```bash
export PATH="$PATH:/path/to/flutter/bin"
```

#### 2. "Android license status unknown"

**Solution:** Accept Android licenses

```bash
flutter doctor --android-licenses
```

#### 3. "Gradle build failed"

**Solution:** Clean and rebuild

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

#### 4. "Hive adapter not found"

**Solution:** Regenerate Hive adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 5. "Build failed due to minification"

**Solution:** Disable minification for debugging

Edit `android/app/build.gradle`:

```gradle
buildTypes {
    release {
        minifyEnabled false  # Change to false temporarily
    }
}
```

## Build Configuration

### Version Management

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1  # version+build_number
```

### App ID

Edit `android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.pawpaw.pawchat"
    # Change to your unique ID for Play Store
}
```

### Signing Release APK

For production releases, sign the APK:

1. Generate keystore:

```bash
keytool -genkey -v -keystore pawchat-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pawchat
```

2. Create `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=pawchat
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle`:

```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Continuous Integration

PawChat uses GitHub Actions for automated builds. See `.github/workflows/build.yml`.

### Build Triggers

- **Push to main:** Build debug and release APKs
- **Pull request:** Build and upload artifacts
- **Tag (v*):** Build and create GitHub Release

### Build Artifacts

APKs are uploaded as GitHub Actions artifacts and attached to releases.

## Performance Tips

### Faster Builds

1. **Enable build cache:**

```bash
export GRADLE_USER_HOME=~/.gradle
```

2. **Use daemon:**

```bash
flutter config --no-android-studio
```

3. **Build only what you need:**

```bash
# Debug only
flutter build apk --debug

# Release only
flutter build apk --release
```

### Clean Build

For a completely fresh build:

```bash
flutter clean
flutter pub get
flutter build apk
```

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4 GB | 8 GB |
| Disk Space | 2.8 GB | 5 GB |
| OS | 64-bit Linux/Windows/macOS | Latest version |
| Android SDK | API 21+ | API 34 |

## Build Time Estimates

| Operation | Time (approx) |
|-----------|---------------|
| First build | 5-10 minutes |
| Subsequent builds | 1-3 minutes |
| Clean build | 3-5 minutes |
| Tests | 30-60 seconds |

## Next Steps

After building:

1. Test the APK on real devices
2. Review [INSTALL.md](INSTALL.md) for installation guide
3. Check [README.md](README.md) for usage instructions

---

**For more help:**
- Flutter Docs: https://docs.flutter.dev/
- Android Build: https://developer.android.com/studio/build
- GitHub Issues: https://github.com/pawpaw-agent/pawchat/issues
