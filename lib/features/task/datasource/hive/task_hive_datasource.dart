import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/task/task.dart';

class TaskLocalDatasource implements TaskDatasource {
  final _box = Hive.box<TaskHiveType>('task_box');

  @override
  Future<dynamic> addTask(Task task) {
    return _box.add(TaskHiveType.fromTask(task));
  }

  @override
  Future<Iterable<dynamic>> addAllTasks(Iterable<Task> tasks) =>
      _box.addAll(tasks.map(TaskHiveType.fromTask));

  @override
  Future<void> deleteTask(dynamic id) {
    if (!_box.containsKey(id)) {
      throw TaskNotFoundException(id);
    }
    return _box.delete(id);
  }

  @override
  Future<TaskWrapper> getTask(dynamic id) async {
    final output = _box.get(id);
    if (output == null) {
      throw TaskNotFoundException(id);
    }
    return output.wrap(id);
  }

  @override
  Future<List<TaskWrapper>> listTasks() async {
    return _box.toMap().entries.map((e) => e.value.wrap(e.key)).toList();
  }

  @override
  Future<void> updateTask(TaskWrapper taskWrapper) async {
    if (!_box.containsKey(taskWrapper.id)) {
      throw TaskNotFoundException(taskWrapper.id);
    }
    _box.put(taskWrapper.id, TaskHiveType.fromTask(taskWrapper.toTask()));
  }

  @override
  Future<List<bool>> anyTasksInRanges(
    List<List<JalaliRange>> ranges, [
    bool? status,
  ]) {
    final List<bool> output = List.filled(ranges.length, false);

    int foundCount = 0;

    for (var task in _box.values) {
      if (foundCount == ranges.length) break;
      if (status != null && task.status != status) continue;

      for (var i = 0; i < ranges.length; i++) {
        if (output[i]) continue;

        final result = ranges[i].any(
          (range) =>
              range.inRange(
                Jalali.fromMillisecondsSinceEpoch(task.startingDate),
              ) ||
              range.inRange(task.endDate),
        );

        if (result) {
          output[i] = result;
          foundCount++;
        }
      }
    }

    return SynchronousFuture(output);
  }

  @override
  Future<List<TaskWrapper>> listTasksInRange(
    List<JalaliRange> ranges, [
    bool? status,
  ]) => SynchronousFuture(
    _box
        .toMap()
        .entries
        .map((e) => e.value.toTaskWrapper(e.key))
        .where(
          (task) =>
              (status == null || task.status == status) &&
              ranges.any(
                (range) =>
                    range.inRange(task.startingDate) ||
                    range.inRange(task.endDate),
              ),
        )
        .toList(),
  );
}

extension _HiveTypeExtension on TaskHiveType {
  Jalali get endDate =>
      Jalali.fromMillisecondsSinceEpoch(startingDate + duration);

  TaskWrapper toTaskWrapper(dynamic id) => TaskWrapper(
    id: id,
    title: title,
    description: description,
    duration: Duration(milliseconds: duration),
    startingDate: Jalali.fromMillisecondsSinceEpoch(startingDate),
    category: category,
    image: image,
    status: status,
  );
}
