import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:todo/features/task/task.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends ListableBloc<TaskWrapper, TaskListState>
    with SelectableBloc<TaskWrapper, TaskListState> {
  final TaskRepository _repository = locator.get();

  TaskListBloc([TaskListState? initialState])
    : super(initialState ?? TaskListState());

  @override
  @protected
  void initiate() {
    super.initiate();

    on(_dateRangeChanged);
    on(_taskToggled);
    on(_dateToggled);
  }

  @override
  @protected
  void emitAndManipulate(TaskListState state, Emitter<TaskListState> emit) {
    final middleWare = EmitterMiddleware(emit, (newState) {
      if (state.manipulatedItems == newState.manipulatedItems) return newState;

      final checked = <TaskWrapper>[];
      final unChecked = <TaskWrapper>[];

      for (var task in newState.manipulatedItems) {
        if (task.status) {
          checked.add(task);
        } else {
          unChecked.add(task);
        }
      }

      return newState.copyWith(checked: checked, unChecked: unChecked);
    });

    return super.emitAndManipulate(state, middleWare);
  }

  @override
  FutureOr<void> loadRequested(
    ListableLoadRequested event,
    Emitter<TaskListState> emit, [
    List<TaskWrapper> Function(
      List<TaskWrapper> source,
      List<TaskWrapper> manipulated,
    )?
    sourceMiddleware,
  ]) async {
    await Future.wait([
      super.loadRequested(event, emit, sourceMiddleware) as Future,
      _updateDaysStatus(emit),
      _updateToday(emit),
    ]);
  }

  @override
  @protected
  Future<Either<String, String>> deleteItem(TaskWrapper item) =>
      _repository.deleteTask(item.id);

  @override
  @protected
  Future<Either<String, List<TaskWrapper>>> loadData() =>
      _repository.listTasksInRange(state.dateRange);

  @override
  @protected
  bool sameItem(TaskWrapper? a, TaskWrapper? b) => a?.id == b?.id;

  void _dateRangeChanged(
    TaskListDateRangeChanged event,
    Emitter<TaskListState> emit,
  ) async {
    _simplifyRanges(event.ranges);

    if (event.ranges.isEmpty || listEquals(event.ranges, state.dateRange)) {
      return;
    }

    emit(state.copyWith(dateRange: event.ranges));
    return loadAndEmit(emit);
  }

  void _taskToggled(
    TaskListTaskToggled event,
    Emitter<TaskListState> emit,
  ) async {
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
        final index = state.sourceItems.indexWhere(
          (e) => e.id == event.task.id,
        );
        if (index < 0) {
          emit(
            state.copyWith(
              alert: const Right(Alert.error('تکس یافت نشد!')),
              toggleState: state.toggleState
                  .where((e) => e != event.task.id)
                  .toList(),
            ),
          );
          return;
        }

        final newSource = List.of(state.sourceItems);
        newSource[index] = newTask;

        emitAndManipulate(
          state.copyWith(
            sourceItems: newSource,
            toggleState: state.toggleState
                .where((e) => e != event.task.id)
                .toList(),
          ),
          emit,
        );

        await Future.wait([
          _updateDaysStatus(emit),
          _updateToday(emit),
        ]);
      },
    );
  }

  void _dateToggled(
    TaskListDateToggled event,
    Emitter<TaskListState> emit,
  ) async {
    final newRanges = List.of(state.dateRange);
    final range = JalaliRange(
      start: event.date.withoutTime,
      end: event.date.withoutTime + 1,
    );

    final isInRange = newRanges.any((e) => e.inRange(event.date));

    if (!isInRange) {
      newRanges.add(range);
    } else {
      final startIndex = newRanges.indexWhere((e) => e.inRange(range.start));
      final endIndex = newRanges.indexWhere((e) => e.inRange(range.end));

      if (startIndex == endIndex) {
        final parent = newRanges.removeAt(startIndex);
        newRanges.add(JalaliRange(start: parent.start, end: range.start));
        newRanges.add(JalaliRange(start: range.end, end: parent.end));
      } else {
        newRanges[startIndex] = JalaliRange(
          start: newRanges[startIndex].start,
          end: range.start,
        );
        newRanges[endIndex] = JalaliRange(
          start: range.end,
          end: newRanges[endIndex].end,
        );
        newRanges.removeRange(startIndex + 1, endIndex);
      }
    }

    _simplifyRanges(newRanges);

    if (newRanges.isEmpty || listEquals(newRanges, state.dateRange)) return;

    emit(state.copyWith(dateRange: newRanges));
    return loadAndEmit(emit);
  }

  Future<void> _updateDaysStatus(Emitter<TaskListState> emit) async {
    if (state.daysState.isInProgress) {
      await stream.firstWhere((e) => !e.daysState.isInProgress);
      // waiting for the previous request to finish
    }

    final today = Jalali.now().withoutTime;
    final days = List.generate(7, (i) => today + i);
    final ranges = days
        .map(
          (e) => [
            JalaliRange(
              start: e,
              end: e.addDuration(
                const Duration(days: 1) - const Duration(milliseconds: 1),
              ),
            ),
          ],
        )
        .toList();

    emit(state.copyWith(daysState: const SubState.inProgress()));

    final daysStatus = await _repository
        .anyTasksInRanges(ranges, false)
        .then(
          (e) => e.map(
            (r) => Map.fromEntries(
              r.asMap().entries.map(
                (e) =>
                    MapEntry(ranges[e.key].first.start.addHours(12), e.value),
              ),
            ),
          ),
        );

    daysStatus.fold(
      ifLeft: (value) {
        emit(state.copyWith(daysState: SubState.failure(value)));
      },
      ifRight: (value) {
        assert(state.daysState.isInProgress);
        emit(state.copyWith(daysState: SubState.success(value)));
      },
    );
  }

  Future<void> _updateToday(Emitter<TaskListState> emit) async {
    if (state.todayState.isInProgress) {
      await stream.firstWhere((e) => !e.daysState.isInProgress);
      // waiting for the previous request to finish
    }
    emit(state.copyWith(todayState: const SubState.inProgress()));

    final today = Jalali.now().withoutTime;

    final count = await _repository
        .listTasksInRange([
          JalaliRange(
            start: today,
            end: today.addDuration(
              const Duration(days: 1) - const Duration(milliseconds: 1),
            ),
          ),
        ], false)
        .then((e) => e.map((l) => l.length));

    count.fold(
      ifLeft: (value) {
        emit(state.copyWith(todayState: SubState.failure(value)));
      },
      ifRight: (value) {
        emit(
          state.copyWith(
            todayState: SubState.success(MapEntry(today, value)),
          ),
        );
      },
    );
  }

  List<JalaliRange> _simplifyRanges(List<JalaliRange> ranges) {
    if (ranges.isEmpty) return ranges;

    ranges.removeWhere((e) => e.isEmpty);
    ranges.sort((a, b) {
      int startComparison = a.start.compareTo(b.start);
      if (startComparison != 0) {
        return startComparison;
      }
      return a.end.compareTo(b.end);
    });

    for (var i = 0; i < ranges.length - 1;) {
      final current = ranges[i];
      final next = ranges[i + 1];

      if (next.start > current.end) {
        // if (next.start > current.end && next.start - 1 > current.end) {
        i++;
        continue;
      }

      if (next.end > current.end) {
        ranges[i] = JalaliRange(start: current.start, end: next.end);
      }

      ranges.removeAt(i + 1);
    }
    return ranges;
  }
}
