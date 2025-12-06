part of 'home_bloc.dart';

abstract class _UnifiedBase extends ListableState<TaskWrapper>
    implements
        SearchableBaseState<TaskWrapper, TaskSearchField>,
        SelectableBaseState<TaskWrapper>,
        AlertableBaseState<TaskWrapper, String> {
  _UnifiedBase({
    super.deleteState,
    super.error,
    super.manipulatedItems,
    super.sourceItems,
    super.status,
  });

  _UnifiedBase copyWith({
    List<TaskWrapper>? sourceItems,
    List<TaskWrapper>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<TaskWrapper>>? deleteState,
    Either<Null, String?> error = const Left(null),
    Set<TaskSearchField>? searchFields,
    String? searchText,
    List<TaskWrapper>? selectedItems,
    Either<Null, Alert<String>?> alert = const Left(null),
  });
}

final class HomeState extends _UnifiedBase
    with
        SearchableState<TaskWrapper, TaskSearchField>,
        SelectableState<TaskWrapper>,
        AlertableState<TaskWrapper, String> {
  HomeState({
    super.deleteState,
    super.error,
    super.manipulatedItems,
    super.sourceItems,
    super.status,
    this.searchFields = const {TaskSearchField.title},
    this.searchText = '',
    this.toggleState = const [],
    this.selectedItems = const [],
    this.alert,
    this.categoriesState = const SubState.init(),
    Jalali? today,
  }) : today = today ?? Jalali.now().withoutTime;

  @override
  HomeState copyWith({
    List<TaskWrapper>? sourceItems,
    List<TaskWrapper>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<TaskWrapper>>? deleteState,
    Either<Null, String?> error = const Left(null),
    Set<TaskSearchField>? searchFields,
    String? searchText,
    List? toggleState,
    List<TaskWrapper>? selectedItems,
    Either<Null, Alert<String>?> alert = const Left(null),
    Jalali? today,
    SubState<List<CategoryWrapper>>? categoriesState,
  }) => HomeState(
    deleteState: deleteState ?? this.deleteState,
    error: error.getOrElse(() => this.error),
    manipulatedItems: manipulatedItems ?? this.manipulatedItems,
    searchFields: searchFields ?? this.searchFields,
    searchText: searchText ?? this.searchText,
    selectedItems: selectedItems ?? this.selectedItems,
    sourceItems: sourceItems ?? this.sourceItems,
    status: status.getOrElse(() => this.status),
    toggleState: toggleState ?? this.toggleState,
    alert: alert.getOrElse(() => this.alert),
    today: today ?? this.today,
    categoriesState: categoriesState ?? this.categoriesState,
  );

  @override
  final Set<TaskSearchField> searchFields;
  @override
  final String searchText;
  @override
  final List<TaskWrapper> selectedItems;
  @override
  final Alert<String>? alert;

  final List<dynamic> toggleState;
  final SubState<List<CategoryWrapper>> categoriesState;
  final Jalali today;

  @override
  List<Object?> get props => [...super.props, toggleState, today, categoriesState];
}
