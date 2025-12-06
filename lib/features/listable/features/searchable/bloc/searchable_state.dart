part of 'searchable_bloc.dart';

abstract class SearchableBaseState<T, F extends Object>
    extends ListableState<T> {
  @override
  SearchableBaseState<T, F> copyWith({
    List<T>? sourceItems,
    List<T>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<T>>? deleteState,
    Either<Null, String?> error = const Left(null),
    Set<F>? searchFields,
    String? searchText,
  });
}

mixin SearchableState<T, F extends Object> on SearchableBaseState<T, F> {
  Set<F> get searchFields;
  String get searchText;

  @override
  List<Object?> get props => [
    ...super.props,
    searchFields,
    searchText,
  ];
}
