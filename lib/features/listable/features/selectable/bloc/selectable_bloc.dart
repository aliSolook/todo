import 'dart:async';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/listable/listable.dart';

part 'selectable_state.dart';
part 'selectable_event.dart';

mixin SelectableBloc<T, S extends SelectableState<T>> on ListableBloc<T, S> {
  bool _isInProgress = false;

  @override
  @protected
  void initiate() {
    super.initiate();
    on<SelectableItemToggled<T>>(itemToggled);
    on<SelectableClearSelectionPressed>(clearSelection);
    on<SelectableDeleteSelectedPressed>(deleteSelected);
  }

  @override
  @protected
  void deletePressed(ListableDeletePressed<T> event, Emitter<S> emit) {
    if (_isInProgress && state.selectedItems.contains(event.item)) return;

    final newEmitter = EmitterMiddleware<S>(
      emit,
      (newState) =>
          newState.copyWith(
                selectedItems: newState.selectedItems
                    .where((element) => !sameItem(element, event.item))
                    .toList(),
              )
              as S,
    );

    return super.deletePressed(event, newEmitter);
  }

  @override
  List<T> manipulateItems(List<T> itemsToManipulate, newState) {
    super.manipulateItems(itemsToManipulate, newState);
    final selectedItems = List.of(state.selectedItems);
    for (var i = 0; i < selectedItems.length; i++) {
      final index = itemsToManipulate.indexWhere(
        (b) => sameItem(selectedItems[i], b),
      );

      if (index < 0) {
        // poping this element and prevent the loop from going forward
        selectedItems.removeAt(i--);
        continue;
      }

      // updating the selectedItems
      selectedItems[i] = itemsToManipulate[index];
    }
    return itemsToManipulate;
  }

  @protected
  void itemToggled(SelectableItemToggled<T> event, Emitter<S> emit) {
    if (_isInProgress) return;

    List<T> addItem() {
      if (!state.sourceItems.contains(event.item)) return state.selectedItems;
      return state.selectedItems.followedBy([event.item]).toList();
    }

    final exists = state.selectedItems.contains(event.item);

    final selectedItems = exists
        ? state.selectedItems.where((e) => !sameItem(e, event.item)).toList()
        : addItem();

    emit(state.copyWith(selectedItems: selectedItems) as S);
  }

  @protected
  void clearSelection(SelectableClearSelectionPressed event, Emitter<S> emit) {
    if (_isInProgress) return;
    emit(state.copyWith(selectedItems: []) as S);
  }

  @protected
  void deleteSelected(
    SelectableDeleteSelectedPressed event,
    Emitter<S> emit,
  ) async {
    if (state.selectedItems.isEmpty || _isInProgress) return;
    _isInProgress = true;

    emit(
      state.copyWith(
            deleteState: state.deleteState.copyUpdateAll(
              state.selectedItems.map(
                (e) => ListableDeleteState(
                  status: StateStatus.inProgress,
                  item: e,
                ),
              ),
            ),
          )
          as S,
    );

    final List<Future<({T item, Either<String, String> result})>> futures = [];

    for (var item in state.selectedItems) {
      futures.add(deleteItem(item).then((r) => (item: item, result: r)));
    }

    final results = await Future.wait(futures);

    final List<T> failures = [];
    final List<T> successes = [];

    final resultsMerged = results.map(
      (e) {
        return e.result.fold(
          ifLeft: (value) {
            failures.add(e.item);
            return ListableDeleteState(
              status: StateStatus.failure,
              message: value,
              item: e.item,
            );
          },
          ifRight: (_) {
            successes.add(e.item);
            return ListableDeleteState(
              status: StateStatus.success,
              item: e.item,
            );
          },
        );
      },
    ).toList();

    final items = state.sourceItems
        .where((e) => !successes.contains(e))
        .toList();
    final selectedItems = state.selectedItems
        .where((e) => !successes.contains(e))
        .toList();

    final newState =
        state.copyWith(
              selectedItems: selectedItems,
              sourceItems: items,
              deleteState: state.deleteState.copyUpdateAll(resultsMerged),
            )
            as S;

    successes.isEmpty ? emit(newState) : emitAndManipulate(newState, emit);

    emit(
      state.copyWith(
            deleteState: state.deleteState
                .where((e) => e.isInProgress)
                .toList(),
          )
          as S,
    );

    _isInProgress = false;
    // emit(
    //   state.copyWith(
    //         selectedItems: selectedItems,
    //         items: items,
    //         deleteSelectedState: Right(
    //           DeleteSelectedResultState<T>(
    //             successes: successes,
    //             failures: failures,
    //           ),
    //         ),
    //       )
    //       as S,
    // );
  }
}
