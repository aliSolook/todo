// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_hive_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CounterHiveTypeAdapter extends TypeAdapter<CounterHiveType> {
  @override
  final int typeId = 2;

  @override
  CounterHiveType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CounterHiveType(
      title: fields[0] as String,
      description: fields[1] as String,
      duration: fields[2] as int,
      image: fields[3] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, CounterHiveType obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterHiveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
