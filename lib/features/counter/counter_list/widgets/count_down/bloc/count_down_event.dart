part of 'count_down_bloc.dart';

sealed class CountDownEvent {
  const CountDownEvent();
}

final class CountDownDurationUpdateRequested extends CountDownEvent {
  final Duration duration;
  const CountDownDurationUpdateRequested(this.duration);
}

final class CountDownPausePressed extends CountDownEvent {
  final double passed;
  const CountDownPausePressed(this.passed);
}

final class CountDownResumePressed extends CountDownEvent {
  const CountDownResumePressed();
}

final class CountDownFinished extends CountDownEvent {
  const CountDownFinished();
}

final class CountDownRestartPressed extends CountDownEvent {
  const CountDownRestartPressed();
}
