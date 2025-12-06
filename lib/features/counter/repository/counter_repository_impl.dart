import 'package:dart_either/dart_either.dart';
import 'package:todo/features/counter/datasource/counter_datasource.dart';
import 'package:todo/features/counter/models/counter_wrapper.dart';
import 'package:todo/features/counter/models/counter.dart';
import 'package:todo/features/counter/repository/counter_repository.dart';
import 'package:todo/di/di.dart';

class CounterRepositoryImpl implements CounterRepository {
  final CounterDatasource _source = locator.get();
  final Duration? _delay;

  CounterRepositoryImpl([Duration? delay]) : _delay = delay;

  @override
  Future<Either<String, int>> addCounter(Counter counter) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.addCounter(counter));
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> deleteCounter(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.deleteCounter(id);
      return const Right('شمارنده با موفقیت حذف شد');
    } on CounterNotFoundException {
      return const Left('شمارنده وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, CounterWrapper>> getCounter(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.getCounter(id));
    } on CounterNotFoundException {
      return const Left('شمارنده وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, List<CounterWrapper>>> listCounters() async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.listCounters());
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> updateCounter(
    CounterWrapper counterWrapper,
  ) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.updateCounter(counterWrapper);
      return const Right('شمارنده با موفقیت ویرایش شد');
    } on CounterNotFoundException {
      return const Left('شمارنده وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }
}
