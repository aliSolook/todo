// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_hive_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryHiveTypeAdapter extends TypeAdapter<CategoryHiveType> {
  @override
  final int typeId = 1;

  @override
  CategoryHiveType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryHiveType(
      title: fields[0] as String,
      image: fields[1] as dynamic,
      color: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryHiveType obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryHiveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
