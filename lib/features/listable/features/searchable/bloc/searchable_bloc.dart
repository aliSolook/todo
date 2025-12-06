import 'dart:async';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:todo/utils/search_comparator.dart';

part 'searchable_state.dart';
part 'searchable_event.dart';

typedef SearchConverter<T> = String Function(T item);

mixin SearchableBloc<T, F extends Object, S extends SearchableState<T, F>>
    on ListableBloc<T, S> {
  Completer<bool> _searchDelay = Completer()..complete(false);

  String getSearchField(F field, T item);

  @override
  @protected
  void initiate() {
    super.initiate();
    on<SearchableSearchFieldToggled<F>>(searchFieldToggled);
    on<SearchableSearchFieldsChanged<F>>(searchFieldsChanged);
    on<SearchableSearchTextChanged>(searchTextChanged);
  }

  @override
  @protected
  List<T> manipulateItems(List<T> itemsToManipulate, S newState) {
    SearchConverter<T> mapConverter(F f) {
      return (item) => getSearchField(f, item);
    }

    final searcher = WeightedSearchFilter<T>(
      searchText: newState.searchText,
      converters: newState.searchFields.map(mapConverter).toList(),
    );

    searcher.filter(itemsToManipulate);
    super.manipulateItems(itemsToManipulate, newState);
    itemsToManipulate.sort(searcher.compare);
    return itemsToManipulate;
  }

  @protected
  void searchFieldToggled(
    SearchableSearchFieldToggled<F> event,
    Emitter<S> emit,
  ) {
    final exists = state.searchFields.contains(event.field);

    return searchFieldsChanged(
      SearchableSearchFieldsChanged(
        added: {if (!exists) event.field},
        removed: {if (exists) event.field},
      ),
      emit,
    );
  }

  @protected
  void searchFieldsChanged(
    SearchableSearchFieldsChanged<F> event,
    Emitter<S> emit,
  ) {
    final searchFields = Set.of(state.searchFields);

    searchFields.addAll(event.added);
    searchFields.removeAll(event.removed);

    if (setEquals(searchFields, state.searchFields)) return;
    if (searchFields.isEmpty) searchFields.add(state.searchFields.first);

    emitAndManipulate(state.copyWith(searchFields: searchFields) as S, emit);
  }

  @protected
  void searchTextChanged(
    SearchableSearchTextChanged event,
    Emitter<S> emit,
  ) async {
    // canceling the previous search delay
    if (!_searchDelay.isCompleted) _searchDelay.complete(false);

    if (event.withDelay) {
      final myCompleter = _searchDelay = Completer();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!myCompleter.isCompleted) myCompleter.complete(true);
      });

      // search canceled
      if (!await myCompleter.future) return;
    }

    emitAndManipulate(state.copyWith(searchText: event.searchText) as S, emit);
  }
}
