import 'package:flutter_test/flutter_test.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/task/task.dart';

void main() {
  setUp(() async {
    await locator.reset();
    await getItInit(mock: true, count: 0);
  });

  group('Dependency injection', () {
    test('Image dependencies are registered', () {
      expect(locator.isRegistered<ImageDatasource>(), true);
      expect(locator.isRegistered<ImageRepository>(), true);
    });

    test('Category dependencies are registered', () {
      expect(locator.isRegistered<CategoryDatasource>(), true);
      expect(locator.isRegistered<CategoryRepository>(), true);
    });

    test('Task dependencies are registered', () {
      expect(locator.isRegistered<TaskDatasource>(), true);
      expect(locator.isRegistered<TaskRepository>(), true);
    });

    test('Counter dependencies are registered', () {
      expect(locator.isRegistered<CounterDatasource>(), true);
      expect(locator.isRegistered<CounterRepository>(), true);
    });

    test('CustomColor dependencies are registered', () {
      expect(locator.isRegistered<CustomColorDatasource>(), true);
      expect(locator.isRegistered<CustomColorRepository>(), true);
    });
  });
}
