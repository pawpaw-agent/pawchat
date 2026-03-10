import 'package:flutter_test/flutter_test.dart';
import 'package:pawchat/models/session.dart';

void main() {
  group('Session Model', () {
    test('should create session with required fields', () {
      final now = DateTime.now();
      final session = Session(
        id: 'session-001',
        name: 'Test Session',
        createdAt: now,
        updatedAt: now,
      );

      expect(session.id, 'session-001');
      expect(session.name, 'Test Session');
      expect(session.isActive, true);
    });

    test('should create session with factory', () {
      final session = Session.create();

      expect(session.id, isNotEmpty);
      expect(session.name, 'New Session');
      expect(session.isActive, true);
      expect(session.lastMessage, isNull);
    });

    test('should copyWith updated values', () {
      final now = DateTime.now();
      final session = Session(
        id: 'session-001',
        name: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      final updated = session.copyWith(
        name: 'Updated',
        lastMessage: 'Hello',
      );

      expect(updated.id, session.id);
      expect(updated.name, 'Updated');
      expect(updated.lastMessage, 'Hello');
    });

    test('should convert to map and back', () {
      final now = DateTime.now();
      final original = Session(
        id: 'session-001',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        lastMessage: 'Hello',
        isActive: true,
      );

      final map = original.toMap();
      final restored = Session.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.lastMessage, original.lastMessage);
      expect(restored.isActive, original.isActive);
    });
  });
}
