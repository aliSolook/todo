import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/category/category.dart';

void main() async {
  test(
    'given Category when fromJson factory constructor is invoked then a Category with the same content as the source json is expected',
    () {
      const source = Category(title: 'the title', image: null, color: 10);
      final json = {
        'title': source.title,
        'image': source.image,
        'color': source.color,
      };

      final category = Category.fromJson(json);

      expect(
        category,
        predicate<Category>(
          (e) =>
              e.title == source.title &&
              e.image == source.image &&
              e.color == source.color,
          '$source',
        ),
      );
    },
  );

  group('Category == operator', () {
    test(
      'given Category when == operator is used on two categories with same content then equality is expected',
      () {
        const source = Category(title: 'the title', image: null, color: 10);
        final other = Category(
          title: source.title,
          image: source.image,
          color: source.color,
        );

        final result = source == other;

        expect(result, true);
      },
    );

    test(
      'given Category when == operator is used on two categories with same content but different titles then inequality is expected',
      () {
        const source = Category(title: 'the title', image: null, color: 10);
        final other = Category(
          title: 'something different',
          image: source.image,
          color: source.color,
        );

        final result = source == other;

        expect(result, false);
      },
    );

    test(
      'given Category when == operator is used on two categories with same content but different images then inequality is expected',
      () {
        const source = Category(title: 'the title', image: null, color: 10);
        final other = Category(
          title: source.title,
          image: 12,
          color: source.color,
        );

        final result = source == other;

        expect(result, false);
      },
    );

    test(
      'given Category when == operator is used on two categories with same content but different colors then inequality is expected',
      () {
        const source = Category(title: 'the title', image: null, color: 10);
        final other = Category(
          title: source.title,
          image: source.image,
          color: 49,
        );

        final result = source == other;

        expect(result, false);
      },
    );
  });
}
