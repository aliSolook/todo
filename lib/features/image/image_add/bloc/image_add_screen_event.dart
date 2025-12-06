// ignore_for_file: library_private_types_in_public_api

part of 'image_add_screen_bloc.dart';

sealed class ImageAddScreenEvent {
  const ImageAddScreenEvent();
}

mixin _NoValueEventMixin {}

mixin _WithValueEventMixin<T> {
  T get value;
}

final class _WithValueEventImpl<T> extends ImageAddScreenEvent {
  final T value;
  const _WithValueEventImpl(this.value);
}

final class ImageAddScreenTitleFocusChanged = _WithValueEventImpl<bool>
    with _WithValueEventMixin<bool>;

final class ImageAddScreenTitleChanged = _WithValueEventImpl<String>
    with _WithValueEventMixin<String>;

final class ImageAddScreenImageChanged = _WithValueEventImpl<Uint8List?>
    with _WithValueEventMixin<Uint8List?>;

final class ImageAddScreenSubmitted = ImageAddScreenEvent
    with _NoValueEventMixin;

final class ImageAddScreenReset = ImageAddScreenEvent with _NoValueEventMixin;
