import 'package:hive/hive.dart';

part 'stats_model.g.dart';

@HiveType(typeId: 2)
class StatsModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int focusSeconds; // 👈 секунды вместо минут

  @HiveField(2)
  int sessionsCount;

  @HiveField(3)
  List<String> completedTodos;

  @HiveField(4)
  List<String> completedTodoIds;

  StatsModel({
    required this.date,
    this.focusSeconds  = 0,
    this.sessionsCount = 0,
    List<String>? completedTodos,
    List<String>? completedTodoIds,
  })  : completedTodos   = completedTodos   ?? [],
        completedTodoIds = completedTodoIds ?? [];
}