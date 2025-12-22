import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/task/task.dart';

import '../../extensions.dart';

class HomeScreenRobot {
  HomeScreenRobot(this.tester);

  @protected
  final WidgetTester tester;

  Future<void> enterSearchText(String text, [Duration? delayPerChar]) async {
    final finder = find.byKey(
      const Key('home_screen_search_field'),
      skipOffstage: false,
    );
    expect(finder, findsOneWidget);

    await tester.scrollTo(finder);

    if (delayPerChar == null || delayPerChar == Duration.zero || text.isEmpty) {
      await tester.enterText(finder, text);
      await tester.pump();
      return;
    }

    await tester.enterText(finder, text[0]);
    for (var i = 1; i < text.length; i++) {
      await Future.delayed(delayPerChar);
      await tester.enterText(finder, text.substring(0, i + 1));
      await tester.pump();
    }
  }

  void verifyTaskExistance(dynamic id, bool exists) {
    final baseFinder = find.byType(TaskWidget);
    final foundTasks = baseFinder.evaluate();

    bool found = false;
    for (var element in foundTasks) {
      final widget = element.widget as TaskWidget;
      if (widget.task?.id == id) {
        found = true;
        break;
      }
    }
    expect(found, exists ? isTrue : isFalse);
  }

  Future<void> toggleFirstTask() async {
    final finder = find.byType(TaskWidget, skipOffstage: false).first;
    await tester.scrollTo(finder);
    await tester.tap(finder, warnIfMissed: false);
  }

  Future<void> openTasksPage() async {
    final finder = find.byKey(
      const Key('home_screen_show_more_tasks_button'),
      skipOffstage: false,
    );
    await tester.scrollTo(finder);
    await tester.tap(finder);
  }
}
