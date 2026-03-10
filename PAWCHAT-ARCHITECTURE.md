# PawChat Architecture Design

**Project:** PawChat - Android WebSocket Client for OpenClaw Gateway  
**Version:** 1.0.0  
**Date:** 2026-03-10  
**Author:** architect  
**Status:** Approved

## 1. Executive Summary

PawChat is a Flutter-based Android application that provides real-time chat functionality by connecting to OpenClaw Gateway via WebSocket. This document defines the architectural blueprint for the application.

## 2. System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Local Network (LAN)                      │
│                                                              │
│  ┌──────────────┐         WebSocket          ┌────────────┐ │
│  │   Android    │ ◄────── ws://192.168.x.x:8080 ──► │  OpenClaw  │ │
│  │   Device     │      (Gateway Protocol v3) │  Gateway   │ │
│  │              │                              │            │ │
│  │   PawChat    │                              │  - Agents  │ │
│  │   (Flutter)  │                              │  - Skills  │ │
│  └──────────────┘                              └────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 3. Architecture Principles

1. **Separation of Concerns:** Clear boundaries between UI, business logic, and data
2. **Single Responsibility:** Each component has one well-defined purpose
3. **Dependency Injection:** Loose coupling through Provider pattern
4. **Reactive Programming:** Stream-based communication between layers
5. **Security by Design:** Authentication and encryption at every layer

## 4. Technology Stack

### 4.1 Core Technologies

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| Min SDK | Android | API 21+ (5.0) |

### 4.2 Key Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| web_socket_channel | WebSocket communication | ^2.4.0 |
| provider | State management | ^6.0.0 |
| hive | Local NoSQL storage | ^2.2.3 |
| flutter_secure_storage | Secure credential storage | ^9.0.0 |
| uuid | Unique ID generation | ^4.0.0 |
| crypto | Cryptographic operations | ^3.0.3 |
| pointycastle | Ed25519 signatures | ^3.7.4 |
| intl | Internationalization | ^0.18.1 |

## 5. Component Architecture

### 5.1 High-Level Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Screens   │  │   Widgets   │  │    Theme    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  WebSocket  │  │    Chat     │  │    Auth     │         │
│  │   Service   │  │   Service   │  │   Service   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│  ┌─────────────┐  ┌─────────────┐                          │
│  │   Storage   │  │  Session    │                          │
│  │   Service   │  │   Service   │                          │
│  └─────────────┘  └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Models    │  │    Hive     │  │   Secure    │         │
│  │             │  │   Boxes     │  │   Storage   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Component Responsibilities

#### Presentation Layer (frontend-coder domain)
- **Screens:** Full-page UI components with business logic integration
- **Widgets:** Reusable UI components
- **Theme:** App-wide styling and theming

#### Business Logic Layer (backend-coder domain)
- **WebSocketService:** Connection management, message framing
- **ChatService:** Message handling, session management
- **AuthService:** Authentication, token management
- **StorageService:** Local data persistence
- **SessionService:** Session lifecycle

#### Data Layer (backend-coder domain)
- **Models:** Data structures with serialization
- **Hive Boxes:** NoSQL local storage
- **Secure Storage:** Encrypted credential storage

## 6. Data Models

### 6.1 Message Model

```dart
class Message {
  String id;
  String sessionId;
  String content;
  MessageRole role;  // user, agent, system
  DateTime timestamp;
  MessageStatus status;  // sending, sent, delivered, failed
}
```

### 6.2 Session Model

```dart
class Session {
  String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  String? lastMessage;
  bool isActive;
}
```

### 6.3 GatewayConfig Model

```dart
class GatewayConfig {
  String id;
  String name;
  String host;
  int port;
  bool useTLS;
  String? deviceToken;
  DateTime? lastConnected;
  bool isActive;
  
  String get wsUrl => '${useTLS ? "wss" : "ws"}://$host:$port/gateway';
}
```

### 6.4 DeviceIdentity Model

```dart
class DeviceIdentity {
  String deviceId;      // Fingerprint of public key
  String publicKey;     // Base64 encoded
  String privateKey;    // Stored securely, never exposed
}
```

## 7. WebSocket Protocol Integration

