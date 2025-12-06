import 'dart:io';
import 'package:hive/hive.dart';
import 'package:todo/features/category/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const boxName = 'category_box';
  const category1 = Category(title: 'Work', image: 14, color: 0xFFFFFFFF);
  const category2 = Category(title: 'Home', image: 30, color: 0xFFFF0000);

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);

    Hive.registerAdapter(CategoryHiveTypeAdapter());

    await Hive.openBox<CategoryHiveType>(boxName);
  });

  tearDown(() async {
    await box(boxName).clear();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  });

  group('CategoryLocalDatasource', () {
    test('addCategory stores category', () async {
      final datasource = CategoryLocalDatasource();

      final id = await datasource.addCategory(category1);

      final result = box(boxName).get(id)?.toCategory();
      expect(result, category1);
    });

    test('getCategory fetches category', () async {
      final datasource = CategoryLocalDatasource();
      final id = await box(
        boxName,
      ).add(CategoryHiveType.fromCategory(category1));

      final result = await datasource.getCategory(id);

      expect(result, CategoryWrapper.fromCategory(id, category1));
    });

    test('deleteCategory removes category', () async {
      final datasource = CategoryLocalDatasource();
      final id = await box(
        boxName,
      ).add(CategoryHiveType.fromCategory(category1));

      await datasource.deleteCategory(id);

      expect(box(boxName).containsKey(id), false);
    });

    test('deleteCategory throws when id not found', () async {
      final datasource = CategoryLocalDatasource();
      expect(
        () => datasource.deleteCategory(999),
        throwsA(isA<CategoryNotFoundException>()),
      );
    });

    test('updateCategory modifies existing category', () async {
      final datasource = CategoryLocalDatasource();
      final id = await box(
        boxName,
      ).add(CategoryHiveType.fromCategory(category1));

      await datasource.updateCategory(
        CategoryWrapper.fromCategory(id, category2),
      );

      final result = box(boxName).get(id)?.toCategory();
      expect(result, category2);
    });

    test('updateCategory throws when id not found', () async {
      final datasource = CategoryLocalDatasource();

      expect(
        () => datasource.updateCategory(
          CategoryWrapper.fromCategory(1, category1),
        ),
        throwsA(isA<CategoryNotFoundException>()),
      );
    });

    test('listCategories returns all categories', () async {
      final datasource = CategoryLocalDatasource();
      const categories = [category1, category2];
      final ids = await box(
        boxName,
      ).addAll(categories.map(CategoryHiveType.fromCategory));

      final wrappers = await datasource.listCategories();

      expect(
        wrappers,
        equals(
          List.generate(
            ids.length,
            (i) =>
                CategoryWrapper.fromCategory(ids.elementAt(i), categories[i]),
          ),
        ),
      );
    });
  });
}

Box<CategoryHiveType> box(String boxName) =>
    Hive.box<CategoryHiveType>(boxName);
