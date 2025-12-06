import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/image/repository/image_repository.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/counter/counter.dart';

Future<CounterWrapper?> showCounterAdd(
  BuildContext context, [
  CounterWrapper? counter,
]) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RepositoryProvider<ImageRepository>(
        create: (context) => locator.get(),
        child: BlocProvider(
          create: (context) => CounterAddScreenBloc(
            CounterAddScreenState.fromCounter(counter),
          ),
          child: const CounterAddScreen(),
        ),
      ),
    ),
  );

  return result is CounterWrapper ? result : null;
}
