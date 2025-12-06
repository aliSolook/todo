part of 'category_add_bloc.dart';

sealed class CategoryAddScreenEvent {
  const CategoryAddScreenEvent();
}

final class CategoryAddScreenTitleFocusChanged extends CategoryAddScreenEvent {
  final bool hasFocus;

  const CategoryAddScreenTitleFocusChanged(this.hasFocus);
}

final class CategoryAddScreenTitleChanged extends CategoryAddScreenEvent {
  final String value;

  const CategoryAddScreenTitleChanged(this.value);
}

final class CategoryAddScreenImageChanged extends CategoryAddScreenEvent {
  final dynamic value;

  const CategoryAddScreenImageChanged(this.value);
}

final class CategoryAddScreenColorChanged extends CategoryAddScreenEvent {
  final int value;

  const CategoryAddScreenColorChanged(this.value);
}

final class CategoryAddScreenCustomColorAdded extends CategoryAddScreenEvent {
  final CustomColorWrapper value;

  const CategoryAddScreenCustomColorAdded(this.value);
}

final class CategoryAddScreenCustomColorDeleteRequested
    extends CategoryAddScreenEvent {
  final dynamic value;

  const CategoryAddScreenCustomColorDeleteRequested(this.value);
}

final class CategoryAddScreenSubmitted extends CategoryAddScreenEvent {
  const CategoryAddScreenSubmitted();
}

final class CategoryAddScreenReset extends CategoryAddScreenEvent {
  const CategoryAddScreenReset();
}

final class CategoryAddScreenCustomColorsLoadRequested
    extends CategoryAddScreenEvent {
  const CategoryAddScreenCustomColorsLoadRequested();
}
