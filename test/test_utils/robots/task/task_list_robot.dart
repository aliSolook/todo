import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo/features/task/task.dart';
import '../../extensions.dart';

// AI generated, not tested, needs modification

class TaskListRobot {
  @protected
  final WidgetTester tester;

  TaskListRobot(this.tester);

  /// Pull down to refresh the task list
  Future<void> pullToRefresh() async {
    final scrollViewFinder = find.byType(CustomScrollView);
    expect(scrollViewFinder, findsOneWidget);

    await tester.drag(scrollViewFinder, const Offset(0, 400));
    await tester.pump();
  }

  /// Verify that shimmer loading indicators are visible (initial load)
  void verifyShimmersVisible() {
    expect(find.byType(Shimmer), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verify that shimmers are gone after loading
  void verifyShimmersGone() {
    expect(find.byType(Shimmer), findsNothing);
  }

  /// Verify the header shows correct active task count
  void verifyActiveTaskCount(int count) {
    final text = count == 0 ? 'تسک فعالی وجود ندارد' : '$count تسک فعال';
    expect(find.textContaining(text), findsOneWidget);
  }

  /// Tap the calendar icon to open date range picker
  Future<void> openDateRangePicker() async {
    final calendarFinder = find.byKey(
      const Key('task_list_screen_show_date_range_picker_button'),
    );

    expect(calendarFinder, findsOneWidget);
    await tester.scrollTo(calendarFinder);
    await tester.tap(calendarFinder);
    await tester.pump();
  }

  void verifyDateRangePickerDialog() {
    expect(find.byType(PersianDateRangePickerDialog), findsOneWidget);
  }

  /// Select a specific day in the week days row
  Future<void> selectDayAt(int index) async {
    final dayButtonFinder = find.descendant(
      of: find.byKey(
        const Key('task_list_screen_days_of_week_parent'),
        skipOffstage: false,
      ),
      matching: find.byType(FilledButton, skipOffstage: false).at(index),
      skipOffstage: false,
    );
    await tester.scrollTo(dayButtonFinder);
    await tester.tap(dayButtonFinder);
    await tester.pump();
  }

  /// Verify a day is selected (index in the 7-day row)
  void verifyDaySelected(int index, {required bool selected}) {
    final buttonFinder = find.descendant(
      of: find.byKey(
        const Key('task_list_screen_days_of_week_parent'),
        skipOffstage: false,
      ),
      matching: find.byType(DayOfWeekWidget, skipOffstage: false).at(index),
      skipOffstage: false,
    );
    final button = tester.widget<DayOfWeekWidget>(buttonFinder);

    expect(button.selected, selected);
  }

  /// Verify a task with given title is visible
  void verifyTaskVisible(dynamic id, {bool? checked}) {
    // Optionally verify it's in correct section
    final finder = find.where((e) {
      final widget = e.widget;
      if (widget is! TaskWidget) return false;
      return widget.task?.id == id;
    });

    expect(finder, findsOneWidget);
    if (checked == null) return;
    final taskWidget = tester.widget<TaskWidget>(finder);
    expect(taskWidget.disabled, checked); // disabled means in "done" section
  }

  /// Verify task is not visible
  void verifyTaskNotVisible(dynamic id) {
    final finder = find.where((e) {
      final widget = e.widget;
      if (widget is! TaskWidget) return false;
      return widget.task?.id == id;
    });

    expect(finder, findsNothing);
  }

  /// Long press a task to enter selection mode
  Future<void> longPressTaskByTitle(String title) async {
    final taskFinder = find.ancestor(
      of: find.text(title),
      matching: find.byType(TaskWidget),
    );

    await tester.scrollTo(taskFinder);
    await tester.longPress(taskFinder);
    await tester.pumpAndSettle();
  }

  /// Verify selection mode is active and shows count
  void verifySelectionModeActive(int selectedCount) {
    expect(find.text('$selectedCount انتخاب شده'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  }

  /// Tap the close button to exit selection mode
  Future<void> exitSelectionMode() async {
    final closeFinder = find.byIcon(Icons.close);
    await tester.tap(closeFinder);
    await tester.pumpAndSettle();
  }

  /// Tap the delete button in selection mode
  Future<void> deleteSelectedTasks() async {
    final deleteFinder = find.byIcon(Icons.delete);
    await tester.tap(deleteFinder);
    await tester.pump();
  }

  /// Verify delete button is showing loading indicator
  void verifyDeleteButtonLoading() {
    expect(
      find.descendant(
        of: find.byIcon(Icons.delete).first,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
  }

  /// Verify the "done tasks" splitter is visible
  void verifyDoneTasksSplitterVisible() {
    expect(find.text('تسک های انجام شده'), findsOneWidget);
  }

  /// Verify the "done tasks" splitter is not visible
  void verifyDoneTasksSplitterHidden() {
    expect(find.text('تسک های انجام شده'), findsNothing);
  }

  /// Verify empty state message is shown
  void verifyEmptyStateVisible() {
    expect(find.text('تسکی وجود ندارد'), findsOneWidget);
  }

  /// Verify empty state is not shown
  void verifyEmptyStateHidden() {
    expect(find.text('تسکی وجود ندارد'), findsNothing);
  }

  /// Verify progress circle shows correct percentage
  void verifyProgressPercentage(String percentage) {
    expect(find.textContaining('$percentage%'), findsOneWidget);
  }

  /// Tap the FAB (assumes it's provided by ScreenManager)
  Future<void> tapFab() async {
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    await tester.tap(fabFinder);
    await tester.pumpAndSettle();
  }

  /// Edit a task by long press → edit button (or direct edit if available)
  Future<void> editTaskByTitle(String title) async {
    final taskFinder = find.ancestor(
      of: find.text(title),
      matching: find.byType(TaskWidget),
    );

    // Assuming edit is triggered via long press + edit action
    await tester.longPress(taskFinder);
    await tester.pumpAndSettle();

    // Find edit button inside TaskWidget (you may need to adjust key)
    final editFinder = find.descendant(
      of: taskFinder,
      matching: find.byKey(const Key('task_widget_edit_button')),
    );

    if (editFinder.evaluate().isNotEmpty) {
      await tester.tap(editFinder);
      await tester.pumpAndSettle();
    } else {
      // Fallback: some implementations may use onEditPressed directly
      throw UnimplementedError('Edit button not found – adjust finder');
    }
  }

  /// Verify a task is selected (visual feedback)
  void verifyTaskSelected(String title, {required bool selected}) {
    final taskFinder = find.ancestor(
      of: find.text(title),
      matching: find.byType(TaskWidget),
    );

    final taskWidget = tester.widget<TaskWidget>(taskFinder);
    expect(taskWidget.selected, selected);
  }

  /// Select multiple tasks by tapping them in selection mode
  Future<void> selectMultipleTasks(List<String> titles) async {
    for (final title in titles) {
      final taskFinder = find.ancestor(
        of: find.text(title),
        matching: find.byType(TaskWidget),
      );
      await tester.scrollTo(taskFinder);
      await tester.tap(taskFinder);
      await tester.pump();
    }
  }
}
