import 'dart:typed_data';
import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/image/models/image.dart';
import 'package:todo/features/image/models/image_wrapper.dart';
import 'package:todo/features/image/repository/image_repository.dart';
import 'package:todo/di/di.dart';
part 'image_add_screen_event.dart';
part 'image_add_screen_state.dart';

final class ImageAddScreenBloc
    extends Bloc<ImageAddScreenEvent, ImageAddScreenState> {
  static const titleError = 'این فیلد اجباری است';
  static const imageError = 'این فیلد اجباری است';

  final ImageRepository _repository = locator.get();

  ImageAddScreenBloc([super.initialState = const ImageAddScreenState()]) {
    on<ImageAddScreenTitleFocusChanged>(_titleFocusChanged);
    on<ImageAddScreenTitleChanged>(_titleChanged);
    on<ImageAddScreenImageChanged>(_imageChanged);
    on<ImageAddScreenSubmitted>(_submitted);
    on<ImageAddScreenReset>(_reset);
  }

  void _titleFocusChanged(
    ImageAddScreenTitleFocusChanged event,
    Emitter emit,
  ) => emit(
    state.copyWith(
      titleError: Right(
        event.value || state.title.isNotEmpty ? null : titleError,
      ),
    ),
  );

  void _titleChanged(
    ImageAddScreenTitleChanged event,
    Emitter emit,
  ) => emit(state.copyWith(title: event.value));

  void _imageChanged(
    ImageAddScreenImageChanged event,
    Emitter emit,
  ) => emit(state.copyWith(image: Right(event.value)));

  void _submitted(
    ImageAddScreenSubmitted event,
    Emitter emit,
  ) async {
    final titleHasError = state.title.isEmpty;
    final imageHasError = state.image == null;

    if (titleHasError || imageHasError) {
      emit(
        state.copyWith(
          titleError: Right(titleHasError ? titleError : null),
          imageError: Right(imageHasError ? imageError : null),
        ),
      );

      return;
    }

    emit(state.copyWith(status: ImageAddScreenStatus.inProgress));

    final image = Image(
      title: state.title,
      data: state.image ?? Uint8List(0),
    );

    final either = await (state.id != null
        ? _repository.updateImage(state.id, image)
        : _repository.addImage(image));

    either.fold(
      ifLeft: (value) {
        emit(
          state.copyWith(
            error: Right(value),
            status: ImageAddScreenStatus.failure,
          ),
        );
      },
      ifRight: (id) {
        id = state.id ?? id;
        emit(
          state.copyWith(id: id, status: ImageAddScreenStatus.success),
        );
      },
    );
  }

  void _reset(
    ImageAddScreenReset event,
    Emitter emit,
  ) {
    emit(ImageAddScreenState(id: state.id));
  }
}
