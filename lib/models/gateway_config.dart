import 'package:hive/hive.dart';

part 'gateway_config.g.dart';

@HiveType(typeId: 4)
class GatewayConfig extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String host;

  @HiveField(3)
  int port;

  @HiveField(4)
  bool useTLS;

  @HiveField(5)
  String? deviceToken;

  @HiveField(6)
  DateTime? lastConnected;

  @HiveField(7)
  bool isActive;

  GatewayConfig({
    required this.id,
    this.name = 'OpenClaw Gateway',
    required this.host,
    this.port = 8080,
    this.useTLS = false,
    this.deviceToken,
    this.lastConnected,
    this.isActive = false,
  });

  String get wsUrl {
    final protocol = useTLS ? 'wss' : 'ws';
    return '$protocol://$host:$port/gateway';
  }

  String get httpUrl {
    final protocol = useTLS ? 'https' : 'http';
    return '$protocol://$host:$port';
  }

  GatewayConfig copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    bool? useTLS,
    String? deviceToken,
    DateTime? lastConnected,
    bool? isActive,
  }) {
    return GatewayConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      useTLS: useTLS ?? this.useTLS,
      deviceToken: deviceToken ?? this.deviceToken,
      lastConnected: lastConnected ?? this.lastConnected,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'host': host,
      'port': port,
      'useTLS': useTLS,
      'deviceToken': deviceToken,
      'lastConnected': lastConnected?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory GatewayConfig.fromMap(Map<String, dynamic> map) {
    return GatewayConfig(
      id: map['id'] as String,
      name: map['name'] as String,
      host: map['host'] as String,
      port: map['port'] as int,
      useTLS: map['useTLS'] as bool,
      deviceToken: map['deviceToken'] as String?,
      lastConnected: map['lastConnected'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastConnected'] as int)
          : null,
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  factory GatewayConfig.defaultConfig() {
    return GatewayConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      host: '192.168.1.100',
      port: 8080,
      name: 'My OpenClaw Gateway',
    );
  }
}
