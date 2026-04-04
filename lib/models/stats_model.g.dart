// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatsModelAdapter extends TypeAdapter<StatsModel> {
  @override
  final int typeId = 2;

  @override
  StatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatsModel(
      date: fields[0] as DateTime,
      focusSeconds: fields[1] as int,
      sessionsCount: fields[2] as int,
      completedTodos: (fields[3] as List?)?.cast<String>(),
      completedTodoIds: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StatsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.focusSeconds)
      ..writeByte(2)
      ..write(obj.sessionsCount)
      ..writeByte(3)
      ..write(obj.completedTodos)
      ..writeByte(4)
      ..write(obj.completedTodoIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
