# Flutter WebSocket Research Findings

**Researcher:** researcher  
**Date:** 2026-03-10  
**Topic:** Flutter WebSocket Best Practices for Android Chat Applications

## 1. WebSocket Package Selection

### Recommended: `web_socket_channel`

**Why:**
- Officially recommended by Flutter team
- Cross-platform support (iOS, Android, Web)
- Built on top of `dart:io` WebSocket for native platforms
- Active maintenance and good documentation

**Alternative Packages:**
- `flutter_websocket` - Less maintained
- `websocket_universal` - More complex, better for advanced use cases
- `native_websocket` - Platform-specific implementations

**Installation:**
```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

## 2. Connection Management

### Best Practices

#### 2.1 Singleton Pattern for WebSocket Service
```dart
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();
  
  WebSocketChannel? _channel;
}
```

**Rationale:** Ensures single connection across app, prevents resource leaks.

#### 2.2 Connection State Management
```dart
enum ConnectionState { disconnected, connecting, connected, error }

final _stateController = StreamController<ConnectionState>.broadcast();
Stream<ConnectionState> get connectionStream => _stateController.stream;
```

**Rationale:** UI can react to connection changes in real-time.

#### 2.3 Reconnection Strategy
```dart
Future<void> reconnect({int retries = 3, int delayMs = 5000}) async {
  for (int i = 0; i < retries; i++) {
    try {
      await Future.delayed(Duration(milliseconds: delayMs * (i + 1)));
      await connect();
      if (_state == ConnectionState.connected) return;
    } catch (e) {
      if (i == retries - 1) rethrow;
    }
  }
}
```

**Best Practice:** Exponential backoff prevents server overload.

## 3. Message Framing & Parsing

### OpenClaw Gateway Protocol v3 Format

#### Request Frame
```json
{
  "type": "req",
  "id": "uuid-here",
  "method": "chat.send",
  "params": {
    "channel": "default",
    "content": "Hello"
  }
}
```

#### Response Frame
```json
{
  "type": "res",
  "id": "uuid-here",
  "ok": true,
  "payload": {...}
}
```

#### Event Frame
```json
{
  "type": "event",
  "event": "chat.message",
  "payload": {
    "from": "agent",
    "content": "Hi there!",
    "timestamp": 1710000000000
  }
}
```

### Parsing Best Practices

```dart
void _handleMessage(dynamic data) {
  try {
    final message = jsonDecode(data as String) as Map<String, dynamic>;
    
    switch (message['type']) {
      case 'res':
        _handleResponse(message);
        break;
      case 'event':
        _handleEvent(message);
        break;
      default:
        _handleUnknown(message);
    }
  } catch (e) {
    // Log error, don't crash
    print('Message parse error: $e');
  }
}
```

**Key Points:**
- Always wrap in try-catch
- Validate message structure before accessing fields
- Use `as?` for safe casting
- Log errors for debugging

## 4. State Management Integration

### Provider Pattern

```dart
class ChatProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  List<Message> _messages = [];
  
  ChatProvider() {
    _wsService.messageStream.listen((msg) {
      _messages.add(Message.fromMap(msg));
      notifyListeners();
    });
  }
  
  List<Message> get messages => _messages;
  
  Future<void> sendMessage(String content) async {
    await _wsService.sendMessage(content);
  }
}

// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    Provider.value(value: WebSocketService()),
  ],
  child: MyApp(),
)
```

### Riverpod Alternative

```dart
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  return ChatNotifier(ref.watch(webSocketServiceProvider));
});
```

**Recommendation:** Use Provider for simplicity, Riverpod for complex apps.

## 5. Background Execution

### Android Considerations

#### 5.1 Foreground Service (for persistent connection)
```dart
// Use flutter_foreground_task package
dependencies:
  flutter_foreground_task: ^8.0.0
```

**When Needed:**
- Keep WebSocket alive when app in background
- Receive push-like notifications
- Maintain real-time sync

#### 5.2 Work Manager for Periodic Sync
```dart
dependencies:
  workmanager: ^0.5.1
```

**Use Case:** Reconnect if connection lost in background.

#### 5.3 Platform-Specific Handling

```dart
import 'package:flutter/foundation.dart';

