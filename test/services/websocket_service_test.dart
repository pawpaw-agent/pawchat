import 'package:flutter_test/flutter_test.dart';
import 'package:pawchat/services/websocket_service.dart';
import 'package:pawchat/models/gateway_config.dart';

void main() {
  group('WebSocketService', () {
    late WebSocketService service;

    setUp(() {
      service = WebSocketService();
    });

    tearDown(() {
      service.dispose();
    });

    test('should be singleton', () {
      final instance1 = WebSocketService();
      final instance2 = WebSocketService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('should have initial disconnected state', () {
      expect(service.state, ConnectionState.disconnected);
    });

    test('should generate correct WebSocket URL', () {
      final config = GatewayConfig(
        id: 'test-1',
        host: '192.168.1.100',
        port: 8080,
        useTLS: false,
      );
      expect(config.wsUrl, 'ws://192.168.1.100:8080/gateway');
    });

    test('should generate correct secure WebSocket URL', () {
      final config = GatewayConfig(
        id: 'test-2',
        host: 'example.com',
        port: 443,
        useTLS: true,
      );
      expect(config.wsUrl, 'wss://example.com:443/gateway');
    });

    test('should have correct protocol version', () {
      expect(WebSocketService.minProtocol, 3);
      expect(WebSocketService.maxProtocol, 3);
    });

    test('should have all connection states', () {
      expect(ConnectionState.values.length, 4);
      expect(ConnectionState.values[0], ConnectionState.disconnected);
      expect(ConnectionState.values[1], ConnectionState.connecting);
      expect(ConnectionState.values[2], ConnectionState.connected);
      expect(ConnectionState.values[3], ConnectionState.error);
    });
  });

  group('GatewayConfig Model', () {
    test('should create with default values', () {
      final config = GatewayConfig(
        id: 'test',
        host: '192.168.1.100',
      );

      expect(config.port, 8080);
      expect(config.useTLS, false);
      expect(config.isActive, false);
    });

    test('should create with custom values', () {
      final config = GatewayConfig(
        id: 'test',
        host: 'example.com',
        port: 443,
        useTLS: true,
        name: 'Test Gateway',
      );

      expect(config.host, 'example.com');
      expect(config.port, 443);
      expect(config.useTLS, true);
      expect(config.name, 'Test Gateway');
    });

    test('should copyWith updated values', () {
      final config = GatewayConfig(
        id: 'test',
        host: '192.168.1.100',
      );

      final updated = config.copyWith(
        port: 9090,
        useTLS: true,
      );

      expect(updated.host, '192.168.1.100');
      expect(updated.port, 9090);
      expect(updated.useTLS, true);
    });

    test('should convert to map and back', () {
      final original = GatewayConfig(
        id: 'test',
        host: '192.168.1.100',
        port: 8080,
        useTLS: false,
        name: 'Test',
      );

      final map = original.toMap();
      final restored = GatewayConfig.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.host, original.host);
      expect(restored.port, original.port);
      expect(restored.useTLS, original.useTLS);
      expect(restored.name, original.name);
    });
  });
}
