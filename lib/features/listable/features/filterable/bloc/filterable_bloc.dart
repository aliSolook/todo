import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/features/listable/listable.dart';

part 'filterable_state.dart';

mixin FilterableBloc<T, S extends FilterableState<T>> on ListableBloc<T, S> {
  @override
  @protected
  List<T> manipulateItems(List<T> itemsToManipulate, S newState) {
    if (newState.filterTest != null) {
      itemsToManipulate.removeWhere((e) => !newState.filterTest!(e, newState));
    }
    return super.manipulateItems(itemsToManipulate, newState);
  }
}
