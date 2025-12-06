import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'count_down_event.dart';
part 'count_down_state.dart';

final class CountDownBloc extends Bloc<CountDownEvent, CountDownState> {
  CountDownBloc([super.initialState = const CountDownState()]) {
    on<CountDownDurationUpdateRequested>(_durationUpdateRequested);
    on<CountDownPausePressed>(_pausePressed);
    on<CountDownResumePressed>(_resumePressed);
    on<CountDownFinished>(_finished);
    on<CountDownRestartPressed>(_restartPressed);
  }

  void _durationUpdateRequested(
    CountDownDurationUpdateRequested event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(
        duration: event.duration,
        passed: 0,
        status: CountDownStatus.setDuration,
      ),
    );
  }

  void _pausePressed(
    CountDownPausePressed event,
    Emitter emit,
  ) async {
    if (state.status.isPaused) return;
    emit(
      state.copyWith(status: CountDownStatus.paused, passed: event.passed),
    );
  }

  void _resumePressed(
    CountDownResumePressed event,
    Emitter emit,
  ) {
    if (state.status.isRunning) return;
    emit(state.copyWith(status: CountDownStatus.running));
  }

  void _finished(
    CountDownFinished event,
    Emitter emit,
  ) async {
    if (state.status.isDone) return;
    emit(state.copyWith(status: CountDownStatus.done, passed: 1));
  }

  void _restartPressed(
    CountDownRestartPressed event,
    Emitter emit,
  ) async {
    emit(state.copyWith(status: CountDownStatus.running, passed: 0));
  }
}
