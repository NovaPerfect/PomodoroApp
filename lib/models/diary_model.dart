import 'package:hive/hive.dart';

part 'diary_model.g.dart';

@HiveType(typeId: 1)
class DiaryModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  int moodIndex;

  DiaryModel({
    required this.title,
    required this.content,
    required this.createdAt,
    this.moodIndex = -1,
  });
}