part of 'listable_bloc.dart';

abstract class ListableEvent {
  const ListableEvent();
}

final class ListableLoadRequested extends ListableEvent {
  const ListableLoadRequested();
}

final class ListableDeletePressed<T> extends ListableEvent {
  final T item;
  const ListableDeletePressed(this.item);
}

final class ListableEditingFinished<T> extends ListableEvent {
  final T item;
  const ListableEditingFinished(this.item);
}

final class ListableItemAdded<T> extends ListableEvent {
  final T item;
  const ListableItemAdded(this.item);
}