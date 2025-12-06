import 'package:todo/features/counter/models/counter_wrapper.dart';
import 'package:todo/features/counter/models/counter.dart';
import 'package:dart_either/dart_either.dart';

abstract class CounterRepository {
  Future<Either<String, List<CounterWrapper>>> listCounters();
  Future<Either<String, CounterWrapper>> getCounter(dynamic id);
  Future<Either<String, dynamic>> addCounter(Counter counter);
  Future<Either<String, String>> deleteCounter(dynamic id);
  Future<Either<String, String>> updateCounter(CounterWrapper counterWrapper);
}
