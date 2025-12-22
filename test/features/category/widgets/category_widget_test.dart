import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/image/image.dart' as img;

import '../../../test_utils/mocks/mocks.mocks.dart';

void main() {
  Widget builder(Widget child) => MaterialApp(home: Center(child: child));

  testWidgets(
    'given CategoryWidget when null is provided as category then shimmer is expected',
    (tester) async {
      await tester.pumpWidget(builder(const CategoryWidget()));

      expect(find.byType(Shimmer), findsOneWidget);
    },
  );

  testWidgets(
    'given CategoryWidget when category is provided then no shimmer should not be found',
    (tester) async {
      const category = Category(title: 'title', image: null, color: 0xFFFF0000);
      await tester.pumpWidget(
        builder(const CategoryWidget(category: category)),
      );

      expect(find.byType(Shimmer), findsNothing);
    },
  );

  testWidgets(
    'given CategoryWidget when category is provided then correct ui is expected',
    (tester) async {
      const category = Category(title: 'title', image: null, color: 0xFFFF0000);
      await tester.pumpWidget(
        builder(const CategoryWidget(category: category)),
      );

      expect(find.byType(Shimmer), findsNothing);
      // Checking title
      expect(find.text(category.title), findsOneWidget);

      // Checking color
      var containerFinder = find.byType(DecoratedBox);
      var decoration =
          tester
                  .widgetList<DecoratedBox>(containerFinder)
                  .cast<DecoratedBox?>()
                  .firstWhere(
                    (e) => e!.decoration is BoxDecoration,
                    orElse: () => null,
                  )
                  ?.decoration
              as BoxDecoration?;

      expect(
        decoration?.boxShadow?.first.color.withAlpha(255),
        Color(category.color).withAlpha(255),
      );

      // Checking image icon
      expect(find.byType(SvgPicture), findsOneWidget);

      // Checking actual image
      final categoryWithImage = Category(
        title: category.title,
        image: 1,
        color: category.color,
      );

      final repo = MockImageRepository();
      provideDummy<Either<String, img.Image>>(const Left(''));
      when(
        repo.getImage(categoryWithImage.image),
      ).thenAnswer(
        (realInvocation) async => Right(
          img.Image(
            title: '',
            data: (await rootBundle.load(
              'assets/images/coding_image.png',
            )).buffer.asUint8List(),
          ),
        ),
      );

      await tester.pumpWidget(
        builder(
          RepositoryProvider<img.ImageRepository>.value(
            value: repo,
            child: CategoryWidget(category: categoryWithImage),
          ),
        ),
      );

      containerFinder = find.byType(DecoratedBox);
      decoration =
          tester
                  .widgetList<DecoratedBox>(containerFinder)
                  .cast<DecoratedBox?>()
                  .firstWhere(
                    (e) =>
                        e!.decoration is BoxDecoration &&
                        (e.decoration as BoxDecoration).image != null,
                    orElse: () => null,
                  )
                  ?.decoration
              as BoxDecoration?;

      expect(decoration?.image?.image, isA<img.CustomImageProvider>());
      final provider = decoration?.image?.image as img.CustomImageProvider?;
      expect(provider?.imageId, categoryWithImage.image);
    },
  );

  testWidgets(
    'given CategoryWidget when category is tapped then tap is expected',
    (tester) async {
      int tapCount = 0;
      void onTap() => tapCount++;

      const category = Category(title: 'title', image: null, color: 0xFFFF0000);
      await tester.pumpWidget(
        builder(CategoryWidget(category: category, onTap: onTap)),
      );

      final categoryFinder = find.byType(CategoryWidget);
      expect(categoryFinder, findsOneWidget);

      // warnIfMissed is false because the categorywidget itself is not tappable
      await tester.tap(categoryFinder, warnIfMissed: false);
      expect(tapCount, 1);
    },
  );
}
