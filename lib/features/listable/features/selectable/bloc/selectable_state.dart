part of 'selectable_bloc.dart';

abstract class SelectableBaseState<T> extends ListableState<T> {
  @override
  SelectableBaseState<T> copyWith({
    List<T>? sourceItems,
    List<T>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<T>>? deleteState,
    Either<Null, String?> error = const Left(null),
    List<T>? selectedItems,
  });
}

mixin SelectableState<T> on SelectableBaseState<T> {
  List<T> get selectedItems;

  @override
  List<Object?> get props => [...super.props, selectedItems];
}

// sealed class DeleteSelectedState<T> extends Equatable {
//   const DeleteSelectedState();
// }

// final class DeleteSelectedInProgressState<T> extends DeleteSelectedState<T> {
//   final List<T> items;
//   const DeleteSelectedInProgressState(this.items);

//   @override
//   List<Object?> get props => [items];
// }

// final class DeleteSelectedResultState<T> extends DeleteSelectedState<T> {
//   final List<T> failures;
//   final List<T> successes;

//   const DeleteSelectedResultState({
//     this.failures = const [],
//     this.successes = const [],
//   });

//   @override
//   List<Object?> get props => [failures, successes];
// }

// extension DeleteSelectedStateExtension<T> on DeleteSelectedState<T>? {
//   bool get isInProgress => this is DeleteSelectedInProgressState<T>;
//   bool get isResult => this is DeleteSelectedResultState<T>;

//   DeleteSelectedInProgressState<T> get asInProgress => cast();
//   DeleteSelectedResultState<T> get asResult => cast();

//   E cast<E>() => this as E;
// }
