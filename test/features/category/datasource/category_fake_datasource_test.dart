import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/category/category.dart';

void main() {
  const category1 = Category(title: 'Work', image: 14, color: 0xFFFFFFFF);
  const category2 = Category(title: 'Home', image: 30, color: 0xFFFF0000);

  group('add', () {
    test(
      'given category when addCategory is invoked then the same category is added to the backing list',
      () async {
        final data = <CategoryWrapper>[];
        final datasource = CategoryFakeDatasource(data);

        final id = await datasource.addCategory(category1);

        expect(data, hasLength(1));
        expect(data[0], CategoryWrapper.fromCategory(id, category1));
      },
    );
  });

  group('get', () {
    test(
      'given existing id when getCategory is invoked then returns the matching category wrapper from backing list',
      () async {
        const id = 0;
        final data = [CategoryWrapper.fromCategory(id, category1)];
        final datasource = CategoryFakeDatasource(data);

        final result = await datasource.getCategory(id);

        expect(result, CategoryWrapper.fromCategory(id, category1));
      },
    );

    test(
      'given invalid id when getCategory is invoked then CategoryNotFoundException is thrown',
      () async {
        final datasource = CategoryFakeDatasource([]);
        expect(
          () => datasource.getCategory(0),
          throwsA(isA<CategoryNotFoundException>()),
        );
      },
    );
  });

  group('delete', () {
    test(
      'given valid id when deleteCategory is invoked then backing list no longer contains the item',
      () async {
        const id = 0;
        final data = [CategoryWrapper.fromCategory(id, category1)];
        final datasource = CategoryFakeDatasource(data);

        await datasource.deleteCategory(id);

        expect(data, hasLength(0));
      },
    );

    test(
      'given invalid id when deleteCategory is invoked then CategoryNotFoundException is thrown',
      () async {
        final data = <CategoryWrapper>[];
        final datasource = CategoryFakeDatasource(data);
        expect(
          () => datasource.deleteCategory(999),
          throwsA(isA<CategoryNotFoundException>()),
        );
      },
    );
  });

  group('update', () {
    test(
      'given valid id when updateCategory is invoked then backing list contains updated category with same id',
      () async {
        const id = 0;
        final data = [CategoryWrapper.fromCategory(id, category1)];
        final datasource = CategoryFakeDatasource(data);

        await datasource.updateCategory(
          CategoryWrapper.fromCategory(id, category2),
        );

        expect(data, hasLength(1));
        expect(data.first, CategoryWrapper.fromCategory(id, category2));
      },
    );

    test(
      'given invalid id when updateCategory is invoked then CategoryNotFoundException is thrown',
      () async {
        final data = <CategoryWrapper>[];
        final datasource = CategoryFakeDatasource(data);

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
      'given backing list when listCategories is invoked then returns a list equal to the backing list',
      () async {
        final source = [
          CategoryWrapper.fromCategory(0, category1),
          CategoryWrapper.fromCategory(1, category2),
        ];
        final data = List.of(source);
        final datasource = CategoryFakeDatasource(data);

        final wrappers = await datasource.listCategories();

        expect(wrappers, equals(source));
        expect(data, equals(source));
      },
    );
  });
}
