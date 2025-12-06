part of 'image_selector_bloc.dart';

@immutable
sealed class ImageSelectorEvent {
  const ImageSelectorEvent();
}

final class ImageSelectorLoadImagesRequested extends ImageSelectorEvent {}

final class ImageSelectorCancelLoadImagesRequested extends ImageSelectorEvent {}

final class ImageSelectorDisposed extends ImageSelectorEvent {}

final class ImageSelectorOrderChanged extends ImageSelectorEvent {
  final ImageSelectorOrder order;

  const ImageSelectorOrderChanged(this.order);
}

final class ImageSelectorSearchTextChanged extends ImageSelectorEvent {
  final String searchText;
  final bool withDelay;

  const ImageSelectorSearchTextChanged(
    this.searchText, [
    this.withDelay = true,
  ]);
}
