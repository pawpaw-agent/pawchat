import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sessionId;

  @HiveField(2)
  String content;

  @HiveField(3)
  MessageRole role;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  MessageStatus status;

  Message({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: map['sessionId'] as String,
      content: map['content'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp'] as DateTime
          : DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
    };
  }
}

@HiveType(typeId: 1)
enum MessageRole {
  @HiveField(0)
  user,
  @HiveField(1)
  agent,
  @HiveField(2)
  system,
}

@HiveType(typeId: 2)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  delivered,
  @HiveField(3)
  failed,
}
