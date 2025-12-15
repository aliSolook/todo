import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/task/task.dart';
import 'package:todo/hive_init.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await hiveInit(true);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  });

  test(
    'given hive initialized when accessing task_box then returns task box',
    () {
      expect(
        Hive.box<TaskHiveType>('task_box'),
        isA<Box<TaskHiveType>>(),
      );
    },
  );

  test(
    'given hive initialized when accessing category_box then returns category box',
    () {
      expect(
        Hive.box<CategoryHiveType>('category_box'),
        isA<Box<CategoryHiveType>>(),
      );
    },
  );

  test(
    'given hive initialized when accessing counter_box then returns counter box',
    () {
      expect(
        Hive.box<CounterHiveType>('counter_box'),
        isA<Box<CounterHiveType>>(),
      );
    },
  );

  test(
    'given hive initialized when accessing custom_color_box then returns custom color box',
    () {
      expect(
        Hive.box<CustomColorHiveType>('custom_color_box'),
        isA<Box<CustomColorHiveType>>(),
      );
    },
  );

  test(
    'given web platform when opening image_box then box is opened',
    () async {
      if (kIsWeb) {
        final box = await Hive.openBox<ImageHiveType>('image_box');
        expect(box, isA<Box<ImageHiveType>>());
        await box.close();
      } else {
        expect(kIsWeb, isFalse);
      }
    },
  );
}

Box<CategoryHiveType> box(String boxName) =>
    Hive.box<CategoryHiveType>(boxName);
