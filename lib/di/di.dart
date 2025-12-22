import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/task/task.dart';

final locator = GetIt.I;
Future<void> getItInit({
  bool mock = false,
  Duration? delay,
  int? count,
  int? seed,
}) async {
  await initImage(mock: mock, delay: delay, count: count, seed: seed);
  await initCategory(mock: mock, delay: delay, count: count, seed: seed);
  await initTask(mock: mock, delay: delay, count: count, seed: seed);
  await initCounter(mock: mock, delay: delay, count: count, seed: seed);
  await initCustomColor(mock: mock, delay: delay, count: count, seed: seed);
}

Future<void> initImage({
  bool mock = false,
  Duration? delay,
  int? count,
  int? seed,
}) async {
  if (mock) {
    _rs<ImageDatasource>(
      await ImageFakeDatasource.init(count: count, seed: seed),
    );
  } else if (kIsWeb) {
    _rs<ImageDatasource>(ImageHiveDatasource());
  } else {
    _rs<ImageDatasource>(ImageLocalFileDatasource());
  }

  _rs<ImageRepository>(ImageRepositoryImpl(delay));
}

Future<void> initCategory({
  bool mock = false,
  Duration? delay,
  int? count,
  int? seed,
}) async {
  if (mock) {
    _rs<CategoryDatasource>(await CategoryFakeDatasource.init(count, seed));
  } else {
    _rs<CategoryDatasource>(CategoryLocalDatasource());
  }

  _rs<CategoryRepository>(CategoryRepositoryImpl(delay));
}

Future<void> initTask({
  bool mock = false,
  Duration? delay,
  int? count,
  int? seed,
}) async {
  if (mock) {
    _rs<TaskDatasource>(await TaskFakeDatasource.init(count, seed));
  } else {
    _rs<TaskDatasource>(TaskLocalDatasource());
  }

  _rs<TaskRepository>(TaskRepositoryImpl(delay));
}

Future<void> initCounter({
  bool mock = false,
  Duration? delay,
  int? count,
  int? seed,
}) async {
  if (mock) {
    _rs<CounterDatasource>(
      await CounterFakeDatasource.init(count: count, seed: seed),
    );
  } else {
    _rs<CounterDatasource>(CounterLocalDatasource());
  }

  _rs<CounterRepository>(CounterRepositoryImpl(delay));
}

Future<void> initCustomColor({
  bool mock = false,
  Duration? delay,
  int? count,
  int? seed,
}) async {
  if (mock) {
    _rs<CustomColorDatasource>(
      await CustomColorFakeDatasource.init(count, seed),
    );
  } else {
    _rs<CustomColorDatasource>(CustomColorLocalDatasource());
  }

  _rs<CustomColorRepository>(CustomColorRepositoryImpl(delay));
}

/// Register single tone
T _rs<T extends Object>(T value) => locator.registerSingleton<T>(value);
