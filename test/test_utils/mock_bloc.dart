import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

typedef EventMatcher<E> = bool Function(E event);
typedef StreamStateGenerator<S> = Stream<S> Function(S state);
typedef IterableStateGenerator<S> = Iterable<S> Function(S state);

abstract class MockBloc<Event, State> extends Bloc<Event, State> {
  MockBloc(super.initialState);

  final _handlers = <MapEntry<Event, StreamStateGenerator<State>>>[];
  final _whenHandlers = <_WhenHandler<Event, State>>[];

  bool? isSameEventAs(Event e, Event a) => null;

  void emitOnAny<E extends Event>(
    IterableStateGenerator<State> stateGenerator,
  ) => emitStreamOnAny<E>((c) => Stream.fromIterable(stateGenerator(c)));

  void emitStreamOnAny<E extends Event>(
    StreamStateGenerator<State> stateGenerator,
  ) => on<E>((_, emit) => stateGenerator(state).forEach(emit.call));

  void emitWhen<E extends Event>(
    EventMatcher<E> when,
    IterableStateGenerator<State> stateGenerator,
  ) => emitStreamWhen<E>(when, (c) => Stream.fromIterable(stateGenerator(c)));

  void emitStreamWhen<E extends Event>(
    EventMatcher<E> when,
    StreamStateGenerator<State> stateGenerator,
  ) {
    final typeIsUsed = _whenHandlers.any((e) => e.type == E);
    _whenHandlers.add(_WhenHandler<E, State>(stateGenerator, E, when));

    if (typeIsUsed) return;
    on<E>((event, emit) {
      final handlers = _whenHandlers.whereType<_WhenHandler<E, State>>();

      final states = handlers.firstWhere(
        (e) => e.matcher(event),
        orElse: () => fail('No matcher satisfied $event'),
      );

      return states.stateGenerator(state).forEach(emit.call);
    });
  }

  void emitOn<E extends Event>(
    E e,
    IterableStateGenerator<State> stateGenerator,
  ) => emitStreamOn<E>(e, (c) => Stream.fromIterable(stateGenerator(c)));

  void emitStreamOn<E extends Event>(
    E e,
    StreamStateGenerator<State> stateGenerator,
  ) {
    final events = _handlers.map((e) => e.key).whereType<E>().toList();

    if (events.any((a) => isSameEventAs(a, e) ?? a == e)) {
      throw StateError('emitStreamOn($e) was called multiple times');
    }
    _handlers.add(MapEntry(e, stateGenerator));

    if (events.isNotEmpty) return;
    on<E>((event, emit) async {
      final candidates = _handlers
          .whereType<MapEntry<E, StreamStateGenerator<State>>>()
          .toList();
      final states = candidates.firstWhere(
        (e) => isSameEventAs(e.key, event) ?? e.key == event,
        orElse: () =>
            fail(isIn(candidates).describe(StringDescription()).toString()),
      );

      return states.value(state).forEach(emit.call);
    });
  }
}

class _WhenHandler<Event, State> {
  final StreamStateGenerator<State> stateGenerator;
  final Type type;
  final EventMatcher<Event> matcher;

  _WhenHandler(this.stateGenerator, this.type, this.matcher);
}

extension DelayExtension<T> on T {
  Future<T> wait(Duration duration) => Future.delayed(duration, () => this);

  Future<T> get immediate => Future.value(this);
}
