import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/category/category.dart';

void main() {
  test(
    'given CategoryHiveType when toCategory is invoked then a Category with same properties is expected',
    () {
      const categorySrc = Category(
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );
      final hiveType = CategoryHiveType(
        title: categorySrc.title,
        image: categorySrc.image,
        color: categorySrc.color,
      );

      final category = hiveType.toCategory();

      expect(category, isA<Category>());
      expect(category, categorySrc);
    },
  );

  test(
    'given CategoryHiveType when formCategory factory constructor is invoked then a CategoryHiveType with same properties as source is expected',
    () {
      const category = Category(title: 'title', image: 24, color: 0xFF000000);

      final hiveType = CategoryHiveType.fromCategory(category);

      expect(hiveType, isA<CategoryHiveType>());
      expect(
        hiveType,
        predicate<CategoryHiveType>(
          (e) =>
              e.color == category.color &&
              e.image == category.image &&
              e.title == category.title,
          '$category',
        ),
      );
    },
  );

  test(
    'given CategoryHiveType when wrap is invoked then a CategoryWrapper with same properties as CategoryHiveType plus an id is expected',
    () {
      const id = 0;
      const category = Category(title: 'title', image: 24, color: 0xFF000000);
      final hiveType = CategoryHiveType.fromCategory(category);

      final wrap = hiveType.wrap(id);

      expect(wrap, isA<CategoryWrapper>());
      expect(
        wrap,
        predicate<CategoryWrapper>(
          (e) =>
              e.id == id &&
              e.color == category.color &&
              e.image == category.image &&
              e.title == category.title,
          CategoryWrapper.fromCategory(id, category).toString(),
        ),
      );
    },
  );
}
