// ignore_for_file: library_private_types_in_public_api

part of 'counter_list_bloc.dart';

enum CounterOrder<T extends Comparable> {
  created<int>('زمان ایجاد'),
  title<String>('عنوان'),
  duration<Duration>('زمان'),
  description<String>('توضیحات');

  final String text;
  const CounterOrder(this.text);

  bool get isCreated => this == CounterOrder.created;
  bool get isTitle => this == CounterOrder.title;
  bool get isDuration => this == CounterOrder.duration;
  bool get isDescription => this == CounterOrder.description;

  T getField(CounterWrapper counter) => switch (this) {
    CounterOrder.created => 0 as T,
    CounterOrder.title => counter.title as T,
    CounterOrder.duration => counter.duration as T,
    CounterOrder.description => counter.description as T,
  };
}

enum CounterSearchField {
  title('عنوان'),
  duration('زمان'),
  description('توضیحات');

  final String text;
  const CounterSearchField(this.text);

  bool get isTitle => this == CounterSearchField.title;
  bool get isDuration => this == CounterSearchField.duration;
  bool get isDescription => this == CounterSearchField.description;

  String getField(CounterWrapper counter) => switch (this) {
    CounterSearchField.title => counter.title,
    CounterSearchField.duration => durationFormatter(
      counter.duration,
      hours: counter.duration.inHours > 0,
    ),
    CounterSearchField.description => counter.description,
  };
}

abstract class _UnifiedBases extends ListableState<CounterWrapper>
    implements
        SortableBaseState<CounterWrapper, CounterOrder>,
        SearchableBaseState<CounterWrapper, CounterSearchField>,
        SelectableBaseState<CounterWrapper> {
  _UnifiedBases({
    super.sourceItems,
    super.status,
    super.manipulatedItems,
    super.deleteState,
    super.error,
  });

  @override
  _UnifiedBases copyWith({
    List<CounterWrapper>? sourceItems,
    List<CounterWrapper>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<CounterWrapper>>? deleteState,
    Either<Null, String?> error = const Left(null),
    List<CounterWrapper>? sortedItems,
    SortableListOfOrderItems<CounterOrder>? order,
    Set<CounterSearchField>? searchFields,
    List<CounterWrapper>? searchedItems,
    String? searchText,
    List<CounterWrapper>? selectedItems,
  });
}

final class CounterListState extends _UnifiedBases
    with
        SortableState<CounterWrapper, CounterOrder>,
        SearchableState<CounterWrapper, CounterSearchField>,
        SelectableState<CounterWrapper> {
  @override
  final String searchText;
  @override
  final Set<CounterSearchField> searchFields;
  @override
  final CounterListOrderItems order;
  @override
  final List<CounterWrapper> selectedItems;

  CounterListState({
    this.searchText = '',
    this.order = const [OrderItem.asc(CounterOrder.created)],
    this.searchFields = const {CounterSearchField.title},
    this.selectedItems = const [],
    super.deleteState,
    super.error,
    super.sourceItems,
    super.manipulatedItems,
    super.status,
  });

  @override
  CounterListState copyWith({
    List<CounterWrapper>? sourceItems,
    List<CounterWrapper>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<CounterWrapper>>? deleteState,
    Either<Null, String?> error = const Left(null),
    List<CounterWrapper>? sortedItems,
    SortableListOfOrderItems<CounterOrder<Comparable>>? order,
    Set<CounterSearchField>? searchFields,
    List<CounterWrapper>? searchedItems,
    String? searchText,
    List<CounterWrapper>? selectedItems,
  }) => CounterListState(
    searchText: searchText ?? this.searchText,
    order: order ?? this.order,
    searchFields: searchFields ?? this.searchFields,
    selectedItems: selectedItems ?? this.selectedItems,
    deleteState: deleteState ?? this.deleteState,
    error: error.getOrElse(() => this.error),
    sourceItems: sourceItems ?? this.sourceItems,
    manipulatedItems: manipulatedItems ?? this.manipulatedItems,
    status: status.getOrElse(() => this.status),
  );

  // @override
  // List<Object?> get props => [...super.props];
}

// final class CounterStateType extends Equatable {
//   const CounterStateType();
//   @override
//   List<Object?> get props => [];
// }

// base mixin CounterErrorMixin on CounterStateType {
//   String get message;

//   @override
//   List<Object?> get props => [...super.props, message];
// }

// base mixin WithCounterTypeMixin on CounterStateType {
//   CounterWrapper get counter;

//   @override
//   List<Object?> get props => [...super.props, counter];
// }

// sealed class _WithCounterStateImpl extends CounterStateType {
//   final CounterWrapper counter;

//   const _WithCounterStateImpl(this.counter);
// }

// sealed class _ErrorImpl extends CounterStateType {
//   final String message;

//   const _ErrorImpl(this.message);
// }

// sealed class _ErrorWithCounterImpl extends CounterStateType {
//   final CounterWrapper counter;
//   final String message;

//   const _ErrorWithCounterImpl({required this.message, required this.counter});
// }

// final class CounterInitType extends CounterStateType {
//   const CounterInitType();
// }

// final class CounterLoadInProgressType extends CounterStateType {
//   const CounterLoadInProgressType();
// }

// final class CounterLoadSuccessType extends CounterStateType {
//   const CounterLoadSuccessType();
// }

// final class CounterLoadFailureType = _ErrorImpl with CounterErrorMixin;

// final class CounterUpdatedCounterType = _WithCounterStateImpl
//     with WithCounterTypeMixin;

// final class CounterDeleteInProgressType = _WithCounterStateImpl
//     with WithCounterTypeMixin;

// final class CounterDeleteCanceledType = _WithCounterStateImpl
//     with WithCounterTypeMixin;

// final class CounterDeleteFailureType = _ErrorWithCounterImpl
//     with WithCounterTypeMixin, CounterErrorMixin;

// final class CounterDeleteSuccessType = _WithCounterStateImpl
//     with WithCounterTypeMixin;

// final class CounterPopType = _WithCounterStateImpl with WithCounterTypeMixin;

// final class CounterSelectionDeleteInProgressType extends CounterStateType {
//   const CounterSelectionDeleteInProgressType();
// }

// final class CounterSelectionDeleteResultType extends CounterStateType {
//   final List<CounterWrapper> successes;
//   final List<CounterWrapper> failures;
//   const CounterSelectionDeleteResultType({
//     required this.successes,
//     required this.failures,
//   });

//   @override
//   List<Object?> get props => [...super.props, successes, failures];
// }
