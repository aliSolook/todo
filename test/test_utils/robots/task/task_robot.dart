import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/task/task.dart';

import '../../extensions.dart';

class TaskRobot {
  const TaskRobot(this.tester);

  @protected
  final WidgetTester tester;

  Future<void> tapTask(dynamic id) async {
    final baseFinder = find.byType(TaskWidget, skipOffstage: false);
    final foundTasks = baseFinder.evaluate();

    bool found = false;
    int index = 0;
    for (var element in foundTasks) {
      final widget = element.widget as TaskWidget;
      index++;
      if (widget.task?.id == id) {
        found = true;
        break;
      }
    }

    expect(found, isTrue);
    await tester.scrollTo(baseFinder.at(index));
    await tester.tap(baseFinder.at(index));
  }
}