### 7.1 Connection Flow

```
┌──────────┐                          ┌──────────┐
│ PawChat  │                          │ Gateway  │
└────┬─────┘                          └────┬─────┘
     │                                     │
     │────── WebSocket Connect ───────────►│
     │                                     │
     │◄───── connect.challenge ────────────│
     │         (nonce, ts)                 │
     │                                     │
     │────── connect request ─────────────►│
     │  (signed nonce, device info)        │
     │                                     │
     │◄───── hello-ok ─────────────────────│
     │    (protocol, deviceToken)          │
     │                                     │
     │◄══════════ Connected ══════════════►│
     │                                     │
```

### 7.2 Message Frame Types

#### Request Frame (Client → Gateway)
```json
{
  "type": "req",
  "id": "uuid-string",
  "method": "chat.send",
  "params": {
    "channel": "default",
    "content": "Message content",
    "session": "session-id"
  }
}
```

#### Response Frame (Gateway → Client)
```json
{
  "type": "res",
  "id": "uuid-string",
  "ok": true,
  "payload": {
    "type": "hello-ok",
    "protocol": 3
  }
}
```

#### Event Frame (Gateway → Client)
```json
{
  "type": "event",
  "event": "chat.message",
  "payload": {
    "from": "agent",
    "content": "Response content",
    "timestamp": 1710000000000,
    "sessionId": "session-id"
  }
}
```

### 7.3 Supported Methods

| Method | Direction | Description | Scope Required |
|--------|-----------|-------------|----------------|
| `connect` | C→S | Establish connection | None |
| `chat.send` | C→S | Send chat message | operator.write |
| `session.create` | C→S | Create new session | operator.write |
| `session.list` | C→S | List sessions | operator.read |
| `chat.message` | S→C | Incoming message | - |
| `session.updated` | S→C | Session state change | - |

## 8. Security Architecture

### 8.1 Authentication Flow

1. **First Connection:**
   - Generate Ed25519 keypair
   - Store private key in Android Keystore
   - Send public key with connect request
   - Receive device token from gateway

2. **Subsequent Connections:**
   - Retrieve stored device token
   - Include token in connect request
   - Gateway validates token
   - Re-authenticate if token invalid

### 8.2 Data Protection

| Data Type | Storage | Protection |
|-----------|---------|------------|
| Device Private Key | Android Keystore | Hardware-backed encryption |
| Device Token | FlutterSecureStorage | Encrypted SharedPreferences |
| Chat Messages | Hive | Local file (LAN trust model) |
| Gateway Config | Hive | Local file |

### 8.3 Transport Security

- **Default:** ws:// (LAN only, trusted network)
- **Recommended:** wss:// (TLS encrypted)
- **Certificate Pinning:** Optional for production

## 9. State Management

### 9.1 Provider Structure

```dart
MultiProvider(
  providers: [
    Provider<WebSocketService>(create: (_) => WebSocketService()),
    Provider<ChatService>(create: (_) => ChatService()),
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<StorageService>(create: (_) => StorageService()),
    ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
  ],
  child: PawChatApp(),
)
```

### 9.2 Reactive Streams

```dart
// WebSocket connection state
Stream<ConnectionState> get connectionStream;

// Incoming messages
Stream<Map<String, dynamic>> get messageStream;

// Chat messages list
Stream<List<Message>> get messagesStream;
```

## 10. Error Handling Strategy

### 10.1 Error Categories

| Category | Recovery | User Action |
|----------|----------|-------------|
| Network Error | Auto-reconnect | Show status |
| Auth Error | Re-authenticate | Re-enter credentials |
| Protocol Error | Log & report | Contact support |
| Server Error | Retry with backoff | Show message |

### 10.2 Error Boundaries

```dart
try {
  await webSocketService.connect(config);
} on WebSocketException catch (e) {
  // Network error - trigger reconnect
  handleError(ErrorType.network, e);
} on AuthException catch (e) {
  // Auth error - clear token
  handleError(ErrorType.auth, e);
} catch (e) {
  // Unknown error - log and report
  handleError(ErrorType.unknown, e);
}
```

## 11. Project Structure

