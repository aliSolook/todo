import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/counter/counter.dart';
part 'counter_add_screen_event.dart';
part 'counter_add_screen_state.dart';

final class CounterAddScreenBloc
    extends Bloc<CounterAddScreenEvent, CounterAddScreenState> {
  static const durationError = 'زمان انتخاب شده باید از \'0\' ثانیه بیشتر باشد';
  static const titleError = 'این فیلد اجباری است';
  static const initDuration = Duration(minutes: 15);

  final CounterRepository _repository = locator.get();

  CounterAddScreenBloc([super.initialState = const CounterAddScreenState()]) {
    on<CounterAddScreenTitleFocusChanged>(_titleFocusChanged);
    on<CounterAddScreenTitleChanged>(_titleChanged);
    on<CounterAddScreenDescriptionChanged>(_descriptionChanged);
    on<CounterAddScreenImageChanged>(_imageChanged);
    on<CounterAddScreenDurationFocusChanged>(_durationFocusChanged);
    on<CounterAddScreenDurationChanged>(_durationChanged);
    on<CounterAddScreenSubmitted>(_submitted);
    on<CounterAddScreenResetRequested>(_reset);
  }

  void _titleFocusChanged(
    CounterAddScreenTitleFocusChanged event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(
        titleError: Right(
          event.value || state.title.isNotEmpty ? null : titleError,
        ),
      ),
    );
  }

  void _titleChanged(
    CounterAddScreenTitleChanged event,
    Emitter emit,
  ) => emit(state.copyWith(title: event.value));

  void _descriptionChanged(
    CounterAddScreenDescriptionChanged event,
    Emitter emit,
  ) => emit(state.copyWith(description: event.value));

  void _imageChanged(
    CounterAddScreenImageChanged event,
    Emitter emit,
  ) async {
    emit(state.copyWith(image: Right(event.value)));
  }

  void _durationFocusChanged(
    CounterAddScreenDurationFocusChanged event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(
        durationError: Right(
          event.value || state.duration != Duration.zero ? null : durationError,
        ),
      ),
    );
  }

  void _durationChanged(
    CounterAddScreenDurationChanged event,
    Emitter emit,
  ) => emit(state.copyWith(duration: event.value));

  void _submitted(
    CounterAddScreenSubmitted event,
    Emitter emit,
  ) async {
    final titleHasError = state.title.isEmpty;
    final durationHasError = state.duration == Duration.zero;

    if (titleHasError || durationHasError) {
      emit(
        state.copyWith(
          titleError: Right(titleHasError ? titleError : null),
          durationError: Right(durationHasError ? durationError : null),
        ),
      );

      return;
    }

    emit(state.copyWith(status: CounterAddScreenStatus.inProgress));

    final counter = CounterWrapper(
      id: state.id,
      title: state.title,
      duration: state.duration,
      image: state.image,
      description: state.description,
    );

    final either = await (state.id != null
        ? _repository.updateCounter(counter)
        : _repository.addCounter(counter.toCounter()));

    either.fold(
      ifLeft: (value) {
        emit(
          state.copyWith(
            error: Right(value),
            status: CounterAddScreenStatus.failure,
          ),
        );
      },
      ifRight: (id) {
        id = state.id ?? id;
        emit(
          state.copyWith(
            id: id,
            status: CounterAddScreenStatus.success,
            error: const Right(null),
          ),
        );
      },
    );
  }

  void _reset(
    CounterAddScreenResetRequested event,
    Emitter emit,
  ) {
    emit(CounterAddScreenState(id: state.id));
  }
}
