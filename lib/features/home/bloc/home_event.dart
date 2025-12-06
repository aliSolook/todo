part of 'home_bloc.dart';

final class HomeSelectedToggled extends ListableEvent {
  const HomeSelectedToggled();
}

final class HomeTaskToggled extends ListableEvent {
  final TaskWrapper task;
  const HomeTaskToggled(this.task);
}