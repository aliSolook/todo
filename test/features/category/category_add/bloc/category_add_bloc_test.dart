import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/listable/listable.dart';

import '../../../../test_utils/mocks/mocks.mocks.dart';

void main() {
  late CategoryAddScreenBloc bloc;
  late CustomColorRepository customColorRepo;
  late CategoryRepository categoryRepo;

  setUp(() {
    customColorRepo = MockCustomColorRepository();
    categoryRepo = MockCategoryRepository();
    locator.registerSingleton<CustomColorRepository>(customColorRepo);
    locator.registerSingleton<CategoryRepository>(categoryRepo);
    bloc = CategoryAddScreenBloc();
  });

  tearDown(() {
    locator.reset();
  });

  group('title', () {
    test(
      'given CategoryAddScreenBloc with empty title when title is changed then an state update with new title is expected',
      () async {
        const String newTitle = 'new title';
        final initState = bloc.state;

        // Change the title
        bloc.add(const CategoryAddScreenTitleChanged(newTitle));

        // Check title is changed
        final newState = await bloc.stream.first.timeout(
          const Duration(seconds: 3),
        );
        expect(newState.title, newTitle);

        // Check title was initially empty
        expect(initState.title, isEmpty);

        // Checking that only the title has changed and nothing else
        expect(newState.copyWith(title: initState.title), initState);
      },
    );

    test(
      'given CategoryAddScreenBloc with a not empty title when title is unfocused then a title error should not be changed',
      () async {
        bloc = CategoryAddScreenBloc(
          const CategoryAddScreenState.init(title: 'some title'),
        );
        final initState = bloc.state;

        // unfocus the title
        bloc.add(const CategoryAddScreenTitleFocusChanged(false));

        // Check title error is not changed
        final newState = await bloc.stream.first.timeout(
          const Duration(seconds: 3),
        );
        expect(newState.titleError, isEmpty);

        // Check title error was initially empty
        expect(initState.titleError, isEmpty);

        // Verifying nothing is changed
        expect(newState.copyWith(titleError: ''), initState);
      },
    );

    test(
      'given CategoryAddScreenBloc with empty title when title is unfocused then a title error is expected',
      () async {
        final initState = bloc.state;

        // unfocus the title
        bloc.add(const CategoryAddScreenTitleFocusChanged(false));

        // Check title is changed
        final newState = await bloc.stream.first.timeout(
          const Duration(seconds: 3),
        );
        expect(newState.titleError, CategoryAddScreenBloc.titleError);

        // Check title error was initially empty
        expect(initState.titleError, isEmpty);

        // Checking that only the title has changed and nothing else
        expect(newState.copyWith(titleError: ''), initState);
      },
    );

    test(
      'given CategoryAddScreenBloc with empty title and not empty titleError when title is focused then title error should be removed',
      () async {
        bloc = CategoryAddScreenBloc(
          const CategoryAddScreenState.init(
            titleError: CategoryAddScreenBloc.titleError,
          ),
        );
        final initState = bloc.state;

        // unfocus the title
        bloc.add(const CategoryAddScreenTitleFocusChanged(true));

        // Check title error is changed
        final newState = await bloc.stream.first.timeout(
          const Duration(seconds: 3),
        );
        expect(newState.titleError, isEmpty);

        // Check title error wasn't initially empty
        expect(initState.titleError, CategoryAddScreenBloc.titleError);

        // Checking that only the title has changed and nothing else
        expect(
          newState.copyWith(titleError: CategoryAddScreenBloc.titleError),
          initState,
        );
      },
    );
  });

  test(
    'given CategoryAddScreenBloc with empty image when image is changed then new state with new image is expected',
    () async {
      const newId = 3;
      final initState = bloc.state;

      bloc.add(const CategoryAddScreenImageChanged(newId));

      // Verifying image update
      final newState = await bloc.stream.first.timeout(
        const Duration(seconds: 3),
      );
      expect(newState.image, newId);

      // Verifying init image was null
      expect(initState.image, isNull);

      // Verifying only image has changed
      expect(newState.copyWith(image: Right(initState.image)), initState);
    },
  );

  test(
    'given CategoryAddScreenBloc with empty color when color is changed then new state with new color is expected',
    () async {
      const newColor = 0xFF00FF00; // green
      final initState = bloc.state;

      bloc.add(const CategoryAddScreenColorChanged(newColor));

      // Verifying color update
      final newState = await bloc.stream.first.timeout(
        const Duration(seconds: 3),
      );
      expect(newState.color, newColor);

      // Verifying init color was not set
      expect(initState.color, lessThan(0));

      // Verifying only color has changed
      expect(newState.copyWith(color: initState.color), initState);
    },
  );

  test(
    'given CategoryAddScreenBloc some default value when reset is requested then new state with empty category fields is expected, other fields must be preserved',
    () async {
      bloc = CategoryAddScreenBloc(
        const CategoryAddScreenState.init(
          id: 34, // expected not to change
          title: 'some title', // expected to reset
          color: 0xFF00FF00, // expected to reset
          image: 34, // expected to reset
          titleError: 'some error', // expected to reset
          customColorDeleteState: [
            ListableDeleteState.inProgress(item: 3),
          ], // expected not to change
          customColorsState: SubState.inProgress(), // expected not to change
          submitState: SubState.failure('the error'), // expected not to change
        ),
      );
      final initState = bloc.state;

      bloc.add(const CategoryAddScreenResetRequested());

      // Verifying changes
      final newState = await bloc.stream.first.timeout(
        const Duration(seconds: 3),
      );

      expect(newState.title, isEmpty);
      expect(newState.color, lessThan(0));
      expect(newState.image, isNull);
      expect(newState.titleError, isEmpty);

      expect(newState.id, initState.id);
      expect(newState.customColorDeleteState, initState.customColorDeleteState);
      expect(newState.customColorsState, initState.customColorsState);
      expect(newState.submitState, initState.submitState);
    },
  );

  group('custom colors', () {
    test(
      'give CagetoryAddScreenBloc with empty custom colors when add custom color is requested then a new color is expected in the state',
      () async {
        bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(customColorsState: SubState.success([])),
        );
        final initState = bloc.state;
        const newColor = CustomColorWrapper(4, 4);

        bloc.add(
          const CategoryAddScreenCustomColorAdded(newColor),
        );

        // Verify changes
        final newState = await bloc.stream.first.timeout(
          const Duration(seconds: 3),
        );
        expect(newState.customColorsState.value, equals([newColor]));

        // Verifying only customColorState is changed
        expect(
          newState.copyWith(customColorsState: initState.customColorsState),
          initState,
        );
      },
    );

    group('load', () {
      test(
        'given CategoryAddScreenBloc when load custom colors is requested then custom color repository list method must be invoked and state gets updated',
        () async {
          const fetchResult = [
            CustomColorWrapper(4, 4),
            CustomColorWrapper(5, 5),
          ];

          provideDummy<Either<String, List<CustomColorWrapper>>>(
            const Left(''),
          );
          when(
            customColorRepo.listCustomColors(),
          ).thenAnswer((_) async => const Right(fetchResult));
          final initState = bloc.state;

          bloc.add(const CategoryAddScreenCustomColorsLoadRequested());

          // Verifying loading stage
          final loadingState = await bloc.stream.first.timeout(
            const Duration(seconds: 3),
          );
          expect(
            loadingState.customColorsState,
            const SubState<List<CustomColorWrapper>>.inProgress(),
          );
          expect(
            loadingState.copyWith(
              customColorsState: initState.customColorsState,
            ),
            initState,
          );

          // Verifying success stage
          final successState = await bloc.stream.first.timeout(
            const Duration(seconds: 3),
          );

          expect(successState.customColorsState, SubState.success(fetchResult));
          expect(
            successState.copyWith(
              customColorsState: loadingState.customColorsState,
            ),
            loadingState,
          );
        },
      );

      test(
        'given CategoryAddScreenBloc when load custom colors is requested then custom color repository list method must be invoked and error must be emitted',
        () async {
          const fetchResult = 'خطایی رخ داد';

          provideDummy<Either<String, List<CustomColorWrapper>>>(
            const Left(''),
          );
          when(
            customColorRepo.listCustomColors(),
          ).thenAnswer((_) async => const Left(fetchResult));
          final initState = bloc.state;

          bloc.add(const CategoryAddScreenCustomColorsLoadRequested());

          // Verifying loading stage
          final loadingState = await bloc.stream.first.timeout(
            const Duration(seconds: 3),
          );
          expect(
            loadingState.customColorsState,
            const SubState<List<CustomColorWrapper>>.inProgress(),
          );
          expect(
            loadingState.copyWith(
              customColorsState: initState.customColorsState,
            ),
            initState,
          );

          // Verifying failure stage
          final successState = await bloc.stream.first.timeout(
            const Duration(seconds: 3),
          );

          expect(
            successState.customColorsState,
            const SubState<List<CustomColorWrapper>>.failure(fetchResult),
          );
          expect(
            successState.copyWith(
              customColorsState: loadingState.customColorsState,
            ),
            loadingState,
          );
        },
      );
    });

    group('delete', () {
      test(
        'given CategoryAddScreenBloc with not empty customColorDeleteState when a signle delete custom color is requested then custom color repository delete method must be invoked and state gets updated',
        () async {
          const successMessage = 'deleted successfully';
          const dynamic targetId = 4;
          const dynamic dummyId = 5;
          const defaultColors = [
            CustomColorWrapper(targetId, 4),
            CustomColorWrapper(dummyId, 5),
          ];

          bloc = CategoryAddScreenBloc(
            CategoryAddScreenState.init(
              customColorsState: SubState.success(defaultColors),
              customColorDeleteState: const [
                ListableDeleteState.inProgress(item: dummyId),
              ],
            ),
          );
          final initState = bloc.state;

          provideDummy<Either<String, String>>(const Right(''));

          when(
            customColorRepo.deleteCustomColor(targetId),
          ).thenAnswer((_) async => const Right(successMessage));

          bloc.add(const CategoryAddScreenCustomColorDeleteRequested(targetId));

          // fetching all expected states
          final firstState = bloc.stream.elementAt(0);
          final secondState = bloc.stream.elementAt(1);
          final thirdState = bloc.stream.elementAt(2);

          // Verifying loading stage
          final loadingState = await firstState.timeout(
            const Duration(seconds: 3),
          );
          expect(
            loadingState.customColorDeleteState,
            equals(
              initState.customColorDeleteState.followedBy([
                const ListableDeleteState.inProgress(item: targetId),
              ]),
            ),
          );
          expect(
            loadingState.copyWith(
              customColorDeleteState: initState.customColorDeleteState,
            ),
            initState,
          );

          // Verifying success stage
          final successState = await secondState.timeout(
            const Duration(seconds: 3),
          );

          expect(
            successState.customColorDeleteState,
            equals(
              initState.customColorDeleteState.followedBy(const [
                ListableDeleteState.success(
                  item: targetId,
                  message: successMessage,
                ),
              ]),
            ),
          );
          expect(
            successState.customColorsState,
            SubState.success(
              defaultColors.where((e) => e.id != targetId).toList(),
            ),
          );
          expect(
            successState.copyWith(
              customColorDeleteState: loadingState.customColorDeleteState,
              customColorsState: loadingState.customColorsState,
            ),
            loadingState,
          );

          // Verifying post result state
          final postResultState = await thirdState.timeout(
            const Duration(seconds: 3),
          );
          expect(
            postResultState.customColorDeleteState,
            equals(initState.customColorDeleteState),
          );
          expect(
            postResultState.copyWith(
              customColorDeleteState: successState.customColorDeleteState,
            ),
            successState,
          );
        },
      );

      test(
        'given CategoryAddScreenBloc with not empty customColorDeleteState when a signle delete custom color with invalid id is requested error is expected',
        () async {
          const failureMessage = 'id not found';
          const dynamic targetId = 4;
          const dynamic dummyId = 5;
          const defaultColors = [
            CustomColorWrapper(3, 4),
            CustomColorWrapper(dummyId, 5),
          ];

          bloc = CategoryAddScreenBloc(
            CategoryAddScreenState.init(
              customColorsState: SubState.success(defaultColors),
              customColorDeleteState: const [
                ListableDeleteState.inProgress(item: dummyId),
              ],
            ),
          );
          final initState = bloc.state;

          provideDummy<Either<String, String>>(const Right(''));

          when(
            customColorRepo.deleteCustomColor(targetId),
          ).thenAnswer((_) async => const Left(failureMessage));

          bloc.add(const CategoryAddScreenCustomColorDeleteRequested(targetId));

          // fetching all expected states
          final firstState = bloc.stream.elementAt(0);
          final secondState = bloc.stream.elementAt(1);
          final thirdState = bloc.stream.elementAt(2);

          // Verifying loading stage
          final loadingState = await firstState.timeout(
            const Duration(seconds: 3),
          );
          expect(
            loadingState.customColorDeleteState,
            equals(
              initState.customColorDeleteState.followedBy([
                const ListableDeleteState.inProgress(item: targetId),
              ]),
            ),
          );
          expect(
            loadingState.copyWith(
              customColorDeleteState: initState.customColorDeleteState,
            ),
            initState,
          );

          // Verifying failure stage
          final successState = await secondState.timeout(
            const Duration(seconds: 3),
          );

          expect(
            successState.customColorDeleteState,
            equals(
              initState.customColorDeleteState.followedBy(const [
                ListableDeleteState.failure(
                  item: targetId,
                  message: failureMessage,
                ),
              ]),
            ),
          );
          expect(
            successState.customColorsState,
            SubState.success(defaultColors),
          );
          expect(
            successState.copyWith(
              customColorDeleteState: loadingState.customColorDeleteState,
              customColorsState: loadingState.customColorsState,
            ),
            loadingState,
          );

          // Verifying post result state
          final postResultState = await thirdState.timeout(
            const Duration(seconds: 3),
          );
          expect(
            postResultState.customColorDeleteState,
            equals(initState.customColorDeleteState),
          );
          expect(
            postResultState.copyWith(
              customColorDeleteState: successState.customColorDeleteState,
            ),
            successState,
          );
        },
      );
    });
  });

  group('submit', () {
    test(
      'give CategoryAddScreenBloc with required parameters for submit when submit is requested then correct behavior is expected',
      () async {
        const category = CategoryWrapper(
          id: 0,
          title: 'title',
          image: 3,
          color: 0xFF00FF00,
        );
        bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.fromCategory(category, id: const Right(null)),
        );
        final initState = bloc.state;

        provideDummy<Either<String, dynamic>>(const Right(null));

        when(
          categoryRepo.addCategory(category.toCategory()),
        ).thenAnswer((_) async => Right(category.id));

        bloc.add(const CategoryAddScreenSubmitted());

        final firstState = bloc.stream.elementAt(0);
        final secondState = bloc.stream.elementAt(1);

        // Verify loading state
        final loadingState = await firstState;
        expect(
          loadingState,
          initState.copyWith(submitState: const SubState.inProgress()),
        );

        // Verify success state
        final successState = await secondState;
        expect(
          successState,
          loadingState.copyWith(submitState: SubState.success(category)),
        );
      },
    );

    test(
      'give CategoryAddScreenBloc when submit is requested then error is expected',
      () async {
        const category = CategoryWrapper(
          id: 0,
          title: 'title',
          image: 3,
          color: 0xFF00FF00,
        );
        bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.fromCategory(category, id: const Right(null)),
        );
        final initState = bloc.state;

        when(
          categoryRepo.addCategory(category.toCategory()),
        ).thenAnswer((_) async => Right(category.id));

        bloc.add(const CategoryAddScreenSubmitted());

        final firstState = bloc.stream.elementAt(0);
        final secondState = bloc.stream.elementAt(1);

        // Verify loading state
        final loadingState = await firstState;
        expect(
          loadingState,
          initState.copyWith(submitState: const SubState.inProgress()),
        );

        // Verify success state
        final successState = await secondState;
        expect(
          successState,
          loadingState.copyWith(submitState: SubState.success(category)),
        );
      },
    );
  });
}
