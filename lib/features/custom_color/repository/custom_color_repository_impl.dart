import 'package:dart_either/dart_either.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/di/di.dart';

class CustomColorRepositoryImpl implements CustomColorRepository {
  final CustomColorDatasource _source = locator.get();
  final Duration? _delay;

  CustomColorRepositoryImpl([Duration? delay]) : _delay = delay;

  @override
  Future<Either<String, int>> addCustomColor(int customColor) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.addCustomColor(customColor));
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> deleteCustomColor(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.deleteCustomColor(id);
      return const Right('رنگ با موفقیت حذف شد');
    } on CustomColorNotFoundException {
      return const Left('دسته‌‌بندی وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, List<CustomColorWrapper>>> listCustomColors() async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.listCustomColors());
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }
}
