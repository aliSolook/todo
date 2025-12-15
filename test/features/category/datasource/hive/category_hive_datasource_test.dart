import 'dart:io';
import 'package:hive/hive.dart';
import 'package:todo/features/category/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const boxName = 'category_box';
  const category1 = Category(title: 'Work', image: 14, color: 0xFFFFFFFF);
  const category2 = Category(title: 'Home', image: 30, color: 0xFFFF0000);
  late CategoryLocalDatasource datasource;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(CategoryHiveTypeAdapter());
    await Hive.openBox<CategoryHiveType>(boxName);
  });

  setUp(() {
    datasource = CategoryLocalDatasource();
  });

  tearDown(() async {
    await getBox(boxName).clear();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  });

  group('add', () {
    test(
      'given category when addCategory invoked then same category must be in box',
      () async {
        final id = await datasource.addCategory(category1);

        final result = getBox(boxName).get(id)?.toCategory();
        expect(result, category1);
      },
    );
  });

  group('get', () {
    test(
      'given existing category when getCategory invoked then returns wrapper with same properties',
      () async {
        final id = await getBox(
          boxName,
        ).add(CategoryHiveType.fromCategory(category1));

        final result = await datasource.getCategory(id);

        expect(result, CategoryWrapper.fromCategory(id, category1));
      },
    );

    test(
      'given non-existing category when getCategory invoked then throws CategoryNotFoundException',
      () async {
        expect(
          () => datasource.getCategory(0),
          throwsA(isA<CategoryNotFoundException>()),
        );
      },
    );
  });

  group('delete', () {
    test(
      'given existing category when deleteCategory invoked then box does not contain the id',
      () async {
        final id = await getBox(
          boxName,
        ).add(CategoryHiveType.fromCategory(category1));

        await datasource.deleteCategory(id);

        expect(getBox(boxName).containsKey(id), false);
      },
    );

    test(
      'given non-existing category when deleteCategory invoked then throws CategoryNotFoundException',
      () async {
        expect(
          () => datasource.deleteCategory(999),
          throwsA(isA<CategoryNotFoundException>()),
        );
      },
    );
  });

  group('update', () {
    test(
      'given existing category when updateCategory invoked then box contains updated category',
      () async {
        final id = await getBox(
          boxName,
        ).add(CategoryHiveType.fromCategory(category1));

        await datasource.updateCategory(
          CategoryWrapper.fromCategory(id, category2),
        );

        final result = getBox(boxName).get(id)?.toCategory();
        expect(result, category2);
      },
    );

    test(
      'given non-existing category when updateCategory invoked then throws CategoryNotFoundException',
      () async {
        expect(
          () => datasource.updateCategory(
            CategoryWrapper.fromCategory(1, category1),
          ),
          throwsA(isA<CategoryNotFoundException>()),
        );
      },
    );
  });

  group('list', () {
    test(
      'given box with categories when listCategories invoked then returns wrappers equal to box contents',
      () async {
        final box = getBox(boxName);
        final source = [category1, category2];
        final ids = await box.addAll(source.map(CategoryHiveType.fromCategory));

        final wrappers = await datasource.listCategories();

        final sourceWrappers = List.generate(
          ids.length,
          (i) => CategoryWrapper.fromCategory(ids.elementAt(i), source[i]),
        );
        final boxSource = box.toMap().entries.map(
          (e) => CategoryWrapper.fromCategory(e.key, e.value.toCategory()),
        );
        expect(wrappers, equals(sourceWrappers));
        expect(boxSource, equals(sourceWrappers));
      },
    );
  });
}

Box<CategoryHiveType> getBox(String boxName) =>
    Hive.box<CategoryHiveType>(boxName);
