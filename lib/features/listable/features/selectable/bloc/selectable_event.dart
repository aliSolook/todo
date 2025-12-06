part of 'selectable_bloc.dart';

final class SelectableItemToggled<T> extends ListableEvent {
  final T item;

  const SelectableItemToggled(this.item);
}

final class SelectableDeleteSelectedPressed extends ListableEvent {
  const SelectableDeleteSelectedPressed();
}

final class SelectableClearSelectionPressed extends ListableEvent {
  const SelectableClearSelectionPressed();
}
