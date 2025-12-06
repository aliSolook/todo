import 'package:hive/hive.dart';
import 'package:todo/features/counter/counter.dart';

class CounterLocalDatasource implements CounterDatasource {
  final _box = Hive.box<CounterHiveType>('counter_box');

  @override
  Future<dynamic> addCounter(Counter counter) {
    print('adding');
    return _box.add(CounterHiveType.fromCounter(counter));
  }

  @override
  Future<void> deleteCounter(dynamic id) {
    if (!_box.containsKey(id)) {
      throw CounterNotFoundException(id);
    }
    return _box.delete(id);
  }

  @override
  Future<CounterWrapper> getCounter(dynamic id) async {
    final output = _box.get(id);
    if (output == null) {
      throw CounterNotFoundException(id);
    }
    return output.wrap(id);
  }

  @override
  Future<List<CounterWrapper>> listCounters() async {
    return _box.toMap().entries.map((e) => e.value.wrap(e.key)).toList();
  }

  @override
  Future<void> updateCounter(CounterWrapper counterWrapper) async {
    if (!_box.containsKey(counterWrapper.id)) {
      throw CounterNotFoundException(counterWrapper.id);
    }
    _box.put(
      counterWrapper.id,
      CounterHiveType.fromCounter(counterWrapper.toCounter()),
    );
  }
}
