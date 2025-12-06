part of 'task_add_screen_bloc.dart';

sealed class TaskAddScreenEvent {
  const TaskAddScreenEvent();
}

final class TaskAddScreenTitleFocusChanged extends TaskAddScreenEvent {
  final bool hasFocus;

  const TaskAddScreenTitleFocusChanged(this.hasFocus);
}

final class TaskAddScreenTitleChanged extends TaskAddScreenEvent {
  final String value;

  const TaskAddScreenTitleChanged(this.value);
}

final class TaskAddScreenDescriptionChanged extends TaskAddScreenEvent {
  final String value;

  const TaskAddScreenDescriptionChanged(this.value);
}

final class TaskAddScreenImageChanged extends TaskAddScreenEvent {
  final dynamic value;

  const TaskAddScreenImageChanged(this.value);
}

final class TaskAddScreenCategoryChanged extends TaskAddScreenEvent {
  final dynamic value;

  const TaskAddScreenCategoryChanged(this.value);
}

final class TaskAddScreenDurationFocusChanged extends TaskAddScreenEvent {
  final bool hasFocus;

  const TaskAddScreenDurationFocusChanged(this.hasFocus);
}

final class TaskAddScreenDurationChanged extends TaskAddScreenEvent {
  final Duration value;

  const TaskAddScreenDurationChanged(this.value);
}

final class TaskAddScreenStartingDateChanged extends TaskAddScreenEvent {
  final Jalali value;

  const TaskAddScreenStartingDateChanged(this.value);
}

final class TaskAddScreenSubmitted extends TaskAddScreenEvent {
  const TaskAddScreenSubmitted();
}

final class TaskAddScreenReset extends TaskAddScreenEvent {
  const TaskAddScreenReset();
}

final class TaskAddScreenCategoriesLoadRequested extends TaskAddScreenEvent {
  const TaskAddScreenCategoriesLoadRequested();
}
