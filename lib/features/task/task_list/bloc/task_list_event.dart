part of 'task_list_bloc.dart';

final class TaskListDateRangeChanged extends ListableEvent {
  final List<JalaliRange> ranges;

  const TaskListDateRangeChanged(this.ranges);
}

final class TaskListTaskToggled extends ListableEvent {
  final TaskWrapper task;
  const TaskListTaskToggled(this.task);
}

final class TaskListDateToggled extends ListableEvent{
  final Jalali date;

  const TaskListDateToggled(this.date);
}