part of 'sortable_bloc.dart';

abstract class SortableBaseState<T, O extends Object> extends ListableState<T> {
  @override
  SortableBaseState<T, O> copyWith({
    List<T>? sourceItems,
    List<T>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<T>>? deleteState,
    Either<Null, String?> error = const Left(null),
    SortableListOfOrderItems<O>? order,
  });
}

mixin SortableState<T, O extends Object> on SortableBaseState<T, O> {
  SortableListOfOrderItems<O> get order;

  @override
  List<Object?> get props => [...super.props, order];
}
