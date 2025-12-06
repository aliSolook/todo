part of 'sortable_bloc.dart';

final class SortableOrderChanged<O extends Object> extends ListableEvent {
  final SortableListOfOrderItems<O> order;

  const SortableOrderChanged(this.order);
}
