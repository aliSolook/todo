part of 'task_list_bloc.dart';

abstract class _UnifiedBase extends ListableState<TaskWrapper>
    implements
        SelectableBaseState<TaskWrapper>,
        AlertableBaseState<TaskWrapper, String> {
  _UnifiedBase({
    super.deleteState,
    super.error,
    super.manipulatedItems,
    super.sourceItems,
    super.status,
  });

  @override
  _UnifiedBase copyWith({
    List<TaskWrapper>? sourceItems,
    List<TaskWrapper>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<TaskWrapper>>? deleteState,
    Either<Null, String?> error = const Left(null),
    List<TaskWrapper>? selectedItems,
    Either<Null, Alert<String>?> alert = const Left(null),
  });
}

base class TaskListState extends _UnifiedBase
    with SelectableState<TaskWrapper>, AlertableState<TaskWrapper, String> {
  TaskListState({
    super.deleteState,
    super.error,
    super.manipulatedItems,
    super.sourceItems,
    super.status,
    this.checked = const [],
    this.unChecked = const [],
    List<JalaliRange>? dateRange,
    this.toggleState = const [],
    this.selectedItems = const [],
    this.daysState = const SubState.init(),
    this.todayState = const SubState.init(),
    this.alert,
  }) : dateRange = dateRange ?? _getDefaultRange;

  static List<JalaliRange> get _getDefaultRange => [
    Jalali.now().withoutTime,
  ].map((e) => JalaliRange(start: e, end: e + 1)).toList();

  @override
  TaskListState copyWith({
    List<TaskWrapper>? sourceItems,
    List<TaskWrapper>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<TaskWrapper>>? deleteState,
    Either<Null, String?> error = const Left(null),
    List<TaskWrapper>? checked,
    List<TaskWrapper>? unChecked,
    List<JalaliRange>? dateRange,
    List<dynamic>? toggleState,
    List<TaskWrapper>? selectedItems,
    Either<Null, Alert<String>?> alert = const Left(null),
    SubState<Map<Jalali, bool>>? daysState,
    SubState<MapEntry<Jalali, int>>? todayState,
  }) => TaskListState(
    sourceItems: sourceItems ?? this.sourceItems,
    manipulatedItems: manipulatedItems ?? this.manipulatedItems,
    status: status.getOrElse(() => this.status),
    deleteState: deleteState ?? this.deleteState,
    error: error.getOrElse(() => this.error),
    checked: checked ?? this.checked,
    unChecked: unChecked ?? this.unChecked,
    dateRange: dateRange ?? this.dateRange,
    toggleState: toggleState ?? this.toggleState,
    selectedItems: selectedItems ?? this.selectedItems,
    daysState: daysState ?? this.daysState,
    todayState: todayState ?? this.todayState,
    alert: alert.getOrElse(() => this.alert),
  );

  @override
  final List<TaskWrapper> selectedItems;
  @override
  final Alert<String>? alert;
  final List<TaskWrapper> checked;
  final List<TaskWrapper> unChecked;
  final List<JalaliRange> dateRange;
  final List<dynamic> toggleState;
  final SubState<Map<Jalali, bool>> daysState;
  final SubState<MapEntry<Jalali, int>> todayState;

  @override
  List<Object?> get props => [
    ...super.props,
    checked,
    unChecked,
    dateRange,
    toggleState,
    daysState,
    todayState,
  ];
}

enum TaskSearchField {
  title,
  description;

  bool get isTitle => this == TaskSearchField.title;
  bool get isDescription => this == TaskSearchField.description;

  String getField(TaskWrapper task) => switch (this) {
    TaskSearchField.title => task.title,
    TaskSearchField.description => task.description,
  };
}
