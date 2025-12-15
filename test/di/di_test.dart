import 'package:flutter_test/flutter_test.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/task/task.dart';

void main() {
  setUpAll(() async {
    // await locator.reset();
    await getItInit(mock: true, count: 0);
  });

  test(
    'given locator when it is initiated then both ImageDatasource and ImageRipository must be registered',
    () {
      expect(locator.isRegistered<ImageDatasource>(), true);
      expect(locator.isRegistered<ImageRepository>(), true);
    },
  );

  test(
    'given locator when it is initiated then both CategoryDatasource and CategoryRipository must be registered',
    () {
      expect(locator.isRegistered<CategoryDatasource>(), true);
      expect(locator.isRegistered<CategoryRepository>(), true);
    },
  );

  test(
    'given locator when it is initiated then both TaskDatasource and TaskRipository must be registered',
    () {
      expect(locator.isRegistered<TaskDatasource>(), true);
      expect(locator.isRegistered<TaskRepository>(), true);
    },
  );

  test(
    'given locator when it is initiated then both CounterDatasource and CounterRipository must be registered',
    () {
      expect(locator.isRegistered<CounterDatasource>(), true);
      expect(locator.isRegistered<CounterRepository>(), true);
    },
  );

  test(
    'given locator when it is initiated then both CustomColorDatasource and CustomColorRipository must be registered',
    () {
      expect(locator.isRegistered<CustomColorDatasource>(), true);
      expect(locator.isRegistered<CustomColorRepository>(), true);
    },
  );
}
