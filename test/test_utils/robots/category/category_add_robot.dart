import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import '../../extensions.dart';

class CategoryAddRobot {
  @protected
  final WidgetTester tester;

  CategoryAddRobot(this.tester);

  Future<void> entertTitle(String text, [Duration? delayPerChar]) async {
    final finder = find.byType(TextField, skipOffstage: false);
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

  /// if title is null, isNotEmpty matcher will be used
  /// if title is not null, the text is used as matcher
  void verifyTitleText([String? text]) {
    final finder = find.descendant(
      of: find.byType(TextField, skipOffstage: false),
      matching: find.byType(EditableText, skipOffstage: false),
      skipOffstage: false,
    );

    final widget = tester.widget<EditableText>(finder);

    if (text == null) {
      expect(widget.controller.text, isNotEmpty);
    } else {
      expect(widget.controller.text, text);
    }
  }

  Future<void> deselectColor() async {
    final finder = find.byKey(
      const Key('category_add_screen_reset_color'),
      skipOffstage: false,
    );
    await tester.scrollTo(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> submit() async {
    final finder = find.byKey(
      const Key('category_add_screen_submit'),
      skipOffstage: false,
    );
    await tester.scrollTo(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> focusTitle() async {
    final finder = find.byType(TextField, skipOffstage: false);
    await tester.scrollTo(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> unfocusTitle() async {
    // final finder = find.byType(TextField, skipOffstage: false);
    // expect(finder, findsOneWidget);
    // await tester.scrollTo(finder);
    // final element = tester.element(finder);
    // final node = FocusScope.of(element, createDependency: false);
    // if (node.hasFocus) {
    //   node.unfocus();
    //   await tester.pump();
    //   return;
    // }
    // fail('Title was not focused');
    final finder = find.descendant(
      of: find.byType(TextField, skipOffstage: false),
      matching: find.byType(EditableText, skipOffstage: false),
      skipOffstage: false,
    );

    final widget = tester.widget<EditableText>(finder);

    widget.focusNode.unfocus();
    await tester.pump();
  }

  void verifyTitleHasError([String? error]) {
    final finder = find.byType(TextField, skipOffstage: false);
    expect(finder, findsOneWidget);
    final widget = tester.widget<TextField>(finder);
    expect(widget.decoration?.errorText, error ?? isNotEmpty);
  }

  void verifyTitleHasNoError() {
    final finder = find.byType(TextField, skipOffstage: false);
    expect(finder, findsOneWidget);
    final widget = tester.widget<TextField>(finder);
    expect(widget.decoration?.errorText, isNull);
  }

  Future<void> selectImage(ImageWrapper? image) async {
    final imageSelectorFinder = find.byType(
      ImageSelectorWidget,
      skipOffstage: false,
    );

    await tester.scrollTo(imageSelectorFinder);

    // openning the widget selector modal sheet
    await tester.tap(imageSelectorFinder, warnIfMissed: false);

    // rendering a single frame just for the modal bottom sheet to be inserted into the widget tree
    await tester.pump();

    // verifying modal sheet's existance
    final bottomSheetFinder = find.byType(
      ImageSelectorModalSheet,
      skipOffstage: false,
    );
    expect(bottomSheetFinder, findsOneWidget);

    // poping the sheet with a custom value
    final bottomSheet = tester.element(bottomSheetFinder);
    Navigator.pop(bottomSheet, image);
    await tester.pump();
  }

  Future<void> deselectImage() async {
    final imageFinder = find.byType(ImageSelectorWidget, skipOffstage: false);
    final deselectFinder = find.byKey(
      const Key('image_selector_widget_deselect_button'),
      skipOffstage: false,
    );

    expect(imageFinder, findsOneWidget);
    final image = tester.widget(imageFinder) as ImageSelectorWidget;
    expect(image.image, isNotNull);

    expect(deselectFinder, findsOneWidget);
    await tester.scrollTo(deselectFinder);
    await tester.tap(deselectFinder);
    await tester.pump();
  }

  void verifyImage(ImageWrapper? image) {
    final finder = find.byType(ImageSelectorWidget, skipOffstage: false);
    final widget = tester.widget(finder) as ImageSelectorWidget;

    expect(widget.image, image?.id);
  }

  Future<void> selectColorAt(int colorIndex) async {
    final colorsFinder = find.byType(ColorPaletteColor, skipOffstage: false);
    colorIndex = colorIndex % colorsFinder.evaluate().length;
    final targetColorFinder = colorsFinder.at(colorIndex);
    await tester.scrollTo(targetColorFinder);
    await tester.tap(targetColorFinder);
    await tester.pump();
  }

  void verifyColor(int colorIndex, {required bool isSelected}) {
    verfiyColor(false, colorIndex, isSelected);
  }

  Future<void> selectCustomColor(dynamic colorId) async {
    final finder = find.byKey(
      ColorPaletteCustomColor.generateKey(colorId)!,
      skipOffstage: false,
    );
    await tester.scrollTo(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> selectCustomColorAt(int colorIndex) async {
    final colorsFinder = find.byType(
      ColorPaletteCustomColor,
      skipOffstage: false,
    );
    colorIndex = colorIndex % colorsFinder.evaluate().length;
    final targetColorFinder = colorsFinder.at(colorIndex);
    await tester.scrollTo(targetColorFinder);
    await tester.tap(targetColorFinder);
    await tester.pump();
  }

  Future<void> deleteCustomColor(dynamic colorId) async {
    final finder = find.descendant(
      of: find.byKey(
        ColorPaletteCustomColor.generateKey(colorId)!,
        skipOffstage: false,
      ),
      matching: find.byKey(
        const Key('custom_color_delete_button'),
        skipOffstage: false,
      ),
      skipOffstage: false,
      matchRoot: true,
    );
    await tester.scrollTo(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> deleteCustomColorAt(int colorIndex) async {
    final finder = find.descendant(
      of: find.byType(
        ColorPaletteCustomColor,
        skipOffstage: false,
      ),
      matching: find.byKey(
        const Key('custom_color_delete_button'),
        skipOffstage: false,
      ),
    );
    colorIndex = colorIndex % finder.evaluate().length;
    final targetColorFinder = finder.at(colorIndex);
    await tester.scrollTo(targetColorFinder);
    await tester.tap(targetColorFinder);
    await tester.pump();
  }

  void verifyCustomColorIsLoading(dynamic colorId) {
    final finder = find.byKey(
      ColorPaletteCustomColor.generateKey(colorId)!,
      skipOffstage: false,
    );

    expect(finder, findsOneWidget);
    final widget = tester.widget<ColorPaletteCustomColor>(finder);
    expect(widget.deleteInProgress, isTrue);
  }

  void verifyCustomColorAtIsLoading(int colorIndex) {
    final finder = find.descendant(
      of: find.byType(
        ColorPaletteCustomColor,
        skipOffstage: false,
      ),
      matching: find.byKey(
        const Key('custom_color_delete_button'),
        skipOffstage: false,
      ),
    );
    colorIndex = colorIndex % finder.evaluate().length;
    final widget = tester.widget<ColorPaletteCustomColor>(
      finder.at(colorIndex),
    );
    expect(widget.deleteInProgress, isTrue);
  }

  void varifyCustomColorDoesNotExists(dynamic colorId) {
    final finder = find.byKey(
      ColorPaletteCustomColor.generateKey(colorId)!,
      skipOffstage: false,
    );
    expect(finder, findsNothing);
  }

  void verifyCustomColorAt(int colorIndex, {required bool isSelected}) {
    verfiyColor(true, colorIndex, isSelected);
  }

  void verifyCustomColor(dynamic id, {required bool isSelected}) {
    assert(id != null);
    final finder = find.byKey(
      ColorPaletteCustomColor.generateKey(id)!,
      skipOffstage: false,
    );
    expect(finder, findsOneWidget);
    final widget = tester.widget(finder) as ColorPaletteCustomColor;
    expect(widget.isSelected, isSelected);
  }

  Future<void> addCustomColor(CustomColorWrapper? color) async {
    final buttonFinder = find.byKey(
      const Key('category_add_screen_add_custom_color'),
      skipOffstage: false,
    );

    await tester.scrollTo(buttonFinder);

    // openning the color selector dialog
    await tester.tap(buttonFinder, warnIfMissed: false);

    // rendering a single frame just for the color selector dialog to be inserted into the widget tree
    await tester.pump();

    // verifying dialog's existance
    final dialogFinder = find.byType(ColorSelectorDialog, skipOffstage: false);
    expect(dialogFinder, findsOneWidget);

    // poping the dialog with a custom value
    final dialog = tester.element(dialogFinder);
    Navigator.pop(dialog, color);
    await tester.pump();
  }

  void verifyAddCustomColor(CustomColorWrapper color) {
    assert(color.id != null);
    final finder = find.byKey(
      ColorPaletteCustomColor.generateKey(color.id)!,
      skipOffstage: false,
    );
    expect(finder, findsOneWidget);
    final widget = tester.widget(finder) as ColorPaletteCustomColor;
    expect(widget.color.toARGB32(), color.color);
  }

  void verfiyColor(bool isCustom, int colorIndex, bool isSelected) {
    final colorsFinder = find.byType(
      isCustom ? ColorPaletteCustomColor : ColorPaletteColor,
      skipOffstage: false,
    );

    colorIndex = colorIndex % colorsFinder.evaluate().length;
    final targetColorFinder = colorsFinder.at(colorIndex);
    expect(targetColorFinder, findsOneWidget);

    final widget = tester.widget(targetColorFinder) as dynamic;
    expect(widget.isSelected, isSelected);
  }

  void verfiyNoColorIsSelected() {
    final colorFinder = find.byType(ColorPaletteColor, skipOffstage: false);
    final colorIterator = colorFinder.evaluate().iterator;
    while (colorIterator.moveNext()) {
      final widget = colorIterator.current.widget as ColorPaletteColor;

      if (widget.isSelected) {
        fail('verifyNoColorIsSelected has failed, ${widget.color} is selected');
      }
    }

    final customColorFinder = find.byType(
      ColorPaletteCustomColor,
      skipOffstage: false,
    );
    final customColorIterator = customColorFinder.evaluate().iterator;
    while (customColorIterator.moveNext()) {
      final widget =
          customColorIterator.current.widget as ColorPaletteCustomColor;

      if (widget.isSelected) {
        fail('verifyNoColorIsSelected has failed, ${widget.color} is selected');
      }
    }
  }
}
