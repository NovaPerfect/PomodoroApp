import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String name;
  final String emoji;
  final String type; // 'daily' | 'weekly' | 'counter'
  final int color;
  final int targetCount;
  final List<int> weekDays; // for weekly: [1,2,3,4,5,6,7]
  final DateTime createdAt;
  final bool isActive;

  const HabitModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.color,
    required this.targetCount,
    required this.weekDays,
    required this.createdAt,
    required this.isActive,
  });

  factory HabitModel.fromMap(String id, Map<String, dynamic> map) {
    return HabitModel(
      id: id,
      name: map['name'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '⭐',
      type: map['type'] as String? ?? 'daily',
      color: map['color'] as int? ?? 0xFFE8A0BF,
      targetCount: map['targetCount'] as int? ?? 1,
      weekDays: List<int>.from(map['weekDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'emoji': emoji,
        'type': type,
        'color': color,
        'targetCount': targetCount,
        'weekDays': weekDays,
        'createdAt': Timestamp.fromDate(createdAt),
        'isActive': isActive,
      };

  HabitModel copyWith({
    String? name,
    String? emoji,
    String? type,
    int? color,
    int? targetCount,
    List<int>? weekDays,
    bool? isActive,
  }) =>
      HabitModel(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        type: type ?? this.type,
        color: color ?? this.color,
        targetCount: targetCount ?? this.targetCount,
        weekDays: weekDays ?? this.weekDays,
        createdAt: createdAt,
        isActive: isActive ?? this.isActive,
      );
}

class HabitLogModel {
  final String habitId;
  final String date; // "YYYY-MM-DD"
  final int count;
  final DateTime? completedAt;

  const HabitLogModel({
    required this.habitId,
    required this.date,
    required this.count,
    this.completedAt,
  });

  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      habitId: map['habitId'] as String? ?? '',
      date: map['date'] as String? ?? '',
      count: map['count'] as int? ?? 0,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'habitId': habitId,
        'date': date,
        'count': count,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };
}
