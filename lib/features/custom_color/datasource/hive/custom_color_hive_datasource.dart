import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:todo/features/custom_color/custom_color.dart';

class CustomColorLocalDatasource implements CustomColorDatasource {
  final _box = Hive.box<CustomColorHiveType>('custom_color_box');

  @override
  Future<dynamic> addCustomColor(int color) =>
      _box.add(CustomColorHiveType(color));

  @override
  Future<Iterable> addAllCustomColors(Iterable<int> colors) =>
      _box.addAll(colors.map(CustomColorHiveType.new));

  @override
  Future<void> deleteCustomColor(dynamic id) {
    if (!_box.containsKey(id)) {
      throw CustomColorNotFoundException(id);
    }
    return _box.delete(id);
  }

  @override
  Future<List<CustomColorWrapper>> listCustomColors() => SynchronousFuture(
    _box.toMap().entries.map((e) => e.value.wrap(e.key)).toList(),
  );
}
