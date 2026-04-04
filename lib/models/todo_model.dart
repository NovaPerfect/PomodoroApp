import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime? completedAt;

  @HiveField(4)
  String id; // 👈 уникальный ID задачи

  TodoModel({
    required this.title,
    this.isDone = false,
    required this.createdAt,
    this.completedAt,
    required this.id,
  });
}