```
pawchat/
├── android/                     # Android platform
├── ios/                         # iOS platform (future)
├── lib/
│   ├── main.dart               # ⚡ App entry point
│   ├── app.dart                # ⚡ App configuration
│   │
│   ├── models/                 # 🔵 Data models (backend-coder)
│   │   ├── message.dart
│   │   ├── session.dart
│   │   ├── gateway_config.dart
│   │   └── device_identity.dart
│   │
│   ├── services/               # 🔵 Business logic (backend-coder)
│   │   ├── websocket_service.dart
│   │   ├── chat_service.dart
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   └── session_service.dart
│   │
│   ├── screens/                # 🟢 UI screens (frontend-coder)
│   │   ├── splash_screen.dart
│   │   ├── connection_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── sessions_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── widgets/                # 🟢 Reusable widgets (frontend-coder)
│   │   ├── message_bubble.dart
│   │   ├── message_input.dart
│   │   ├── connection_status.dart
│   │   └── session_list.dart
│   │
│   └── utils/                  # ⚪ Utilities (shared)
│       ├── constants.dart
│       ├── validators.dart
│       └── theme.dart
│
├── test/                       # 🧪 Unit tests (tester-unit)
│   ├── models/
│   ├── services/
│   └── widgets/
│
├── assets/                     # 🎨 Static assets
│   ├── images/
│   └── icons/
│
├── pubspec.yaml               # 📦 Dependencies
└── README.md                  # 📖 Documentation
```

**Legend:**
- 🔵 backend-coder domain
- 🟢 frontend-coder domain
- 🧪 tester-unit domain
- ⚪ Shared utilities

## 12. Build & Deployment

### 12.1 Build Configuration

```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

### 12.2 Build Commands

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Build with analysis
flutter build apk --analyze
```

### 12.3 Version Management

```yaml
version: 1.0.0+1  # version+build_number
```

## 13. Testing Strategy

### 13.1 Test Pyramid

```
        /\
       /  \      E2E Tests (5%)
      /----\    
     /      \   Integration Tests (20%)
    /--------\  
   /          \ Unit Tests (75%)
  /------------\
```

### 13.2 Test Coverage Targets

| Component | Target | Tool |
|-----------|--------|------|
| Models | 90% | flutter_test |
| Services | 80% | flutter_test + mockito |
| Widgets | 70% | flutter_test |
| Screens | 50% | integration_test |

## 14. Performance Considerations

### 14.1 Memory Management

- Dispose all StreamControllers in service cleanup
- Use `const` constructors for immutable widgets
- Implement `AutomaticKeepAliveClientMixin` for chat screen

### 14.2 Network Optimization

- Implement message debouncing for typing indicators
- Batch multiple operations when possible
- Use exponential backoff for reconnection

### 14.3 Storage Optimization

- Limit message history to 100 messages per session
- Implement pagination for session list
- Clear old sessions automatically

## 15. Future Enhancements

### Phase 2 (Post-MVP)
- [ ] Push notifications via FCM
- [ ] Voice message support
- [ ] File attachment sharing
- [ ] Message reactions

### Phase 3 (Advanced)
- [ ] End-to-end encryption
- [ ] Multi-device sync
- [ ] Offline message queue
- [ ] Plugin system for themes

## 16. Architecture Decisions Record (ADR)

### ADR-001: WebSocket Package Selection

**Decision:** Use `web_socket_channel`  
**Rationale:** Official Flutter recommendation, cross-platform, well-maintained  
**Date:** 2026-03-10

### ADR-002: State Management

**Decision:** Use Provider pattern  
**Rationale:** Simpler learning curve, sufficient for app complexity  
**Date:** 2026-03-10

### ADR-003: Local Storage

**Decision:** Use Hive for messages, FlutterSecureStorage for credentials  
**Rationale:** Hive is fast and simple, secure storage for sensitive data  
**Date:** 2026-03-10

### ADR-004: Authentication

**Decision:** Ed25519 device identity with gateway-issued tokens  
**Rationale:** Follows OpenClaw Gateway Protocol v3 specification  
**Date:** 2026-03-10

---

**Document Version:** 1.0.0  
**Last Updated:** 2026-03-10  
**Approved By:** architect  
**Next Review:** After MVP completion
