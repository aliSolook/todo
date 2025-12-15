part of 'listable_bloc.dart';

abstract class ListableState<T> extends Equatable {
  final List<T> sourceItems;
  final List<T> manipulatedItems;
  final StateStatus? status;
  final List<ListableDeleteState<T>> deleteState;
  final String? error;

  ListableState({
    List<T>? sourceItems,
    List<T>? manipulatedItems,
    this.status,
    List<ListableDeleteState<T>>? deleteState,
    this.error,
  }) : sourceItems = sourceItems ?? [],
       manipulatedItems = manipulatedItems ?? [],
       deleteState = deleteState ?? [];

  @protected
  ListableState<T> copyWith({
    List<T>? sourceItems,
    List<T>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<T>>? deleteState,
    Either<Null, String?> error = const Left(null),
  });

  @override
  List<Object?> get props => [
    sourceItems,
    status,
    error,
    deleteState,
    manipulatedItems,
  ];
}

final class ListableDeleteState<T> extends Equatable {
  final T item;
  final String? message;
  final StateStatus status;

  const ListableDeleteState({
    required this.status,
    required this.item,
    this.message,
  });

  const ListableDeleteState.inProgress({
    required this.item,
    this.message,
  }) : status = StateStatus.inProgress;

  const ListableDeleteState.failure({
    required this.item,
    this.message,
  }) : status = StateStatus.failure;

  const ListableDeleteState.success({
    required this.item,
    this.message,
  }) : status = StateStatus.success;

  ListableDeleteState copyWith({
    StateStatus? status,
    Either<Null, T> item = const Left(null),
    Either<Null, String?> message = const Left(null),
  }) => ListableDeleteState(
    item: item.getOrElse(() => this.item),
    message: message.getOrElse(() => this.message),
    status: status ?? this.status,
  );

  bool get isInProgress => status == StateStatus.inProgress;
  bool get isFailure => status == StateStatus.failure;
  bool get isSuccess => status == StateStatus.success;

  @override
  List<Object?> get props => [status, item];
}
