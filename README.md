# PawChat

**PawChat** is a Flutter-based Android application that enables real-time communication with OpenClaw Gateway via WebSocket.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/flutter-3.x-blue)
![Protocol](https://img.shields.io/badge/protocol-v3-green)
![Platform](https://img.shields.io/badge/platform-android-green)
![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- 🔌 **WebSocket Connection** - Connect to OpenClaw Gateway over local network
- 💬 **Real-time Chat** - Send and receive messages with OpenClaw agents
- 📱 **Session Management** - Create and manage multiple chat sessions
- 💾 **Local Storage** - Messages stored locally with Hive
- 🔒 **Secure Authentication** - Ed25519 device identity with token-based auth
- 🎨 **Modern UI** - Material Design 3 with smooth animations
- 🔐 **TLS Support** - Optional WSS for encrypted transport

## Screenshots

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Connection    │  │     Chat        │  │   Sessions      │
│     Screen      │  │    Screen       │  │    Screen       │
│                 │  │                 │  │                 │
│  [Gateway Name] │  │  ● Connected    │  │  + New Session  │
│  Host: ___      │  │                 │  │                 │
│  Port: ___      │  │  Agent: Hello!  │  │  Session 1  14:30│
│  [  Connect  ]  │  │  You: Hi        │  │  Session 2  14:25│
│  ☐ Use TLS      │  │  [Type...] [→]  │  │  Session 3  14:20│
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## Requirements

- **Android:** API 21+ (Android 5.0+)
- **OpenClaw Gateway:** v1.x with WebSocket enabled
- **Network:** Same local network (LAN) or Tailscale
- **Flutter:** 3.x (for building from source)

## Installation

### Download Release

Download the latest APK from [GitHub Releases](https://github.com/pawpaw-agent/pawchat/releases).

### Build from Source

```bash
# Clone repository
git clone https://github.com/pawpaw-agent/pawchat.git
cd pawchat

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## Usage

### 1. Find Gateway IP

On your computer running OpenClaw:

```bash
openclaw gateway status
```

Note the gateway address (e.g., `192.168.1.100:8080`).

### 2. Configure Connection

1. Open PawChat on your Android device
2. Enter **Gateway Name** (e.g., "Home Gateway")
3. Enter **Host IP** (e.g., `192.168.1.100`)
4. Enter **Port** (default: `8080`)
5. Enable **Use TLS** if using WSS
6. Tap **Connect**

### 3. Start Chatting

Once connected:
- Type messages in the input field
- Send messages to OpenClaw agents
- Create multiple sessions for different conversations
- View message history

## Project Structure

```
pawchat/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   │   ├── message.dart
│   │   ├── session.dart
│   │   └── gateway_config.dart
│   ├── services/              # Business logic
│   │   ├── websocket_service.dart
│   │   ├── chat_service.dart
│   │   ├── auth_service.dart
│   │   └── storage_service.dart
│   ├── screens/               # UI screens
│   │   ├── splash_screen.dart
│   │   ├── connection_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── sessions_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/               # Reusable widgets
│   │   ├── message_bubble.dart
│   │   ├── message_input.dart
│   │   └── connection_status.dart
│   └── utils/                 # Utilities
├── test/                      # Unit tests
│   ├── models/
│   └── services/
├── research/                  # Research findings
├── pubspec.yaml              # Dependencies
├── PAWCHAT-ARCHITECTURE.md   # Architecture design
├── SECURITY_REVIEW.md        # Security audit
├── CODE_REVIEW.md            # Code review
└── README.md                 # This file
```

## Architecture

PawChat follows **Clean Architecture** principles:

### Layers

1. **Presentation Layer** (UI)
   - Screens: Full-page components
   - Widgets: Reusable UI elements
   - Theme: App-wide styling

2. **Business Logic Layer** (Services)
   - WebSocketService: Connection management
   - ChatService: Message handling
   - AuthService: Authentication
   - StorageService: Data persistence

3. **Data Layer** (Models & Storage)
   - Models: Message, Session, GatewayConfig
   - Hive: Local NoSQL storage
   - FlutterSecureStorage: Encrypted credentials

### State Management

Uses **Provider** pattern for state management:

```dart
MultiProvider(
  providers: [
    Provider<WebSocketService>(create: (_) => WebSocketService()),
    Provider<ChatService>(create: (_) => ChatService()),
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<StorageService>(create: (_) => StorageService()),
  ],
  child: PawChatApp(),
)
```

### WebSocket Protocol

Implements **OpenClaw Gateway Protocol v3**:

1. **Connect** → Gateway sends challenge
2. **Authenticate** → Client signs challenge
3. **Token** → Gateway issues device token
4. **Chat** → Send/receive messages via `chat.send` / `chat.message`

See [PAWCHAT-ARCHITECTURE.md](PAWCHAT-ARCHITECTURE.md) for details.

## Development

### Setup

```bash
# Install Flutter dependencies
flutter pub get

# Generate code (Hive adapters)
flutter pub run build_runner build

# Run linter
flutter analyze

# Format code
dart format .
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/message_test.dart
```

### Code Generation

Hive requires code generation for type adapters:

```bash
# Build
flutter pub run build_runner build

# Watch mode
flutter pub run build_runner watch
```

## Security

### Security Measures

- ✅ **Device Identity:** Ed25519 keypair per device
- ✅ **Token Storage:** Android Keystore (hardware-backed)
- ✅ **TLS Support:** WSS for encrypted transport
- ✅ **Input Validation:** All user inputs validated
- ✅ **Secure Coding:** No hardcoded secrets

### Security Reviews

- **Security Review:** [SECURITY_REVIEW.md](SECURITY_REVIEW.md) ✅ Approved
- **Code Review:** [CODE_REVIEW.md](CODE_REVIEW.md) ✅ Approved

### Security Recommendations

For production deployment:
1. **Enable TLS** - Use WSS for all connections
2. **Add Biometric Auth** - Fingerprint/face unlock
3. **Certificate Pinning** - Prevent MITM attacks
4. **Code Obfuscation** - Enable R8/ProGuard

## Troubleshooting

### Connection Failed

**Problem:** Cannot connect to gateway

**Solutions:**
- Verify both devices are on the same network
- Check firewall allows port 8080
- Confirm OpenClaw Gateway is running: `openclaw gateway status`
- Try pinging the gateway IP from Android device

### Authentication Error

**Problem:** Authentication fails

**Solutions:**
- Clear app data and reconnect
- Check gateway pairing settings
- Verify device token is valid

### Messages Not Sending

**Problem:** Messages stuck in "sending" state

**Solutions:**
- Check connection status indicator
- Verify gateway is accepting messages
- Check message length (max 4096 chars)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing
- Write tests for new features
- Update documentation

## Dependencies

### Production

| Package | Version | Purpose |
|---------|---------|---------|
| web_socket_channel | ^2.4.0 | WebSocket communication |
| provider | ^6.0.0 | State management |
| hive | ^2.2.3 | Local storage |
| hive_flutter | ^1.1.0 | Hive Flutter integration |
| flutter_secure_storage | ^9.0.0 | Secure credential storage |
| uuid | ^4.0.0 | Unique ID generation |
| crypto | ^3.0.3 | Cryptographic operations |
| pointycastle | ^3.7.4 | Ed25519 signatures |
| intl | ^0.18.1 | Internationalization |

### Development

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_test | SDK | Testing framework |
| hive_generator | ^2.0.1 | Hive code generation |
| build_runner | ^2.4.7 | Code generation |
| mockito | ^5.4.3 | Mocking for tests |

## License

MIT License - See [LICENSE](LICENSE) file.

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Powered by [OpenClaw](https://openclaw.ai)
- Protocol: OpenClaw Gateway Protocol v3

## Links

- **Repository:** https://github.com/pawpaw-agent/pawchat
- **Issues:** https://github.com/pawpaw-agent/pawchat/issues
- **Releases:** https://github.com/pawpaw-agent/pawchat/releases
- **OpenClaw Docs:** https://docs.openclaw.ai

---

**Version:** 1.0.0  
**Build Date:** 2026-03-10  
**Min Android:** API 21+ (5.0)  
**Protocol:** OpenClaw Gateway Protocol v3
