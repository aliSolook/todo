part of 'image_add_screen_bloc.dart';

typedef SubmitResult = Either<String, List<ImageWrapper>>;

enum ImageAddScreenStatus {
  init,
  inProgress,
  failure,
  success;

  bool get isInit => this == ImageAddScreenStatus.init;
  bool get isInProgress => this == ImageAddScreenStatus.inProgress;
  bool get isFailure => this == ImageAddScreenStatus.failure;
  bool get isSuccess => this == ImageAddScreenStatus.success;
}

final class ImageAddScreenState extends Equatable {
  final dynamic id;
  final String title;
  final Uint8List? image;
  final String? titleError;
  final String? imageError;
  final String? error;

  final ImageAddScreenStatus status;

  const ImageAddScreenState({
    this.id,
    this.title = '',
    this.imageError,
    this.titleError,
    this.error,
    this.status = ImageAddScreenStatus.init,
    this.image,
  });

  ImageAddScreenState copyWith({
    dynamic id,
    String? title,
    Either<Null, Uint8List?> image = const Left(null),
    Either<Null, String?> titleError = const Left(null),
    Either<Null, String?> imageError = const Left(null),
    Either<Null, String?> error = const Left(null),
    ImageAddScreenStatus? status,
  }) => ImageAddScreenState(
    id: id ?? this.id,
    title: title ?? this.title,
    image: image.getOrElse(() => this.image),
    titleError: titleError.getOrElse(() => this.titleError),
    imageError: imageError.getOrElse(() => this.imageError),
    error: error.getOrElse(() => this.error),
    status: status ?? this.status,
  );

  bool get isEditing => id != null;

  @override
  List<Object?> get props => [
    id,
    title,
    image,
    titleError,
    imageError,
    error,
    status,
  ];
}
