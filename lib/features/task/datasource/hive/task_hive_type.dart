import 'package:hive/hive.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/task/task.dart';

part 'task_hive_type.g.dart';

@HiveType(typeId: 0)
class TaskHiveType {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final int duration;

  @HiveField(3)
  final int startingDate;

  @HiveField(4)
  final dynamic category;

  @HiveField(5)
  final dynamic image;

  @HiveField(6)
  final bool status;

  const TaskHiveType({
    required this.title,
    required this.description,
    required this.duration,
    required this.startingDate,
    required this.category,
    required this.image,
    required this.status,
  });

  factory TaskHiveType.fromTask(Task task) => TaskHiveType(
    title: task.title,
    description: task.description,
    duration: task.duration.inMilliseconds,
    startingDate: task.startingDate.millisecondsSinceEpoch,
    category: task.category,
    image: task.image,
    status: task.status,
  );

  TaskWrapper wrap(int id) => TaskWrapper(
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
