import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';

import '../../../test/test_utils/test_utils.dart';

void main() {
  late MockCategoryRepository categoryRepo;
  late MockCustomColorRepository customColorRepo;
  late final ImageWrapper image1;
  late final ImageWrapper image2;
  const customColor1 = CustomColorWrapper(3, 0xFF00FFFF);
  const customColor2 = CustomColorWrapper(4, 0xFFFF0000);

  setUpAll(() async {
    await initImage(mock: true, count: 0);
    image1 = await addImage('assets/images/shopping.png');
    image2 = await addImage('assets/images/study.png');
    locator.registerSingleton<CategoryRepository>(
      categoryRepo = MockCategoryRepository(),
    );
    locator.registerSingleton<CustomColorRepository>(
      customColorRepo = MockCustomColorRepository(),
    );
  });

  tearDown(() async {
    reset(categoryRepo);
    reset(customColorRepo);
    resetMockitoState();
  });

  tearDownAll(() async {
    await locator.reset();
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  testWidgets('category_add_screen end-to-end add test', (tester) async {
    CategoryWrapper? result;
    final CategoryWrapper category = CategoryWrapper(
      id: 0,
      title: 'this is a title test',
      image: image1.id,
      color: customColor1.color,
    );

    provideDummy<Either<String, dynamic>>(const Right(null));
    when(
      categoryRepo.addCategory(category.toCategory()),
    ).thenAnswer((_) async => Right(category.id));

    provideDummy<Either<String, List<CustomColorWrapper>>>(const Right([]));
    when(
      customColorRepo.listCustomColors(),
    ).thenAnswer((_) async => const Right([customColor2]));

    provideDummy<Either<String, String>>(const Right(''));
    when(
      customColorRepo.deleteCustomColor(customColor2.id),
    ).thenAnswer((_) async => const Right('delete successfully'));

    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    runApp(
      MaterialApp(
        home: PopScope(
          onPopInvokedWithResult: (didPop, popResult) =>
              didPop && popResult is CategoryWrapper
              ? result = popResult
              : null,
          child: RepositoryProvider<ImageRepository>(
            create: (_) => locator.get(),
            child: BlocProvider(
              create: (_) => CategoryAddScreenBloc(),
              child: const CategoryAddScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    verify(customColorRepo.listCustomColors()).called(1);

    final robot = CategoryAddRobot(tester);
    await robot.entertTitle(category.title);

    await robot.selectImage(image1);
    robot.verifyImage(image1);

    await robot.deleteCustomColor(customColor2.id);
    verify(customColorRepo.deleteCustomColor(customColor2.id)).called(1);

    await robot.addCustomColor(customColor1);
    robot.verifyAddCustomColor(customColor1);
    robot.verifyCustomColor(customColor1.id, isSelected: true);

    await robot.submit();
    verify(categoryRepo.addCategory(category.toCategory())).called(1);
    expect(result, category);
  });

  testWidgets('category_add_screen end-to-end edit test', (tester) async {
    CategoryWrapper? actualResult;
    final source = CategoryWrapper(
      id: 0,
      title: 'this is a title test',
      image: image1.id,
      color: customColor1.color,
    );

    final result = CategoryWrapper(
      id: 0,
      title: 'this is the altered title',
      image: image2.id,
      color: customColor2.color,
    );

    provideDummy<Either<String, String>>(const Right(''));
    when(
      categoryRepo.updateCategory(result),
    ).thenAnswer((_) async => const Right('updated successfully'));

    provideDummy<Either<String, List<CustomColorWrapper>>>(const Right([]));
    when(
      customColorRepo.listCustomColors(),
    ).thenAnswer((_) async => const Right([customColor1]));

    when(
      customColorRepo.deleteCustomColor(customColor1.id),
    ).thenAnswer((_) async => const Right('delete successfully'));

    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    runApp(
      MaterialApp(
        home: PopScope(
          onPopInvokedWithResult: (didPop, popResult) =>
              didPop && popResult is CategoryWrapper
              ? actualResult = popResult
              : null,
          child: RepositoryProvider<ImageRepository>(
            create: (_) => locator.get(),
            child: BlocProvider(
              create: (_) => CategoryAddScreenBloc(
                CategoryAddScreenState.fromCategory(source),
              ),
              child: const CategoryAddScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    verify(customColorRepo.listCustomColors()).called(1);

    final robot = CategoryAddRobot(tester);
    await robot.entertTitle(result.title);

    await robot.selectImage(image2);
    robot.verifyImage(image2);

    await robot.deleteCustomColor(customColor1.id);
    verify(customColorRepo.deleteCustomColor(customColor1.id)).called(1);

    await robot.addCustomColor(customColor2);
    robot.verifyAddCustomColor(customColor2);
    robot.verifyCustomColor(customColor2.id, isSelected: true);

    await robot.submit();
    verify(categoryRepo.updateCategory(result)).called(1);
    expect(actualResult, result);
  });
}
