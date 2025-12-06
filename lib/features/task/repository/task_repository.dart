import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/task/models/task_wrapper.dart';
import 'package:todo/features/task/models/task.dart';
import 'package:dart_either/dart_either.dart';

abstract class TaskRepository {
  Future<Either<String, List<bool>>> anyTasksInRanges(
    List<List<JalaliRange>> ranges, [
    bool? status,
  ]);
  Future<Either<String, List<TaskWrapper>>> listTasksInRange(
    List<JalaliRange> ranges, [
    bool? status,
  ]);
  Future<Either<String, List<TaskWrapper>>> listTasks();
  Future<Either<String, TaskWrapper>> getTask(dynamic id);
  Future<Either<String, dynamic>> addTask(Task task);
  Future<Either<String, String>> deleteTask(dynamic id);
  Future<Either<String, String>> updateTask(TaskWrapper taskWrapper);
}
