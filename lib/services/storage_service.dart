import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../models/gateway_config.dart';

/// StorageService - Backend service for data persistence
/// Responsible for: Local storage, secure credential storage, data access
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<GatewayConfig> _gatewayBox;
  late Box<Session> _sessionBox;
  late Box<List<Message>> _messageBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Box names
  static const String gatewayBoxName = 'gateway_configs';
  static const String sessionBoxName = 'sessions';
  static const String messageBoxName = 'chat_history';
  static const String settingsBoxName = 'app_settings';

  /// Initialize storage service
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Hive adapters
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(MessageRoleAdapter());
    Hive.registerAdapter(MessageStatusAdapter());
    Hive.registerAdapter(SessionAdapter());
    Hive.registerAdapter(GatewayConfigAdapter());
    
    // Open boxes
    _gatewayBox = await Hive.openBox<GatewayConfig>(gatewayBoxName);
    _sessionBox = await Hive.openBox<Session>(sessionBoxName);
    _messageBox = await Hive.openBox<List<Message>>(messageBoxName);
  }

  // ==================== Gateway Config Operations ====================

  /// Save gateway configuration
  Future<void> saveGatewayConfig(GatewayConfig config) async {
    await _gatewayBox.put(config.id, config);
  }

  /// Get gateway configuration by ID
  GatewayConfig? getGatewayConfig(String id) {
    return _gatewayBox.get(id);
  }

  /// Get all gateway configurations
  List<GatewayConfig> getAllGatewayConfigs() {
    return _gatewayBox.values.toList();
  }

  /// Delete gateway configuration
  Future<void> deleteGatewayConfig(String id) async {
    await _gatewayBox.delete(id);
  }

  /// Set active gateway
  Future<void> setActiveGateway(String id) async {
    for (var config in _gatewayBox.values) {
      final updated = config.copyWith(isActive: config.id == id);
      await _gatewayBox.put(config.id, updated);
    }
  }

  /// Get active gateway
  GatewayConfig? getActiveGateway() {
    final configs = _gatewayBox.values.toList();
    if (configs.isEmpty) return null;
    
    try {
      return configs.firstWhere((config) => config.isActive);
    } on StateError {
      return configs.first;
    }
  }

  // ==================== Session Operations ====================

  /// Save session
  Future<void> saveSession(Session session) async {
    await _sessionBox.put(session.id, session);
  }

  /// Get session by ID
  Session? getSession(String id) {
    return _sessionBox.get(id);
  }

  /// Get all sessions (sorted by updated time)
  List<Session> getAllSessions() {
    return _sessionBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Delete session and its messages
  Future<void> deleteSession(String id) async {
    await _sessionBox.delete(id);
    await _messageBox.delete(id);
  }

  // ==================== Message Operations ====================

  /// Save message to session
  Future<void> saveMessage(String sessionId, Message message) async {
    final messages = getMessages(sessionId);
    messages.add(message);
    await _messageBox.put(sessionId, messages);
    
    // Update session's last message
    final session = getSession(sessionId);
    if (session != null) {
      final updated = session.copyWith(
        lastMessage: message.content,
        updatedAt: message.timestamp,
      );
      await saveSession(updated);
    }
  }

  /// Get messages for session
  List<Message> getMessages(String sessionId) {
    final messages = _messageBox.get(sessionId);
    return messages ?? [];
  }

  /// Clear messages for session
  Future<void> clearMessages(String sessionId) async {
    await _messageBox.put(sessionId, []);
  }

  // ==================== Secure Storage Operations ====================

  /// Save device token securely
  Future<void> saveDeviceToken(String gatewayId, String token) async {
    await _secureStorage.write(key: 'token_$gatewayId', value: token);
  }

  /// Get device token securely
  Future<String?> getDeviceTokenAsync(String gatewayId) async {
    return await _secureStorage.read(key: 'token_$gatewayId');
  }

  /// Save device identity securely
  Future<void> saveDeviceIdentity(String gatewayId, Map<String, dynamic> identity) async {
    final encoded = base64Encode(utf8.encode(jsonEncode(identity)));
    await _secureStorage.write(key: 'identity_$gatewayId', value: encoded);
  }

  /// Get device identity securely
  Future<Map<String, dynamic>?> getDeviceIdentityAsync(String gatewayId) async {
    final data = await _secureStorage.read(key: 'identity_$gatewayId');
    if (data == null) return null;
    
    final decoded = utf8.decode(base64Decode(data));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  /// Delete device identity
  Future<void> deleteDeviceIdentity(String gatewayId) async {
    await _secureStorage.delete(key: 'identity_$gatewayId');
  }

  // ==================== Settings Operations ====================

  /// Save app setting
  Future<void> saveSetting(String key, String value) async {
    final box = await Hive.openBox(settingsBoxName);
    await box.put(key, value);
  }

  /// Get app setting
  String? getSetting(String key) {
    if (!Hive.isBoxOpen(settingsBoxName)) return null;
    final box = Hive.box(settingsBoxName);
    return box.get(key);
  }

  /// Clear all data (reset app)
  Future<void> clearAllData() async {
    await _gatewayBox.clear();
    await _sessionBox.clear();
    await _messageBox.clear();
    
    final settingsBox = await Hive.openBox(settingsBoxName);
    await settingsBox.clear();
  }

  /// Close storage service
  Future<void> close() async {
    await Hive.close();
  }
}
