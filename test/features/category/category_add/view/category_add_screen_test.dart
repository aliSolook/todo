import 'package:flutter/material.dart' hide Image;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/listable/listable.dart';

import '../../../../test_utils/test_utils.dart';

class MockCategoryAddScreenBloc
    extends MockBloc<CategoryAddScreenEvent, CategoryAddScreenState>
    implements CategoryAddScreenBloc {
  MockCategoryAddScreenBloc([
    super.initialState = const CategoryAddScreenState.init(),
  ]);
}

void main() {
  late MockCategoryRepository source;

  late Image imageSource1;
  late Image imageSource2;

  late ImageWrapper image1;
  late ImageWrapper image2;
  const customColor = CustomColorWrapper(3, 0xFF00FFFF);

  setUpAll(() async {
    imageSource1 = await readImage('assets/images/shopping.png');
    imageSource2 = await readImage('assets/images/study.png');
  });

  setUp(() async {
    await initImage(mock: true, count: 0);
    image1 = await addImageFromSource(imageSource1);
    image2 = await addImageFromSource(imageSource2);

    await initCustomColor(mock: true, count: 0);
    locator.registerSingleton<CategoryRepository>(
      source = MockCategoryRepository(),
    );
  });

  tearDown(() async {
    await locator.reset();
    reset(source);
    resetMockitoState();
  });

  tearDownAll(() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  group('title', () {
    testWidgets(
      'given CategoryAddScreen with CategoryAddScreenBloc and non-empty title '
      'when screen is initiated '
      'then title textfield must contain that title',
      (tester) async {
        const title = 'some title';
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          const CategoryAddScreenState.init(title: title),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        robot.verifyTitleText(title);
      },
    );

    testWidgets(
      'given CategoryAddScreen with empty title '
      'when title is unfocused '
      'then title error is expected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        bloc.add(const CategoryAddScreenTitleFocusChanged(false));
        await tester.pumpAndSettle();

        robot.verifyTitleHasError(CategoryAddScreenBloc.titleError);
        expect(bloc.state.titleError, CategoryAddScreenBloc.titleError);
      },
    );

    testWidgets(
      'given CategoryAddScreen with non-empty title and title error '
      'when title is unfocused '
      'then no title error is expected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          const CategoryAddScreenState.init(
            title: 'some title',
            titleError: 'some error',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        bloc.add(const CategoryAddScreenTitleFocusChanged(false));
        await tester.pumpAndSettle();

        robot.verifyTitleHasNoError();
        expect(bloc.state.titleError, isEmpty);
      },
    );

    testWidgets(
      'given CategoryAddScreen with non-empty title error '
      'when title is focused '
      'then no title error is expected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          const CategoryAddScreenState.init(titleError: 'some error'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.focusTitle();

        robot.verifyTitleHasNoError();
        expect(bloc.state.titleError, isEmpty);
      },
    );
  });

  group('image', () {
    testWidgets(
      'given CategoryAddScreen with image1 being selected '
      'when screen is initated '
      'then image1 is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(image: image1.id),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        robot.verifyImage(image1);
      },
    );

    testWidgets(
      'given CategoryAddScreen '
      'when image1 gets selected '
      'then image1 is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.selectImage(image1);

        robot.verifyImage(image1);
      },
    );

    testWidgets(
      'given CategoryAddScreen with image1 being selected '
      'when image2 gets selected '
      'then image2 is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(image: image1.id),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.selectImage(image2);

        robot.verifyImage(image2);
      },
    );

    testWidgets(
      'given CategoryAddScreen with image1 being selected '
      'when user cancels image selection '
      'then image1 is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(image: image1.id),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.selectImage(null);

        robot.verifyImage(image1);
      },
    );

    testWidgets(
      'given CategoryAddScreen with image1 being selected '
      'when user deselects the selected image '
      'then no image should be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(image: image1.id),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.deselectImage();

        robot.verifyImage(null);
      },
    );
  });

  group('color', () {
    testWidgets(
      'given CategoryAddScreen with a default color being selected '
      'when screen is initated '
      'then that color is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final defaultColor = Colors.primaries[0];
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(color: defaultColor.toARGB32()),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        robot.verifyColor(0, isSelected: true);
      },
    );

    testWidgets(
      'given CategoryAddScreen with no color being selected '
      'when second color gets selected '
      'then that color is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(const CategoryAddScreenState.init());

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.selectColorAt(1);

        robot.verifyColor(1, isSelected: true);
      },
    );

    testWidgets(
      'given CategoryAddScreen with second color being selected '
      'when forth color gets selected '
      'then that color is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(color: Colors.primaries[1].toARGB32()),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.selectColorAt(3);

        robot.verifyColor(3, isSelected: true);
      },
    );

    testWidgets(
      'given CategoryAddScreen with second color being selected '
      'when deselect color is pressed '
      'then no color should be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(color: Colors.primaries[1].toARGB32()),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.deselectColor();

        robot.verfiyNoColorIsSelected();
      },
    );

    testWidgets(
      'given CategoryAddScreen '
      'when add color is pressed '
      'then the result color is expected to be added and selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.addCustomColor(customColor);

        robot.verifyCustomColor(customColor.id, isSelected: true);
      },
    );

    testWidgets(
      'given CategoryAddScreen with second color being selected '
      'when add color is pressed '
      'then the result color is expected to be added and selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc(
          CategoryAddScreenState.init(color: Colors.primaries[1].toARGB32()),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.addCustomColor(customColor);

        robot.verifyCustomColor(customColor.id, isSelected: true);
      },
    );

    testWidgets(
      'given CategoryAddScreen '
      'when a custom color gets selected '
      'then that custom color is expected to be selected',
      (tester) async {
        final robot = CategoryAddRobot(tester);
        final bloc = CategoryAddScreenBloc();
        final customColorId = await locator
            .get<CustomColorDatasource>()
            .addCustomColor(customColor.color);

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await robot.selectCustomColor(customColorId);

        robot.verifyCustomColor(customColorId, isSelected: true);
      },
    );

    testWidgets(
      'given CategoryAddScreen '
      'when a custom color gets deleted '
      'then that custom color is expected to be deleted',
      (tester) async {
        const statesTimeout = Duration(seconds: 2);
        tester.printToConsole('test started');
        final robot = CategoryAddRobot(tester);
        final bloc = MockCategoryAddScreenBloc();

        bloc.emitOnAny<CategoryAddScreenCustomColorsLoadRequested>(
          (current) => [
            current.copyWith(
              customColorsState: SubState.success([customColor]),
            ),
          ],
        );

        bloc.emitStreamWhen<CategoryAddScreenCustomColorDeleteRequested>(
          (event) => event.value == customColor.id,
          (state) => Stream.fromFutures([
            state
                .copyWith(
                  customColorDeleteState: [
                    ListableDeleteState.inProgress(item: customColor.id),
                  ],
                )
                .immediate,
            state
                .copyWith(
                  customColorDeleteState: [
                    ListableDeleteState.success(item: customColor.id),
                  ],
                  customColorsState: SubState.success([]),
                )
                .wait(const Duration(seconds: 2)),
          ]),
        );

        tester.printToConsole('pumping widget');
        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<ImageRepository>.value(
              value: locator.get(),
              child: BlocProvider<CategoryAddScreenBloc>.value(
                value: bloc,
                child: const CategoryAddScreen(),
              ),
            ),
          ),
        );

        final futureLoadingState = bloc.stream.firstWhere(
          (e) => e.customColorDeleteState.isInProgress(customColor.id),
        );

        final futureDeleteState = bloc.stream.firstWhere(
          (e) => e.customColorDeleteState.isSuccess(customColor.id),
        );

        await tester.pumpAndSettle();

        await robot.deleteCustomColor(customColor.id);
        await tester.pump();

        await futureLoadingState.timeout(statesTimeout);
        await tester.pump();
        robot.verifyCustomColorIsLoading(customColor.id);

        await tester.pump(const Duration(seconds: 2));
        await futureDeleteState.timeout(statesTimeout);
        await tester.pump();
        robot.varifyCustomColorDoesNotExists(customColor.id);
      },
    );
  });
}
