import 'package:todo/features/custom_color/custom_color.dart';

abstract class CustomColorDatasource {
  Future<List<CustomColorWrapper>> listCustomColors();
  Future<dynamic> addCustomColor(int color);
  Future<Iterable<dynamic>> addAllCustomColors(Iterable<int> colors);
  Future<void> deleteCustomColor(dynamic id);
}

class CustomColorNotFoundException implements Exception {
  final dynamic id;

  CustomColorNotFoundException(this.id);

  @override
  String toString() {
    return 'CustomColorNotFoundException($id)';
  }
}
