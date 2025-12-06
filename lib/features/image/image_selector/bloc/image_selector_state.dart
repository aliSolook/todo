part of 'image_selector_bloc.dart';

// enum ImageSelectorStatus { initial, loading, loaded, loadCanceled }
enum ImageSelectorStatus {
  initial,
  loading,
  failure,
  success;

  bool get isInitial => this == ImageSelectorStatus.initial;
  bool get isLoading => this == ImageSelectorStatus.loading;
  bool get isFailure => this == ImageSelectorStatus.failure;
  bool get isSuccess => this == ImageSelectorStatus.success;
}

enum ImageSelectorOrder {
  created,
  title;

  bool get isCreated => this == ImageSelectorOrder.created;
  bool get isTitle => this == ImageSelectorOrder.title;
}

final class ImageSelectorState extends Equatable {
  final List<ImageWrapper?> _images;
  final List<ImageWrapper?> _sortedImages;
  final String searchText;
  final ImageSelectorStatus status;
  final ImageSelectorOrder order;
  final String error;
  final bool isAscending;

  // List<ImageWrapper?> get images => _images;
  List<ImageWrapper?> get sortedImages => _sortedImages;

  ImageSelectorState({
    List<ImageWrapper?>? images,
    List<ImageWrapper?>? sortedImages,
    this.searchText = '',
    this.status = ImageSelectorStatus.initial,
    this.order = ImageSelectorOrder.created,
    this.isAscending = true,
    this.error = '',
  }) : _sortedImages = sortedImages ?? [],
       _images = images ?? [];

  ImageSelectorState copyWith({
    List<ImageWrapper?>? images,
    List<ImageWrapper?>? sortedImages,
    String? searchText,
    ImageSelectorStatus? status,
    ImageSelectorOrder? order,
    bool? isAscending,
    String? error,
  }) {
    return ImageSelectorState(
      images: images ?? _images,
      sortedImages: sortedImages ?? _sortedImages,
      searchText: searchText ?? this.searchText,
      status: status ?? this.status,
      order: order ?? this.order,
      isAscending: isAscending ?? this.isAscending,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    _images,
    _sortedImages,
    searchText,
    status,
    order,
    isAscending,
  ];
}
