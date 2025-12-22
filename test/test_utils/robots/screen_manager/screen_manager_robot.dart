import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ScreenManagerRobot {
  ScreenManagerRobot(this.tester);

  @protected
  final WidgetTester tester;

  Future<void> goToScreenAt(int index) {
    return tester.tap(find.byKey(Key('screen_manager_tab_$index')));
  }

  Future<void> switchTheme() {
    return tester.tap(
      find.descendant(
        of: find.byKey(const Key('screen_manager_theme_switcher_button')),
        matching: find.byType(IconButton),
      ),
    );
  }

  void verifyFabVisibility(bool isVisible) {
    expect(
      find.byKey(const Key('screen_manager_theme_switcher_button')),
      isVisible ? findsOneWidget : findsNothing,
    );
  }
}
