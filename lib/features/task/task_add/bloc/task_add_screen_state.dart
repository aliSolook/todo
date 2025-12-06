part of 'task_add_screen_bloc.dart';

final class TaskAddScreenState extends Equatable {
  final dynamic id;
  final String title;
  final String description;
  final Duration duration;
  final Jalali startingDate;
  final dynamic category;
  final dynamic image;

  final String titleError;
  final String durationError;
  final String categoryError;

  final SubState<List<CategoryWrapper>> categoriesState;

  final SubState<TaskWrapper> submitState;

  const TaskAddScreenState({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.startingDate,
    required this.category,
    required this.image,
    required this.titleError,
    required this.durationError,
    required this.categoryError,
    required this.categoriesState,
    required this.submitState,
  });

  TaskAddScreenState.init({
    this.id,
    this.title = '',
    this.description = '',
    this.duration = TaskAddScreenBloc.initDuration,
    Jalali? startingDate,
    this.category,
    this.image,
    this.titleError = '',
    this.durationError = '',
    this.categoryError = '',
    this.categoriesState = const SubState.init(),
    this.submitState = const SubState.init(),
  }) : startingDate = startingDate ?? Jalali.now();

  TaskAddScreenState.fromTask(
    TaskWrapper task, {
    this.titleError = '',
    this.durationError = '',
    this.categoryError = '',
    this.submitState = const SubState.init(),
    this.categoriesState = const SubState.init(),
  }) : id = task.id,
       title = task.title,
       description = task.description,
       duration = task.duration,
       startingDate = task.startingDate,
       category = task.category,
       image = task.image;

  TaskAddScreenState copyWith({
    Either<Null, dynamic> id = const Left(null),
    String? title,
    String? description,
    Duration? duration,
    Jalali? startingDate,
    Either<Null, dynamic> category = const Left(null),
    Either<Null, dynamic> image = const Left(null),
    String? titleError,
    String? durationError,
    String? categoryError,
    SubState<List<CategoryWrapper>>? categoriesState,
    SubState<TaskWrapper>? submitState,
  }) => TaskAddScreenState(
    id: id.getOrElse(() => this.id),
    title: title ?? this.title,
    description: description ?? this.description,
    duration: duration ?? this.duration,
    startingDate: startingDate ?? this.startingDate,
    category: category.getOrElse(() => this.category),
    image: image.getOrElse(() => this.image),
    titleError: titleError ?? this.titleError,
    durationError: durationError ?? this.durationError,
    categoryError: categoryError ?? this.categoryError,
    categoriesState: categoriesState ?? this.categoriesState,
    submitState: submitState ?? this.submitState,
  );

  bool get isEditing => id != null;

  bool get isReadyForSubmition =>
      title.isNotEmpty && duration > Duration.zero && category != null;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    duration,
    startingDate,
    category,
    image,
    titleError,
    durationError,
    categoryError,
    categoriesState,
    submitState,
  ];
}
