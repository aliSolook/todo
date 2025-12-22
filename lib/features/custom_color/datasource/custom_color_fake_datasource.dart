import 'dart:math';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:todo/features/custom_color/custom_color.dart';

class CustomColorFakeDatasource implements CustomColorDatasource {
  CustomColorFakeDatasource._(this._random);

  late final List<CustomColorWrapper> _data;
  final Random _random;

  static Future<CustomColorFakeDatasource> init([int? count, int? seed]) async {
    final output = CustomColorFakeDatasource._(Random(seed));
    output._init(count);
    return output;
  }

  void _init(int? count) {
    if (count == 0) {
      _data = [];
      return;
    }
    _data = List.generate(
      count ?? _random.nextInt(10),
      (i) => CustomColorWrapper(i, 0xFF000000 + _random.nextInt(0xFFFFFF)),
    );
  }

  @override
  Future addCustomColor(int customColor) async {
    int max = 0;
    for (var task in _data) {
      if (task.id as int > max) max = task.id;
    }

    _data.add(CustomColorWrapper(++max, customColor));
    return SynchronousFuture(max);
  }

  @override
  Future<Iterable> addAllCustomColors(Iterable<int> colors) {
    int max = 0;
    for (var color in _data) {
      if (color.id as int > max) max = color.id;
    }

    final output = <int>[];
    for (var color in colors) {
      _data.add(CustomColorWrapper(++max, color));
      output.add(max);
    }

    return SynchronousFuture(output);
  }

  @override
  Future<void> deleteCustomColor(dynamic id) async {
    bool idExists = false;

    for (var i = 0; i < _data.length; i++) {
      if (_data[i].id == id) {
        _data.removeAt(i);
        idExists = true;
        break;
      }
    }

    if (!idExists) throw CustomColorNotFoundException(id);
  }

  @override
  Future<List<CustomColorWrapper>> listCustomColors() =>
      SynchronousFuture(List.from(_data));
}
