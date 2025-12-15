import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/category/category.dart';

void main() {
  test(
    'given CategoryWrapper when fromCategory factory constructor is invoked then a CategoryWrapper if same id and category properties as source is expected',
    () {
      const id = 0;
      const category = Category(title: 'title', image: 24, color: 0xFF000000);

      final wrapper = CategoryWrapper.fromCategory(id, category);

      expect(wrapper, isA<CategoryWrapper>());
      expect(
        wrapper,
        predicate<CategoryWrapper>(
          (e) =>
              e.id == id &&
              e.color == category.color &&
              e.image == category.image &&
              e.title == category.title,
          'CategoryWrapper($id, ${category.color}, ${category.image}, ${category.title})',
        ),
      );
    },
  );

  test(
    'given CategoryWrapper when toCategory is invoked then a Category is expected with same properties as the CategoryWrapper',
    () {
      const id = 0;
      const categorySrc = Category(
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );
      final wrapper = CategoryWrapper(
        id: id,
        title: categorySrc.title,
        image: categorySrc.image,
        color: categorySrc.color,
      );

      final category = wrapper.toCategory();

      expect(category, isA<Category>());
      expect(
        category,
        predicate<Category>(
          (e) =>
              e.color == categorySrc.color &&
              e.image == categorySrc.image &&
              e.title == categorySrc.title,
          '$categorySrc',
        ),
      );
    },
  );

  group('CategoryWrapper equal operator', () {
    test('given two identical categoryWrappers then they are equal', () {
      const a = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );
      const b = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );

      expect(a, b);
    });

    test('given different id then categoryWrappers are not equal', () {
      const a = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );
      const b = CategoryWrapper(
        id: 1,
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );

      expect(a, isNot(b));
    });

    test('given different title then categoryWrappers are not equal', () {
      const a = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );
      const b = CategoryWrapper(
        id: 0,
        title: 'no match',
        image: 24,
        color: 0xFF000000,
      );

      expect(a, isNot(b));
    });

    test('given different image then categoryWrappers are not equal', () {
      const a = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );
      const b = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 10,
        color: 0xFF000000,
      );

      expect(a, isNot(b));
    });

    test('given different color then categoryWrappers are not equal', () {
      const a = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 24,
        color: 0xFF000000,
      );
      const b = CategoryWrapper(
        id: 0,
        title: 'title',
        image: 24,
        color: 0xFF0000FF,
      );

      expect(a, isNot(b));
    });
  });

  group('CategoryWrapper copyWith', () {
    test(
      'given categoryWrapper when copyWith called with no args then returns identical instance',
      () {
        const original = CategoryWrapper(
          id: 0,
          title: 'title',
          image: 24,
          color: 0xFF000000,
        );

        final copied = original.copyWith();

        expect(copied, original);
      },
    );

    test(
      'given categoryWrapper when copyWith called with new id then id is updated and others preserved',
      () {
        const original = CategoryWrapper(
          id: 0,
          title: 'title',
          image: 24,
          color: 0xFF000000,
        );

        final copied = original.copyWith(id: 1);

        expect(copied.id, 1);
        expect(copied.title, original.title);
        expect(copied.image, original.image);
        expect(copied.color, original.color);
      },
    );

    test(
      'given categoryWrapper when copyWith called with new title then title is updated and others preserved',
      () {
        const original = CategoryWrapper(
          id: 0,
          title: 'title',
          image: 24,
          color: 0xFF000000,
        );

        final copied = original.copyWith(title: 'no match');

        expect(copied.title, 'no match');
        expect(copied.id, original.id);
        expect(copied.image, original.image);
        expect(copied.color, original.color);
      },
    );

    test(
      'given categoryWrapper when copyWith called with new image then image is updated and others preserved',
      () {
        const original = CategoryWrapper(
          id: 0,
          title: 'title',
          image: 24,
          color: 0xFF000000,
        );

        final copied = original.copyWith(image: 10);

        expect(copied.image, 10);
        expect(copied.id, original.id);
        expect(copied.title, original.title);
        expect(copied.color, original.color);
      },
    );

    test(
      'given categoryWrapper when copyWith called with new color then color is updated and others preserved',
      () {
        const original = CategoryWrapper(
          id: 0,
          title: 'title',
          image: 24,
          color: 0xFF000000,
        );

        final copied = original.copyWith(color: 0xFF0000FF);

        expect(copied.color, 0xFF0000FF);
        expect(copied.id, original.id);
        expect(copied.title, original.title);
        expect(copied.image, original.image);
      },
    );
  });
}
