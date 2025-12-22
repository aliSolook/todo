import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/task/task.dart';
import 'package:todo/main.dart' as app;

void main() {
  // testWidgets('end-to-end test', (tester) async {
  //   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  //   await app.bootstrapApp(true);
  //   await populateSources();
  //   await tester.pumpAndSettle();

  //   await Future.delayed(const Duration(minutes: 20));
  // });
}

Future<void> populateSources() async {
  await populateImage();
  await populateCategory();
  await populateTask();
  await populateCounter();
  await populateCustomColors();
}

Future<void> populateImage() async {
  final datasource = locator.get<ImageDatasource>();

  Future<void> addImage(String assetName) async {
    final title = assetName
        .split('\\')
        .last
        .split('//')
        .last
        .split('.')
        .first
        .replaceAll('_', ' ');

    final data = await rootBundle.load(assetName);
    await datasource.addImage(
      Image(title: title, data: data.buffer.asUint8List()),
    );
  }

  await Future.wait([
    addImage('assets/images/study.png'),
    addImage('assets/images/exercise.png'),
    addImage('assets/images/shopping.png'),
    addImage('assets/images/teaching_image.png'),
    addImage('assets/images/coding_image.png'),
  ]);
}

Future<void> populateCategory() async {
  /// we use the fake category populator
  final datasource = locator.get<CategoryDatasource>();
  final fakeDatasource = await CategoryFakeDatasource.init(7);
  final categories = await fakeDatasource.listCategories();

  await datasource.addAllCategories(categories.map((e) => e.toCategory()));
}

Future<void> populateCounter() async {
  /// we use the fake counter populator
  final datasource = locator.get<CounterDatasource>();
  final fakeDatasource = await CounterFakeDatasource.init(count: 7);
  final counters = await fakeDatasource.listCounters();

  await datasource.addAllCounters(counters.map((e) => e.toCounter()));
}

Future<void> populateTask() async {
  /// we use the fake task populator
  final datasource = locator.get<TaskDatasource>();
  final fakeDatasource = await TaskFakeDatasource.init(360);
  final tasks = await fakeDatasource.listTasks();

  await datasource.addAllTasks(tasks.map((e) => e.toTask()));
}

Future<void> populateCustomColors() async {
  /// we use the fake custom color populator
  final datasource = locator.get<CustomColorDatasource>();
  final fakeDatasource = await CustomColorFakeDatasource.init(7);
  final colors = await fakeDatasource.listCustomColors();

  await datasource.addAllCustomColors(colors.map((e) => e.color));
}
