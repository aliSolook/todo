import 'package:todo/features/counter/models/counter_wrapper.dart';
import 'package:todo/features/counter/models/counter.dart';

abstract class CounterDatasource {
  Future<List<CounterWrapper>> listCounters();
  Future<CounterWrapper> getCounter(dynamic id);
  Future<dynamic> addCounter(Counter counter);
  Future<void> deleteCounter(dynamic id);
  Future<void> updateCounter(CounterWrapper counterWrapper);
}

class CounterNotFoundException implements Exception {
  final dynamic id;

  CounterNotFoundException(this.id);

  @override
  String toString() {
    return 'CounterNotFoundException($id)';
  }
}
