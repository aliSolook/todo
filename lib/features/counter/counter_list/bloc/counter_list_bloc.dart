import 'dart:async';
import 'package:dart_either/dart_either.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:todo/utils/functions.dart';
part 'counter_list_state.dart';

typedef CounterListOrderItems = List<OrderItem<CounterOrder>>;

final class CounterListBloc
    extends ListableBloc<CounterWrapper, CounterListState>
    with
        SortableBloc<CounterWrapper, CounterOrder, CounterListState>,
        SearchableBloc<CounterWrapper, CounterSearchField, CounterListState>,
        SelectableBloc<CounterWrapper, CounterListState> {
  final CounterRepository _repository = locator.get();

  CounterListBloc([CounterListState? initialState])
    : super(initialState ?? CounterListState());

  @override
  Future<Either<String, String>> deleteItem(CounterWrapper item) =>
      _repository.deleteCounter(item.id);

  @override
  Future<Either<String, List<CounterWrapper>>> loadData() async =>
      _repository.listCounters();

  @override
  bool sameItem(CounterWrapper? a, CounterWrapper? b) => a?.id == b?.id;

  @override
  String getSearchField(
    CounterSearchField field,
    CounterWrapper item,
  ) => field.getField(item);

  @override
  Comparable getSortField(
    CounterOrder<Comparable> order,
    CounterWrapper item,
  ) => order.getField(item);
}