void initBackgroundHandling() {
  if (!kIsWeb) {
    // Native platform code for background execution
    // Use platform channels if needed
  }
}
```

### Best Practices

1. **Graceful Disconnect:** Save state before app terminates
2. **Quick Reconnect:** Reconnect when app resumes
3. **Battery Optimization:** Don't keep alive unnecessarily
4. **User Control:** Let users enable/disable background sync

## 6. Error Handling

### Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `WebSocketException: Connection closed` | Network loss | Implement reconnection |
| `HandshakeException` | Wrong URL/port | Validate gateway config |
| `TimeoutException` | Server not responding | Add timeout handling |
| `FormatException` | Invalid JSON | Validate message structure |

### Error Recovery Strategy

```dart
enum ErrorType { network, auth, protocol, server }

void handleError(dynamic error, ErrorType type) {
  switch (type) {
    case ErrorType.network:
      // Trigger reconnection
      reconnect();
      break;
    case ErrorType.auth:
      // Clear token, show login
      clearAuth();
      break;
    case ErrorType.protocol:
      // Log and report
      reportProtocolError(error);
      break;
    case ErrorType.server:
      // Show user-friendly message
      showServerError();
      break;
  }
}
```

## 7. Security Best Practices

### 7.1 Secure Storage
```dart
dependencies:
  flutter_secure_storage: ^9.0.0

// Usage
final storage = FlutterSecureStorage();
await storage.write(key: 'device_token', value: token);
```

### 7.2 TLS/SSL
```dart
// Always use wss:// in production
final channel = WebSocketChannel.connect(Uri.parse('wss://gateway.example.com'));
```

### 7.3 Certificate Pinning (Advanced)
```dart
// Use with custom SecurityContext
final context = SecurityContext();
context.setTrustedCertificatesBytes(certificateBytes);
```

## 8. Testing Strategies

### Unit Testing WebSocket Service

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockWebSocketChannel extends Mock implements WebSocketChannel {}

void main() {
  test('WebSocketService sends connect request', () {
    final service = WebSocketService();
    final mockChannel = MockWebSocketChannel();
    
    // Test implementation
  });
}
```

### Integration Testing

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Full chat flow', (tester) async {
    // Test complete user flow
  });
}
```

## 9. Performance Optimization

### 9.1 Message Batching
```dart
// Batch multiple messages before sending
void sendBatchedMessages(List<String> messages) {
  // Send as single request if protocol supports
}
```

### 9.2 Connection Pooling
Not needed for single-gateway apps. Use singleton pattern instead.

### 9.3 Memory Management
```dart
@override
void dispose() {
  _channel?.sink.close();
  _stateController.close();
  _messageController.close();
  super.dispose();
}
```

## 10. Recommended Project Structure

```
lib/
├── main.dart
├── models/
│   ├── message.dart
│   ├── session.dart
│   └── gateway_config.dart
├── services/
│   ├── websocket_service.dart
│   ├── chat_service.dart
│   └── storage_service.dart
├── screens/
│   ├── chat_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── message_bubble.dart
│   └── connection_status.dart
└── utils/
    ├── constants.dart
    └── validators.dart
```

## 11. Dependencies Summary

```yaml
dependencies:
  flutter:
    sdk: flutter
  web_socket_channel: ^2.4.0        # WebSocket
  provider: ^6.0.0                   # State management
  hive: ^2.2.3                       # Local storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0    # Secure token storage
  uuid: ^4.0.0                       # Unique IDs
  crypto: ^3.0.3                     # Cryptography
  pointycastle: ^3.7.4              # Ed25519 signatures
  intl: ^0.18.1                      # Date formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.3                    # Mocking for tests
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
```

## 12. Common Pitfalls to Avoid

1. ❌ **Multiple WebSocket instances** - Use singleton
2. ❌ **Not closing connections** - Always dispose properly
3. ❌ **Blocking UI thread** - Use async/await
4. ❌ **No error handling** - Wrap all WebSocket ops in try-catch
5. ❌ **Hardcoding gateway URL** - Use configurable settings
6. ❌ **Storing tokens in plaintext** - Use flutter_secure_storage
7. ❌ **No reconnection logic** - Implement exponential backoff
8. ❌ **Not validating messages** - Always check message structure

## Conclusion

For PawChat, recommend:
- **Package:** web_socket_channel
- **State Management:** Provider (simpler) or Riverpod (scalable)
- **Storage:** Hive + flutter_secure_storage
- **Pattern:** Singleton WebSocket service with Stream-based messaging
- **Security:** Ed25519 device identity, WSS for transport

---

**Research Completed:** 2026-03-10  
**Confidence Level:** High  
**Sources:** Flutter docs, web_socket_channel README, OpenClaw Gateway Protocol v3
