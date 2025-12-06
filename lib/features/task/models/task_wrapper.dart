import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/task/models/task.dart';

class TaskWrapper extends Equatable {
  final dynamic id;
  final String title;
  final String description;
  final Duration duration;
  final Jalali startingDate;
  final dynamic category;
  final dynamic image;
  final bool status;

  const TaskWrapper({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.startingDate,
    required this.category,
    required this.image,
    required this.status,
  });

  TaskWrapper copyWith({
    dynamic id,
    String? title,
    String? description,
    Duration? duration,
    Jalali? startingDate,
    TimeOfDay? startingTime,
    dynamic category,
    dynamic image,
    bool? status,
  }) {
    return TaskWrapper(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      startingDate: startingDate ?? this.startingDate,
      category: category ?? this.category,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }

  factory TaskWrapper.fromTask(dynamic id, Task task) => TaskWrapper(
    id: id,
    title: task.title,
    description: task.description,
    duration: task.duration,
    startingDate: task.startingDate,
    category: task.category,
    image: task.image,
    status: task.status,
  );

  Task toTask() => Task(
    title: title,
    description: description,
    duration: duration,
    startingDate: startingDate,
    category: category,
    image: image,
    status: status,
  );

  Jalali get endDate => Jalali.fromMillisecondsSinceEpoch(
    startingDate.millisecondsSinceEpoch + duration.inMilliseconds,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    duration,
    startingDate,
    category,
    image,
    status,
  ];
}
