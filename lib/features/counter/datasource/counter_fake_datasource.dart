import 'dart:math';
import 'package:todo/features/counter/datasource/counter_datasource.dart';
import 'package:todo/features/counter/models/counter_wrapper.dart';
import 'package:todo/features/counter/models/counter.dart';

final _populatedList = [
  CounterWrapper(
    id: 1,
    title: 'Apples',
    description: '',
    duration: Duration(seconds: Random().nextInt(60)),
    image: null,
  ),
  CounterWrapper(
    id: 2,
    title: 'Bananas',
    description: '',
    duration: Duration(seconds: Random().nextInt(60)),
    image: null,
  ),
  CounterWrapper(
    id: 3,
    title: 'Oranges',
    description: '',
    duration: Duration(seconds: Random().nextInt(60)),
    image: null,
  ),
  CounterWrapper(
    id: 4,
    title: 'Oranges',
    description: '',
    duration: Duration(seconds: Random().nextInt(60)),
    image: null,
  ),
  CounterWrapper(
    id: 5,
    title: 'Oranges',
    description: '',
    duration: Duration(seconds: Random().nextInt(60)),
    image: null,
  ),
  CounterWrapper(
    id: 6,
    title: 'Oranges',
    description: '',
    duration: Duration(seconds: Random().nextInt(60)),
    image: null,
  ),
  CounterWrapper(
    id: 7,
    title: 'Oranges',
    description: '',
    duration: Duration(seconds: Random().nextInt(60)),
    image: null,
  ),
];

class CounterFakeDatasource implements CounterDatasource {
  final List<CounterWrapper> _storage = List.of(_populatedList);

  int _lastInsertedId = 0;

  @override
  Future<int> addCounter(Counter counter) async {
    final id = _lastInsertedId++;
    _populatedList.add(CounterWrapper.fromCounter(id, counter));
    _storage.add(CounterWrapper.fromCounter(id, counter));
    return id;
  }

  @override
  Future<void> deleteCounter(dynamic id) async {
    bool idExists = false;

    for (var i = 0; i < _storage.length; i++) {
      if (_storage[i].id == id) {
        _storage.removeAt(i);
        idExists = true;
        break;
      }
    }

    if (!idExists) {
      throw CounterNotFoundException(id);
    }
  }

  @override
  Future<CounterWrapper> getCounter(dynamic id) async {
    final counter = _storage.cast<CounterWrapper?>().firstWhere(
      (counter) => counter?.id == id,
      orElse: () => null,
    );

    if (counter == null) {
      throw CounterNotFoundException(id);
    }

    return counter;
  }

  @override
  Future<List<CounterWrapper>> listCounters() async {
    _storage.clear();
    _storage.addAll(_populatedList);
    return List.from(_storage);
  }

  @override
  Future<void> updateCounter(CounterWrapper counterWrapper) async {
    final index = _storage.indexWhere(
      (counter) => counter.id == counterWrapper,
    );
    if (index == -1) {
      throw CounterNotFoundException(counterWrapper);
    }
    _storage[index] = counterWrapper;
  }
}
