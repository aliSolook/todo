import 'dart:async';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sortable_state.dart';
part 'sortable_event.dart';

typedef SortableListOfOrderItems<O extends Object> = List<OrderItem<O>>;

mixin SortableBloc<T, O extends Object, S extends SortableState<T, O>>
    on ListableBloc<T, S> {
  Comparable getSortField(O order, T item);

  // /// the order that if all items where compared using this, none of them would be equal to one another
  // O? get uniqueOrder;

  @override
  @protected
  void initiate() {
    super.initiate();

    on<SortableOrderChanged<O>>(orderChanged);
  }

  @override
  @protected
  List<T> manipulateItems(List<T> itemsToManipulate, S newState) {
    super.manipulateItems(itemsToManipulate, newState);

    sort(itemsToSort: itemsToManipulate, order: newState.order);
    return itemsToManipulate;
  }

  @protected
  FutureOr<void> orderChanged(
    SortableOrderChanged<O> event,
    Emitter<S> emit,
  ) {
    final order = event.order.isEmpty ? [state.order.first.toAsc] : event.order;

    emitAndManipulate(state.copyWith(order: order) as S, emit);
  }

  @protected
  void sort({
    required List<T> itemsToSort,
    SortableListOfOrderItems<O>? order,
  }) {
    // SortableListOfOrderItems<O> getUntilUnique(
    //   SortableListOfOrderItems<O> order,
    // ) {
    //   final unique = uniqueOrder;
    //   final index = order.indexWhere((e) => e.value == unique);
    //   return order.sublist(0, index.isNegative ? null : index + 1);
    // }

    int sortComparator(T a, T b) {
      if (a == b) return 0;

      for (var e in order!) {
        final result = compare(a, b, e.value, e.isAsc);

        if (result != 0) return result;
      }

      return 0;
    }

    order ??= state.order;
    itemsToSort.sort(sortComparator);
  }

  @protected
  int compare(T a, T b, O order, bool isAscending) {
    if (a == b) return 0;

    final result = getSortField(
      order,
      a,
    ).compareTo(getSortField(order, b));

    return result * (isAscending ? 1 : -1);
  }
}
