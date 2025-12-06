part of 'filterable_bloc.dart';

typedef FilterTest<T> = bool Function(T item, FilterableState state);

abstract class FilterableBaseState<T> extends ListableState<T> {
  @override
  FilterableBaseState<T> copyWith({
    List<T>? sourceItems,
    List<T>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<T>>? deleteState,
    Either<Null, String?> error = const Left(null),
    Either<Null, FilterTest<T>?> filterTest = const Left(null),
  });
}

mixin FilterableState<T> on FilterableBaseState<T> {
  FilterTest<T>? get filterTest;

  @override
  List<Object?> get props => [...super.props, filterTest];
}
