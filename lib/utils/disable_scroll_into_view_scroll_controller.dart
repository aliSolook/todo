import 'package:flutter/widgets.dart';

class DisableScrollIntoViewScrollController extends ScrollController {
  // Causes early return from EditableText._showCaretOnScreen, preventing focus
  // gain from making the CustomScrollView jump to the top.
  @override
  bool get hasClients => false;
}