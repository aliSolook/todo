// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_color_hive_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomColorHiveTypeAdapter extends TypeAdapter<CustomColorHiveType> {
  @override
  final int typeId = 4;

  @override
  CustomColorHiveType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomColorHiveType(
      fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomColorHiveType obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomColorHiveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
