import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/models/models.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/task/task.dart';

part 'task_add_screen_event.dart';
part 'task_add_screen_state.dart';

final class TaskAddScreenBloc
    extends Bloc<TaskAddScreenEvent, TaskAddScreenState> {
  static const durationError = 'زمان انتخاب شده باید از \'0\' ثانیه بیشتر باشد';
  static const titleError = 'این فیلد اجباری است';
  static const categoryError = 'هیچ دسته بندی انتخاب نشده سات';
  static const initDuration = Duration(minutes: 15);

  final TaskRepository _taskRepository = locator.get();
  final CategoryRepository _categoryRepository = locator.get();

  TaskAddScreenBloc([TaskAddScreenState? initialState])
    : super(initialState ?? TaskAddScreenState.init()) {
    on<TaskAddScreenCategoriesLoadRequested>(_categoriesLoadRequested);
    on<TaskAddScreenTitleFocusChanged>(_titleFocusChanged);
    on<TaskAddScreenTitleChanged>(_titleChanged);
    on<TaskAddScreenDescriptionChanged>(_descriptionChanged);
    on<TaskAddScreenImageChanged>(_imageChanged);
    on<TaskAddScreenDurationFocusChanged>(_durationFocusChanged);
    on<TaskAddScreenDurationChanged>(_durationChanged);
    on<TaskAddScreenStartingDateChanged>(_startingDateChanged);
    on<TaskAddScreenCategoryChanged>(_categoryChanged);
    on<TaskAddScreenSubmitted>(_submitted);
    on<TaskAddScreenReset>(_reset);
  }

  void _categoriesLoadRequested(
    TaskAddScreenCategoriesLoadRequested event,
    Emitter emit,
  ) async {
    emit(state.copyWith(categoriesState: const SubState.inProgress()));

    final either = await _categoryRepository.listCategories();

    final newState = either.fold(
      ifLeft: (value) =>
          state.copyWith(categoriesState: SubState.failure(value)),
      ifRight: (value) =>
          state.copyWith(categoriesState: SubState.success(value)),
    );

    emit(newState);
  }

  void _titleFocusChanged(
    TaskAddScreenTitleFocusChanged event,
    Emitter emit,
  ) {
    if (event.hasFocus) {
      emit(state.copyWith(titleError: ''));
      return;
    }

    if (state.title.isNotEmpty) {
      emit(state.copyWith(titleError: ''));
      return;
    }

    emit(state.copyWith(titleError: titleError));
  }

  void _titleChanged(
    TaskAddScreenTitleChanged event,
    Emitter emit,
  ) {
    emit(state.copyWith(title: event.value));
  }

  void _descriptionChanged(
    TaskAddScreenDescriptionChanged event,
    Emitter emit,
  ) {
    emit(state.copyWith(description: event.value));
  }

  void _imageChanged(
    TaskAddScreenImageChanged event,
    Emitter emit,
  ) async {
    return emit(state.copyWith(image: Right(event.value)));
  }

  void _durationFocusChanged(
    TaskAddScreenDurationFocusChanged event,
    Emitter emit,
  ) {
    if (event.hasFocus) {
      emit(state.copyWith(durationError: ''));
      return;
    }

    if (state.duration != Duration.zero) {
      emit(state.copyWith(durationError: ''));
      return;
    }

    emit(
      state.copyWith(durationError: durationError),
    );
  }

  void _durationChanged(
    TaskAddScreenDurationChanged event,
    Emitter emit,
  ) {
    emit(state.copyWith(duration: event.value));
  }

  void _startingDateChanged(
    TaskAddScreenStartingDateChanged event,
    Emitter emit,
  ) {
    emit(state.copyWith(startingDate: event.value));
  }

  void _categoryChanged(
    TaskAddScreenCategoryChanged event,
    Emitter emit,
  ) {
    emit(state.copyWith(category: Right(event.value)));
  }

  void _reset(
    TaskAddScreenReset event,
    Emitter emit,
  ) {
    emit(TaskAddScreenState.init(id: state.id, categoriesState: state.categoriesState));
  }

  void _submitted(
    TaskAddScreenSubmitted event,
    Emitter emit,
  ) async {
    final titleHasError = state.title.isEmpty;
    final durationHasError = state.duration == Duration.zero;
    final categoryHasError = state.category == null;

    if (titleHasError || durationHasError || categoryHasError) {
      emit(
        state.copyWith(
          titleError: titleHasError ? titleError : '',
          durationError: durationHasError ? durationError : '',
          categoryError: durationHasError ? categoryError : '',
        ),
      );

      return;
    }

    emit(state.copyWith(submitState: const SubState.inProgress()));

    final task = TaskWrapper(
      id: state.id,
      title: state.title,
      duration: state.duration,
      image: state.image,
      description: state.description,
      startingDate: state.startingDate,
      category: state.category,
      status: false,
    );

    final either = await (state.isEditing
        ? _taskRepository.updateTask(task)
        : _taskRepository.addTask(task.toTask()));

    either.fold(
      ifLeft: (value) {
        emit(state.copyWith(submitState: SubState.failure(value)));
      },
      ifRight: (id) {
        emit(
          state.copyWith(
            submitState: SubState.success(
              state.isEditing ? task : task.copyWith(id: id),
            ),
          ),
        );
      },
    );
  }
}
