import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/task/models/task_wrapper.dart';
import 'package:todo/features/task/models/task.dart';

abstract class TaskDatasource {
  Future<List<bool>> anyTasksInRanges(List<List<JalaliRange>> ranges, [bool? status]);
  Future<List<TaskWrapper>> listTasksInRange(List<JalaliRange> ranges, [bool? status]);
  Future<List<TaskWrapper>> listTasks();
  Future<TaskWrapper> getTask(dynamic id);
  Future<dynamic> addTask(Task task);
  Future<void> deleteTask(dynamic id);
  Future<void> updateTask(TaskWrapper taskWrapper);
}

class TaskNotFoundException implements Exception {
  final dynamic id;

  TaskNotFoundException(this.id);

  @override
  String toString() {
    return 'TaskNotFoundException($id)';
  }
}
