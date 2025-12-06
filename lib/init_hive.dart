import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/features/task/task.dart';
import 'features/category/category.dart';
import 'features/counter/counter.dart';
import 'features/custom_color/custom_color.dart';
import 'features/image/image.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

void initHive([bool mock = false]) async {
  final subDir = p.join('todo', 'database');
  if (mock) {
    final tmpDir = (await pp.getTemporaryDirectory()).path;
    
    Hive.init(p.join(tmpDir, subDir));
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
