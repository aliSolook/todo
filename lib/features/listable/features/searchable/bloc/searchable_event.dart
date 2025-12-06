part of 'searchable_bloc.dart';

final class SearchableSearchFieldToggled<F extends Object>
    extends ListableEvent {
  final F field;

  const SearchableSearchFieldToggled(this.field);
}

final class SearchableSearchFieldsChanged<F extends Object>
    extends ListableEvent {
  final Set<F> added;
  final Set<F> removed;

  const SearchableSearchFieldsChanged({
    this.added = const {},
    this.removed = const {},
  });
}

final class SearchableSearchTextChanged extends ListableEvent {
  final String searchText;
  final bool withDelay;

  const SearchableSearchTextChanged(this.searchText, [this.withDelay = true]);
}
