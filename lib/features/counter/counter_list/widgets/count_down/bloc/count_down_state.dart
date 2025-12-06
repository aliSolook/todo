part of 'count_down_bloc.dart';

enum CountDownStatus {
  none,
  setDuration,
  done,
  paused,
  running;

  bool get isNone => this == CountDownStatus.none;
  bool get isSetDuration => this == CountDownStatus.setDuration;
  bool get isDone => this == CountDownStatus.done;
  bool get isPaused => this == CountDownStatus.paused;
  bool get isRunning => this == CountDownStatus.running;
}

final class CountDownState extends Equatable {
  final Duration duration;
  final double passed;
  final CountDownStatus status;

  const CountDownState({
    this.status = CountDownStatus.none,
    this.duration = Duration.zero,
    this.passed = 1,
  });

  CountDownState copyWith({
    Duration? duration,
    double? passed,
    CountDownStatus? status,
  }) {
    return CountDownState(
      duration: duration ?? this.duration,
      passed: passed ?? this.passed,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [duration, passed, status];
}
