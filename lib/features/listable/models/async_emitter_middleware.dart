import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef AsyncStateTransformer<State> = FutureOr<State> Function(State newState);

class AsyncEmitterMiddleware<State> implements Emitter<State> {
  final Emitter<State> _originalEmitter;
  final AsyncStateTransformer<State> _transformer;

  AsyncEmitterMiddleware(this._originalEmitter, this._transformer);

  @override
  FutureOr<void> call(State state) async {
    final transformedState = _transformer(state);

    return _originalEmitter(await transformedState);
  }

  @override
  bool get isDone => _originalEmitter.isDone;

  @override
  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T data) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  }) => onEach<T>(
    stream,
    onData: (data) => call(onData(data)),
    onError: onError != null
        ? (Object error, StackTrace stackTrace) {
            call(onError(error, stackTrace));
          }
        : null,
  );

  @override
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) => _originalEmitter.onEach(
    stream,
    onData: onData,
    onError: onError,
  );
}
