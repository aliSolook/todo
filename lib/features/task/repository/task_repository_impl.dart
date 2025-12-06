import 'package:dart_either/dart_either.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/task/datasource/task_datasource.dart';
import 'package:todo/features/task/models/task_wrapper.dart';
import 'package:todo/features/task/models/task.dart';
import 'package:todo/features/task/repository/task_repository.dart';
import 'package:todo/di/di.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _source = locator.get();
  final Duration? _delay;

  TaskRepositoryImpl([Duration? delay]) : _delay = delay;

  @override
  Future<Either<String, dynamic>> addTask(Task task) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.addTask(task));
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> deleteTask(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.deleteTask(id);
      return const Right('دسته‌بندی با موفقیت حذف شد');
    } on TaskNotFoundException {
      return const Left('تسک وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, TaskWrapper>> getTask(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.getTask(id));
    } on TaskNotFoundException {
      return const Left('تسک وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, List<TaskWrapper>>> listTasks() async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.listTasks());
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> updateTask(TaskWrapper taskWrapper) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.updateTask(taskWrapper);
      return const Right('دسته‌بندی با موفقیت ویرایش شد');
    } on TaskNotFoundException {
      return const Left('تسک وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, List<bool>>> anyTasksInRanges(
    List<List<JalaliRange>> ranges, [
    bool? status,
  ]) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.anyTasksInRanges(ranges, status));
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, List<TaskWrapper>>> listTasksInRange(
    List<JalaliRange> ranges, [
    bool? status,
  ]) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.listTasksInRange(ranges, status));
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }
}
