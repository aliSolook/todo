import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';

Future<CategoryWrapper?> showCategoryAdd(
  BuildContext context, [
  CategoryWrapper? task,
]) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RepositoryProvider<ImageRepository>(
        create: (context) => locator.get(),
        child: BlocProvider(
          create: (context) => CategoryAddScreenBloc(
            task == null
                ? const CategoryAddScreenState.init()
                : CategoryAddScreenState.fromCategory(task),
          ),
          child: const CategoryAddScreen(),
        ),
      ),
    ),
  );

  return result is CategoryWrapper ? result : null;
}
