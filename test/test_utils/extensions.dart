import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import './test_utils.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> scrollTo(FinderBase<Element> finder) async {
    await Scrollable.ensureVisible(element(finder));
    await pump();
  }

  Future<T> pumpUntil<T>(Future<T> future, [Duration timeout = const Duration(minutes: 10)]) async {
    (T value,)? result;
    future.then((r) => result = (r,)).timeout(timeout);

    while (result == null) {
      await pump();
    }

    return result!.$1;
  }

  Future<int> pumpUntilCount(Future future, [Duration timeout = const Duration(minutes: 10)]) async {
    bool isFutureDone = false;
    future.then((_) => isFutureDone = true).timeout(timeout);

    int count = 0;
    while (!isFutureDone) {
      await pump();
      count++;
    }

    return count;
  }

  int count(FinderBase finder) => finder.evaluate().length;
}

extension CommonFindersExtensions on CommonFinders{
  FinderBase<Element> where(bool Function(Element element) test) => WhereFinder(test);
}