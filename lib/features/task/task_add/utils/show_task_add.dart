import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/task/task.dart';

Future<TaskWrapper?> showTaskAdd(
  BuildContext context, [
  TaskWrapper? task,
]) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RepositoryProvider<ImageRepository>(
        create: (context) => locator.get(),
        child: BlocProvider(
          create: (context) => TaskAddScreenBloc(
            task == null
                ? TaskAddScreenState.init()
                : TaskAddScreenState.fromTask(task),
          ),
          child: const TaskAddScreen(),
        ),
      ),
    ),
  );

  return result is TaskWrapper ? result : null;
}
