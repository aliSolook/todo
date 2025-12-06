import 'dart:async';
import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/listable/listable.dart';

export 'package:todo/features/models/models.dart';

part 'listable_state.dart';
part 'listable_event.dart';

abstract class ListableBloc<T, S extends ListableState<T>>
    extends Bloc<ListableEvent, S> {
  ListableBloc(super.initialState) {
    initiate();
  }

  @protected
  @mustCallSuper
  void initiate() {
    on<ListableDeletePressed<T>>(deletePressed);
    on<ListableEditingFinished<T>>(editingFinished);
    on<ListableItemAdded<T>>(itemAdded);
    on<ListableLoadRequested>(loadRequested);
  }

  @protected
  Future<Either<String, List<T>>> loadData();

  @protected
  Future<Either<String, String>> deleteItem(T item);

  bool sameItem(T? a, T? b);

  @mustCallSuper
  @protected
  List<T> manipulateItems(List<T> itemsToManipulate, S newState) {
    // if (itemsToManipulate is UnmodifiableListView) {
    //   throw Exception(
    //     '[itemsToManipulate] can not be an [UnmodifiableListView]',
    //   );
    // }

    // if (event is ListableDeletePressed<T>) {
    //   itemsToManipulate.removeWhere((e) => sameItem(e, event.item));
    // } else if (event is ListableEditingFinished<T>) {
    //   final index = itemsToManipulate.indexWhere(
    //     (e) => sameItem(e, event.item),
    //   );
    //   if (index >= 0) itemsToManipulate[index] = event.item;
    // } else if (event is ListableItemAdded<T>) {
    //   itemsToManipulate.add(event.item);
    // }

    return itemsToManipulate;
  }

  @protected
  FutureOr<void> loadRequested(
    ListableLoadRequested event,
    Emitter<S> emit, [
    List<T> Function(List<T> source, List<T> manipulated)? sourceMiddleware,
  ]) async => loadAndEmit(emit, sourceMiddleware);

  @protected
  FutureOr<void> loadAndEmit(
    Emitter<S> emit, [
    List<T> Function(List<T> source, List<T> manipulated)? sourceMiddleware,
  ]) async {
    if (state.status?.isInProgress ?? false) return;

    emit(state.copyWith(status: const Right(StateStatus.inProgress)) as S);

    return (await loadData()).fold(
      ifLeft: (value) {
        emit(
          state.copyWith(
                status: const Right(StateStatus.failure),
                error: Right(value),
              )
              as S,
        );
      },
      ifRight: (value) {
        emitAndManipulate(
          state.copyWith(
                sourceItems:
                    sourceMiddleware?.call(value, List.of(value)) ?? value,
                status: const Right(StateStatus.success),
              )
              as S,
          emit,
        );
      },
    );
  }

  @protected
  void deletePressed(
    ListableDeletePressed<T> event,
    Emitter<S> emit,
  ) async {
    // if (state.selectedCounters.contains(event.counter)) {
    //   final selectedCounters = state.selectedCounters
    //       .where((e) => !sameItem(e, event.counter))
    //       .toList();
    //   emit(state.copyWith(selectedCounters: selectedCounters));
    // }
    emit(
      state.copyWith(
            deleteState: state.deleteState.copyAdd(
              ListableDeleteState(
                status: StateStatus.inProgress,
                item: event.item,
              ),
            ),
          )
          as S,
    );

    (await deleteItem(event.item)).fold(
      ifLeft: (value) {
        emit(
          state.copyWith(
                deleteState: state.deleteState.copyUpdate(
                  ListableDeleteState<T>(
                    status: StateStatus.failure,
                    item: event.item,
                    message: value,
                  ),
                ),
              )
              as S,
        );
      },
      ifRight: (value) {
        emitAndManipulate(
          state.copyWith(
                sourceItems: state.sourceItems
                    .where((e) => !sameItem(e, event.item))
                    .toList(),
                deleteState: state.deleteState.copyUpdate(
                  ListableDeleteState<T>(
                    status: StateStatus.success,
                    item: event.item,
                  ),
                ),
              )
              as S,
          emit,
        );
      },
    );

    emit(
      state.copyWith(
            deleteState: state.deleteState
                .where((e) => e.isInProgress)
                .toList(),
          )
          as S,
    );
  }

  @protected
  void editingFinished(
    ListableEditingFinished<T> event,
    Emitter<S> emit,
  ) {
    final index = state.sourceItems.indexWhere(
      (element) => sameItem(element, event.item),
    );
    final items = List.of(state.sourceItems);
    items[index] = event.item;

    emitAndManipulate(state.copyWith(sourceItems: items) as S, emit);
  }

  @protected
  FutureOr<void> itemAdded(ListableItemAdded<T> event, Emitter<S> emit) {
    final items = state.sourceItems.followedBy([event.item]).toList();
    emitAndManipulate(state.copyWith(sourceItems: items) as S, emit);
  }

  void emitAndManipulate(S state, Emitter<S> emit) {
    emit(
      state.copyWith(
            manipulatedItems: manipulateItems(
              List.of(state.sourceItems),
              state,
            ),
          )
          as S,
    );
  }
}
