import 'package:flutter_test/flutter_test.dart';
import 'package:pawchat/models/message.dart';

void main() {
  group('Message Model', () {
    test('should create message with required fields', () {
      final message = Message(
        id: 'msg-001',
        sessionId: 'session-001',
        content: 'Hello, World!',
        role: MessageRole.user,
        timestamp: DateTime(2026, 3, 10, 14, 0, 0),
      );

      expect(message.id, 'msg-001');
      expect(message.sessionId, 'session-001');
      expect(message.content, 'Hello, World!');
      expect(message.role, MessageRole.user);
      expect(message.status, MessageStatus.sent);
    });

    test('should create message from map', () {
      final map = {
        'id': 'msg-002',
        'sessionId': 'session-001',
        'content': 'Test message',
        'role': 'agent',
        'timestamp': 1710000000000,
        'status': 'delivered',
      };

      final message = Message.fromMap(map);

      expect(message.id, 'msg-002');
      expect(message.content, 'Test message');
      expect(message.role, MessageRole.agent);
      expect(message.status, MessageStatus.delivered);
    });

    test('should convert message to map', () {
      final message = Message(
        id: 'msg-003',
        sessionId: 'session-001',
        content: 'Test',
        role: MessageRole.user,
        timestamp: DateTime(2026, 3, 10, 14, 0, 0),
        status: MessageStatus.sent,
      );

      final map = message.toMap();

      expect(map['id'], 'msg-003');
      expect(map['content'], 'Test');
      expect(map['role'], 'user');
      expect(map['status'], 'sent');
      expect(map['timestamp'], isA<int>());
    });

    test('should handle different message roles', () {
      expect(MessageRole.user.name, 'user');
      expect(MessageRole.agent.name, 'agent');
      expect(MessageRole.system.name, 'system');
    });

    test('should handle different message statuses', () {
      expect(MessageStatus.sending.name, 'sending');
      expect(MessageStatus.sent.name, 'sent');
      expect(MessageStatus.delivered.name, 'delivered');
      expect(MessageStatus.failed.name, 'failed');
    });

    test('should use default status when not provided', () {
      final message = Message(
        id: 'msg-004',
        sessionId: 'session-001',
        content: 'Test',
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      expect(message.status, MessageStatus.sent);
    });
  });
}
