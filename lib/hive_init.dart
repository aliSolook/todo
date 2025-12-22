import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/features/task/task.dart';
import 'features/category/category.dart';
import 'features/counter/counter.dart';
import 'features/custom_color/custom_color.dart';
import 'features/image/image.dart';
import 'package:path/path.dart' as p;

Future<void> hiveInit([bool sandbox = false]) async {
  final subDir = p.join('todo', 'database');
  if (sandbox) {
    final tmpDir = Directory.systemTemp.path;
    final hivePath = p.join(tmpDir, subDir);

    await Directory(hivePath).create(recursive: true);
    
    Hive.init(hivePath);
  } else {
    await Hive.initFlutter(subDir);
  }

  Hive.registerAdapter(TaskHiveTypeAdapter());
  Hive.registerAdapter(CategoryHiveTypeAdapter());
  Hive.registerAdapter(CounterHiveTypeAdapter());
  Hive.registerAdapter(CustomColorHiveTypeAdapter());

  if (kIsWeb) Hive.registerAdapter(ImageHiveTypeAdapter());

  await Hive.openBox<TaskHiveType>('task_box');
  await Hive.openBox<CategoryHiveType>('category_box');
  await Hive.openBox<CounterHiveType>('counter_box');
  await Hive.openBox<CustomColorHiveType>('custom_color_box');

  if (kIsWeb) await Hive.openBox<ImageHiveType>('image_box');
}
