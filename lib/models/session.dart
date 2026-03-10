import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 3)
class Session extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  String? lastMessage;

  @HiveField(5)
  bool isActive;

  Session({
    required this.id,
    this.name = 'New Session',
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.isActive = true,
  });

  factory Session.create() {
    final now = DateTime.now();
    return Session(
      id: now.millisecondsSinceEpoch.toString(),
      createdAt: now,
      updatedAt: now,
    );
  }

  Session copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    bool? isActive,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'isActive': isActive,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      lastMessage: map['lastMessage'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
