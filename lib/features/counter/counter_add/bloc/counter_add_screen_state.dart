part of 'counter_add_screen_bloc.dart';

typedef SubmitResult = Either<String, MapEntry<int, Counter>>;

enum CounterAddScreenStatus {
  init,
  inProgress,
  failure,
  success;

  bool get isInit => this == CounterAddScreenStatus.init;
  bool get isInProgress => this == CounterAddScreenStatus.inProgress;
  bool get isFailure => this == CounterAddScreenStatus.failure;
  bool get isSuccess => this == CounterAddScreenStatus.success;
}

final class CounterAddScreenState extends Equatable {
  final dynamic id;
  final String title;
  final String description;
  final Duration duration;
  final dynamic image;
  final String? titleError;
  final String? durationError;
  final String? error;

  final CounterAddScreenStatus status;

  const CounterAddScreenState({
    this.id,
    this.title = '',
    this.description = '',
    this.duration = CounterAddScreenBloc.initDuration,
    this.image,
    this.titleError,
    this.durationError,
    this.status = CounterAddScreenStatus.init,
    this.error,
  });

  factory CounterAddScreenState.fromCounter(CounterWrapper? counter) {
    if (counter == null) return const CounterAddScreenState();

    return CounterAddScreenState(
      id: counter.id,
      title: counter.title,
      description: counter.description,
      duration: counter.duration,
      image: counter.image,
      status: CounterAddScreenStatus.init,
    );
  }

  CounterAddScreenState copyWith({
    dynamic id,
    String? title,
    String? description,
    Duration? duration,
    Either<Null, String?> titleError = const Left(null),
    Either<Null, String?> durationError = const Left(null),
    Either<Null, dynamic> image = const Left(null),
    Either<Null, String?> error = const Left(null),
    CounterAddScreenStatus? status,
  }) => CounterAddScreenState(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    duration: duration ?? this.duration,
    titleError: titleError.getOrElse(() => this.titleError),
    durationError: durationError.getOrElse(() => this.durationError),
    image: image.getOrElse(() => this.image),
    error: error.getOrElse(() => this.error),
    status: status ?? this.status,
  );

  bool get isEditing => id != null;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    duration,
    image,
    status,
    error,
    durationError,
    titleError,
  ];
}
