// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_hive_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskHiveTypeAdapter extends TypeAdapter<TaskHiveType> {
  @override
  final int typeId = 0;

  @override
  TaskHiveType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskHiveType(
      title: fields[0] as String,
      description: fields[1] as String,
      duration: fields[2] as int,
      startingDate: fields[3] as int,
      category: fields[4] as dynamic,
      image: fields[5] as dynamic,
      status: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskHiveType obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.startingDate)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskHiveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
