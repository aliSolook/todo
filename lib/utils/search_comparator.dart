import 'package:flutter/foundation.dart';

typedef SearchConverter<T> = String Function(T item);
typedef Comparer<T> = int Function(T a, T b);

abstract class SearchFilter<T> {
  const SearchFilter(this.searchText, this.converters, this.comparer);

  SearchFilter.signle(
    this.searchText,
    SearchConverter<T> converter, [
    this.comparer,
  ]) : converters = [converter];

  final String searchText;
  final List<SearchConverter<T>> converters;

  @protected
  final Comparer<T>? comparer;

  int compare(T a, T b);
  List<T> filter(List<T> items);

  List<T> search(List<T> items) {
    filter(items);
    items.sort(compare);
    return items;
  }
}

class WeightedSearchFilter<T> extends SearchFilter<T> {
  final List<String> _searchTerms;
  final List<String> _searchChars;
  final Map<String, double> _scoreCache = {};
  final double _minimumRelevanceScore;
  double _maxScore = 0;

  WeightedSearchFilter({
    required String searchText,
    required List<SearchConverter<T>> converters,
    Comparer<T>? comparer,
    double minimumRelevanceScore = 100.0,
  }) : _searchTerms = searchText.toLowerCase().trim().split(RegExp(r'\s+')),
       _searchChars = _breakText(searchText),
       _minimumRelevanceScore = minimumRelevanceScore,
       super(searchText.toLowerCase(), converters, comparer);

  factory WeightedSearchFilter.signle({
    required String searchText,
    required SearchConverter<T> converter,
    Comparer<T>? comparer,
    double minimumRelevanceScore = 100.0,
  }) => WeightedSearchFilter(
    searchText: searchText,
    converters: [converter],
    minimumRelevanceScore: minimumRelevanceScore,
    comparer: comparer,
  );

  static List<String> _breakText(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'\s+'), '').split('');

  double _calcScoreForT(T e) {
    double score = 0;
    for (var converter in converters) {
      score += _calcScore(converter(e));
    }

    if (score > _maxScore) _maxScore = score;

    return score;
  }

  @override
  int compare(T a, T b) {
    final aScore = _calcScoreForT(a);
    final bScore = _calcScoreForT(b);

    if (aScore != bScore) {
      return bScore.compareTo(aScore);
    }

    return comparer?.call(a, b) ?? 0;
  }

  @override
  List<T> filter(List<T> items) => items
    ..removeWhere(
      (item) {
        final double threshold;
        if (_maxScore < _minimumRelevanceScore) {
          threshold = _maxScore / 2;
        } else {
          threshold = _minimumRelevanceScore;
        }

        return _calcScoreForT(item) < threshold;
      },
    );

  double _calcScore(final String text) {
    final lowerText = text.toLowerCase();

    if (_scoreCache[text] != null) return _scoreCache[text]!;

    double score = 0.0;

    if (lowerText == searchText.toLowerCase()) {
      score += 1000;
    }

    if (lowerText.startsWith(searchText.toLowerCase())) {
      score += 800;
    }

    if (lowerText.contains(searchText.toLowerCase())) {
      score += 600;
    }

    // Word matching: count and position matter
    int wordMatches = 0;
    for (int i = 0; i < _searchTerms.length; i++) {
      if (_searchTerms[i].isEmpty) continue;

      if (lowerText.contains(_searchTerms[i])) {
        wordMatches++;
        // Early words in search are more important
        score += (_searchTerms.length - i) * 100;

        // Word at beginning of text gets bonus
        if (lowerText.startsWith(_searchTerms[i])) {
          score += 50;
        }
      }
    }

    // Percentage of words matched
    if (_searchTerms.isNotEmpty) {
      final wordMatchRatio = wordMatches / _searchTerms.length;
      score += wordMatchRatio * 300;
    }

    // Characters closer together get higher scores
    int charMatches = 0;
    int lastFoundIndex = -1;
    double proximityBonus = 0;
    for (int charIndex = 0; charIndex < _searchChars.length; charIndex++) {
      final char = _searchChars[charIndex];
      final index = lowerText.indexOf(char, lastFoundIndex + 1);
      if (index >= 0) {
        if (lastFoundIndex != -1) {
          // Reward characters that appear close together
          final distance = index - lastFoundIndex;
          proximityBonus += (10 - distance).clamp(0, 10).toDouble();
        }

        // order of the character in the search query matters, 10 points maximum
        proximityBonus +=
            (_searchChars.length - charIndex) / _searchChars.length * 10;

        lastFoundIndex = index;
        charMatches++;
      }
    }
    score += proximityBonus;

    if (_searchChars.isNotEmpty) {
      final charMatchRatio = charMatches / _searchChars.length;
      score += charMatchRatio * 100;
    }

    return _scoreCache[lowerText] = score;
  }
}
