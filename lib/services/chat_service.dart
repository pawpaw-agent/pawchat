import 'dart:async';
import '../models/message.dart';
import '../models/session.dart';
import 'websocket_service.dart';
import 'storage_service.dart';

/// ChatService - Backend service for chat operations
/// Responsible for: Message management, session handling, chat business logic
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final WebSocketService _wsService = WebSocketService();
  final StorageService _storage = StorageService();
  
  StreamSubscription? _messageSubscription;
  String? _currentSessionId;

  final _messagesController = StreamController<List<Message>>.broadcast();
  Stream<List<Message>> get messagesStream => _messagesController.stream;

  /// Get current messages for active session
  List<Message> get currentMessages {
    if (_currentSessionId == null) return [];
    return _storage.getMessages(_currentSessionId!);
  }

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Initialize chat service
  Future<void> init() async {
    // Listen to WebSocket messages
    _messageSubscription = _wsService.messageStream.listen(_handleWebSocketMessage);
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    if (message['type'] == 'event' && message['event'] == 'chat.message') {
      final payload = message['payload'] as Map<String, dynamic>;
      final sessionId = payload['sessionId'] as String? ?? _currentSessionId;
      
      if (sessionId != null) {
        final msg = Message(
          id: payload['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          sessionId: sessionId,
          content: payload['content'] as String,
          role: payload['from'] == 'agent' ? MessageRole.agent : MessageRole.user,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            payload['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ),
          status: MessageStatus.delivered,
        );
        
        _storage.saveMessage(sessionId, msg);
        
        if (sessionId == _currentSessionId) {
          _messagesController.add(currentMessages);
        }
      }
    }
  }

  /// Select active session
  Future<void> selectSession(String sessionId) async {
    _currentSessionId = sessionId;
    _messagesController.add(currentMessages);
  }

  /// Create new session
  Future<Session> createSession() async {
    final session = Session.create();
    await _storage.saveSession(session);
    _currentSessionId = session.id;
    
    // Request session creation on gateway
    await _wsService.createSession();
    
    _messagesController.add([]);
    return session;
  }

  /// Get all sessions
  Future<List<Session>> getSessions() async {
    return _storage.getAllSessions();
  }

  /// Delete session
  Future<void> deleteSession(String sessionId) async {
    await _storage.deleteSession(sessionId);
    if (_currentSessionId == sessionId) {
      _currentSessionId = null;
      _messagesController.add([]);
    }
  }

  /// Send message
  Future<void> sendMessage(String content) async {
    if (_wsService.state != ConnectionState.connected) {
      throw Exception('Not connected to gateway');
    }

    final sessionId = _currentSessionId ?? (await createSession()).id;
    
    // Create local message
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    
    // Save locally
    await _storage.saveMessage(sessionId, message);
    _messagesController.add(currentMessages);
    
    // Send via WebSocket
    await _wsService.sendMessage(content, sessionId: sessionId);
    
    // Update status to sent
    message.status = MessageStatus.sent;
    await _storage.saveMessage(sessionId, message);
  }

  /// Clear current session messages
  Future<void> clearCurrentSessionMessages() async {
    if (_currentSessionId != null) {
      await _storage.clearMessages(_currentSessionId!);
      _messagesController.add([]);
    }
  }

  /// Cleanup resources
  void dispose() {
    _messageSubscription?.cancel();
    _messagesController.close();
  }
}
