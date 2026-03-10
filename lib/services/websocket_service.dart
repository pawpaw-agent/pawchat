import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../models/gateway_config.dart';

enum ConnectionState { disconnected, connecting, connected, error }

/// WebSocketService - Backend service for WebSocket communication
/// Responsible for: Connection management, message framing, protocol handling
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  ConnectionState _state = ConnectionState.disconnected;
  GatewayConfig? _currentGateway;
  
  final _connectionController = StreamController<ConnectionState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _uuid = const Uuid();

  // Stream accessors
  Stream<ConnectionState> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  
  // State accessors
  ConnectionState get state => _state;
  GatewayConfig? get currentGateway => _currentGateway;

  // Protocol version (OpenClaw Gateway Protocol v3)
  static const int minProtocol = 3;
  static const int maxProtocol = 3;

  /// Connect to OpenClaw Gateway
  Future<void> connect(GatewayConfig gateway) async {
    if (_state == ConnectionState.connected) {
      await disconnect();
    }

    _state = ConnectionState.connecting;
    _currentGateway = gateway;
    _connectionController.add(_state);

    try {
      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(gateway.wsUrl));
      
      // Listen for incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Wait for connect.challenge and send connect request
      await _performHandshake();
      
    } catch (e) {
      _state = ConnectionState.error;
      _connectionController.add(_state);
      rethrow;
    }
  }

  /// Perform WebSocket handshake with gateway
  Future<void> _performHandshake() async {
    // Wait for challenge from gateway
    final challenge = await _waitForChallenge();
    
    // Build and send connect request
    final connectRequest = _buildConnectRequest(challenge);
    send(connectRequest);
  }

  /// Wait for connect.challenge event from gateway
  Future<Map<String, dynamic>> _waitForChallenge() async {
    final completer = Completer<Map<String, dynamic>>();
    final subscription = _channel!.stream.listen((data) {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      if (message['type'] == 'event' && message['event'] == 'connect.challenge') {
        completer.complete(message['payload'] as Map<String, dynamic>);
      }
    });
    
    // Timeout after 10 seconds
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription.cancel();
        throw TimeoutException('Gateway challenge timeout');
      },
    );
    
    subscription.cancel();
    return completer.future as Future<Map<String, dynamic>>;
  }

  /// Build connect request frame
  Map<String, dynamic> _buildConnectRequest(Map<String, dynamic> challenge) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return {
      'type': 'req',
      'id': _uuid.v4(),
      'method': 'connect',
      'params': {
        'minProtocol': minProtocol,
        'maxProtocol': maxProtocol,
        'client': {
          'id': 'pawchat-android',
          'version': '1.0.0',
          'platform': 'android',
          'mode': 'operator',
        },
        'role': 'operator',
        'scopes': ['operator.read', 'operator.write'],
        'caps': [],
        'commands': [],
        'permissions': {},
        'locale': 'zh-CN',
        'userAgent': 'pawchat-android/1.0.0',
        'device': {
          'id': 'device_temp', // Will be replaced by auth service
          'nonce': challenge['nonce'],
          'signedAt': now,
        },
      },
    };
  }

  /// Send WebSocket message
  void send(Map<String, dynamic> message) {
    if (_channel != null && _state == ConnectionState.connected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  /// Send chat message via gateway
  Future<void> sendMessage(String content, {String? sessionId}) async {
    final message = {
      'type': 'req',
      'id': _uuid.v4(),
      'method': 'chat.send',
      'params': {
        'channel': 'default',
        'content': content,
        if (sessionId != null) 'session': sessionId,
      },
    };
    send(message);
  }

  /// Create new session on gateway
  Future<void> createSession() async {
    final message = {
      'type': 'req',
      'id': _uuid.v4(),
      'method': 'session.create',
      'params': {},
    };
    send(message);
  }

  /// List active sessions
  Future<void> listSessions() async {
    final message = {
      'type': 'req',
      'id': _uuid.v4(),
      'method': 'session.list',
      'params': {},
    };
    send(message);
  }

  /// Handle incoming WebSocket message
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      
      // Handle connect response
      if (message['type'] == 'res' && message['method'] == 'connect') {
        _handleConnectResponse(message);
        return;
      }
      
      // Broadcast all messages to listeners
      _messageController.add(message);
      
    } catch (e) {
      print('WebSocket message handling error: $e');
    }
  }

  /// Handle connect response from gateway
  void _handleConnectResponse(Map<String, dynamic> response) {
    if (response['ok'] == true && response['payload']['type'] == 'hello-ok') {
      _state = ConnectionState.connected;
      _connectionController.add(_state);
      
      // Update gateway config with connection time
      if (_currentGateway != null) {
        _currentGateway = _currentGateway!.copyWith(
          lastConnected: DateTime.now(),
        );
      }
    } else {
      _state = ConnectionState.error;
      _connectionController.add(_state);
    }
  }

  /// Handle WebSocket error
  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _state = ConnectionState.error;
    _connectionController.add(_state);
  }

  /// Handle WebSocket disconnect
  void _handleDisconnect() {
    print('WebSocket disconnected');
    _state = ConnectionState.disconnected;
    _connectionController.add(_state);
    _channel = null;
  }

  /// Disconnect from gateway
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _state = ConnectionState.disconnected;
    _connectionController.add(_state);
  }

  /// Reconnect with exponential backoff
  Future<void> reconnect({int retries = 3, int delayMs = 5000}) async {
    for (int i = 0; i < retries; i++) {
      try {
        await Future.delayed(Duration(milliseconds: delayMs * (i + 1)));
        if (_currentGateway != null) {
          await connect(_currentGateway!);
          if (_state == ConnectionState.connected) return;
        }
      } catch (e) {
        if (i == retries - 1) rethrow;
      }
    }
  }

  /// Cleanup resources
  void dispose() {
    _connectionController.close();
    _messageController.close();
  }
}
