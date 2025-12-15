import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/di/di.dart';

import '../../../test_utils/mocks/mocks.mocks.dart';

void main() {
  late final CategoryDatasource source;
  late final CategoryRepository repo;

  setUpAll(() {
    source = MockCategoryDatasource();
    locator.registerSingleton<CategoryDatasource>(source);
    repo = CategoryRepositoryImpl();
  });

  tearDown(() async {
    resetMockitoState();
    reset(source);
  });

  group('addCategory', () {
    test(
      'given category when addCategory invoked then returns right with new id',
      () async {
        const outputId = 1;
        const category = Category(title: 'title', image: null, color: 10);
        when(source.addCategory(category)).thenAnswer((_) async => outputId);

        final result = await repo.addCategory(category);

        verify(source.addCategory(category)).called(1);
        expect(result, const Right(outputId));
      },
    );
  });

  group('deleteCategory', () {
    test(
      'given existing id when deleteCategory invoked then returns success message',
      () async {
        const deleteId = 1;
        when(source.deleteCategory(deleteId));

        final result = await repo.deleteCategory(deleteId);

        verify(source.deleteCategory(deleteId)).called(1);
        expect(result, const Right('دسته‌بندی با موفقیت حذف شد'));
      },
    );

    test(
      'given non-existing id when deleteCategory invoked then returns not found left',
      () async {
        const deleteId = 1;
        when(
          source.deleteCategory(deleteId),
        ).thenThrow(CategoryNotFoundException(deleteId));

        final result = await repo.deleteCategory(deleteId);

        verify(source.deleteCategory(deleteId)).called(1);
        expect(result, const Left('دسته‌‌بندی وجود ندارد'));
      },
    );
  });

  group('getCategory', () {
    test(
      'given existing id when getCategory invoked then returns right with category',
      () async {
        const id = 1;
        const category = CategoryWrapper(
          id: id,
          title: 'title',
          image: null,
          color: 10,
        );
        when(
          source.getCategory(id),
        ).thenAnswer((_) async => category);

        final result = await repo.getCategory(id);

        verify(source.getCategory(id)).called(1);
        expect(result, const Right(category));
      },
    );

    test(
      'given non-existing id when getCategory invoked then returns not found left',
      () async {
        const id = 1;
        when(source.getCategory(id)).thenThrow(CategoryNotFoundException(id));

        final result = await repo.getCategory(id);

        verify(source.getCategory(id)).called(1);
        expect(result, const Left('دسته‌‌بندی وجود ندارد'));
      },
    );
  });

  group('listCategories', () {
    test(
      'given datasource with categories when listCategories invoked then returns right with list',
      () async {
        const categories = [
          CategoryWrapper(id: 0, title: 'title', image: null, color: 10),
          CategoryWrapper(id: 1, title: 'something else', image: 1, color: 11),
        ];
        when(source.listCategories()).thenAnswer((_) async => categories);

        final result = await repo.listCategories();

        verify(source.listCategories()).called(1);
        expect(result, const Right(categories));
      },
    );
  });

  group('updateCategory', () {
    test(
      'given category when updateCategory invoked then returns success message',
      () async {
        const updateCategory = CategoryWrapper(
          id: 0,
          title: 'title',
          image: null,
          color: 10,
        );
        when(source.updateCategory(updateCategory));

        final result = await repo.updateCategory(updateCategory);

        verify(source.updateCategory(updateCategory)).called(1);
        expect(result, const Right('دسته‌بندی با موفقیت ویرایش شد'));
      },
    );

    test(
      'given non-existing category when updateCategory invoked then returns not found left',
      () async {
        const updateCategory = CategoryWrapper(
          id: 0,
          title: 'title',
          image: null,
          color: 10,
        );
        when(
          source.updateCategory(updateCategory),
        ).thenThrow(CategoryNotFoundException(updateCategory.id));

        final result = await repo.updateCategory(updateCategory);

        verify(source.updateCategory(updateCategory)).called(1);
        expect(result, const Left('دسته‌‌بندی وجود ندارد'));
      },
    );
  });
}