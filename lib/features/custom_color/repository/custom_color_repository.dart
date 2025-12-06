import 'package:todo/features/custom_color/custom_color.dart';
import 'package:dart_either/dart_either.dart';

abstract class CustomColorRepository {
  Future<Either<String, List<CustomColorWrapper>>> listCustomColors();
  Future<Either<String, dynamic>> addCustomColor(int color);
  Future<Either<String, String>> deleteCustomColor(dynamic id);
}
