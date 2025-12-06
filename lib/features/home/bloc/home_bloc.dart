import 'dart:async';
import 'package:dart_either/dart_either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/task/task.dart';
import 'package:todo/features/listable/listable.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends ListableBloc<TaskWrapper, HomeState>
    with
        SelectableBloc<TaskWrapper, HomeState>,
        SearchableBloc<TaskWrapper, TaskSearchField, HomeState> {
  final _repository = locator.get<TaskRepository>();
  final _categoriesRepository = locator.get<CategoryRepository>();

  HomeBloc([HomeState? initialState]) : super(initialState ?? HomeState());

  @override
  void initiate() {
    super.initiate();
    on<HomeSelectedToggled>(_selectedToggled);
    on<HomeTaskToggled>(_taskToggled);
  }

  @override
  FutureOr<void> loadAndEmit(
    Emitter<HomeState> emit, [
    List<TaskWrapper> Function(
      List<TaskWrapper> source,
      List<TaskWrapper> manipulated,
    )?
    sourceMiddleware,
  ]) async {
    FutureOr categoriesFuture;
    final middleware = EmitterMiddleware(emit, (newState) {
      if (newState.status.isInProgress) {
        newState = newState.copyWith(
          categoriesState: const SubState.inProgress(),
        );

        categoriesFuture = _categoriesRepository.listCategories().then((value) {
          value.fold(
            ifLeft: (value) =>
                emit(state.copyWith(categoriesState: SubState.failure(value))),
            ifRight: (value) =>
                emit(state.copyWith(categoriesState: SubState.success(value))),
          );
        });
      } else {
        newState = newState.copyWith(today: Jalali.now().withoutTime);
      }
      return newState;
    });

    await super.loadAndEmit(middleware, sourceMiddleware);
    await categoriesFuture;
  }

  @override
  Future<Either<String, String>> deleteItem(TaskWrapper item) =>
      _repository.deleteTask(item.id);

  @override
  String getSearchField(TaskSearchField field, TaskWrapper item) =>
      field.getField(item);

  @override
  Future<Either<String, List<TaskWrapper>>> loadData() {
    final today = Jalali.now().withoutTime;
    return _repository.listTasksInRange([
      JalaliRange(start: today, end: today + 1),
    ], false);
  }

  @override
  bool sameItem(TaskWrapper? a, TaskWrapper? b) => a?.id == b?.id;

  void _selectedToggled(
    HomeSelectedToggled event,
    Emitter<HomeState> emit,
  ) async {
    final newTasks = List.of(
      state.selectedItems
          .where((e) => !state.toggleState.contains(e.id))
          .map((e) => e.copyWith(status: !e.status)),
    );

    emit(
      state.copyWith(
        toggleState: state.toggleState
            .followedBy(newTasks.map((e) => e.id))
            .toList(),
      ),
    );

    final eithers = Stream.fromFutures(
      newTasks.map((e) {
        return _repository.updateTask(e).then((r) => MapEntry(e, r));
      }),
    ).asBroadcastStream();

    eithers
        .where((e) => e.value.isLeft)
        .map((e) => MapEntry(e.key, (e.value as Left).value as String))
        .listen((event) {
          emit(
            state.copyWith(
              alert: Right(Alert.error(event.value)),
              toggleState: state.toggleState
                  .where((e) => e != event.key.id)
                  .toList(),
            ),
          );
        });

    final successes = await eithers
        .where((e) => e.value.isRight)
        .map((e) => e.key)
        .toList();

    if (successes.isEmpty) return;

    final sourceItems = state.sourceItems
        .where((e) => !successes.any((a) => a.id == e.id))
        .toList();

    final selectedItems = state.selectedItems
        .where((e) => !successes.any((a) => a.id == e.id))
        .toList();

    final toggleState = state.toggleState
        .where((e) => !successes.removeSingleWhere((t) => t.id == e))
        .toList();

    emitAndManipulate(
      state.copyWith(
        sourceItems: sourceItems,
        selectedItems: selectedItems,
        toggleState: toggleState,
      ),
      emit,
    );
  }

  void _taskToggled(
    HomeTaskToggled event,
    Emitter<HomeState> emit,
  ) async {
    if (state.deleteState.contains(event.task.id)) return;

    emit(
      state.copyWith(
        toggleState: state.toggleState.followedBy([event.task.id]).toList(),
      ),
    );

    final newTask = event.task.copyWith(status: !event.task.status);
    final either = await _repository.updateTask(newTask);

    await either.fold<FutureOr<void>>(
      ifLeft: (value) {
        emit(
          state.copyWith(
            alert: Right(Alert.error(value)),
            toggleState: state.toggleState
                .where((e) => e != event.task.id)
                .toList(),
          ),
        );
      },
      ifRight: (value) async {
        final sourceItems = state.sourceItems
            .where((e) => e.id != event.task.id)
            .toList();

        final toggleState = state.toggleState
            .where((e) => e != event.task.id)
            .toList();

        emitAndManipulate(
          state.copyWith(
            sourceItems: sourceItems,
            toggleState: toggleState,
          ),
          emit,
        );
      },
    );
  }
}
