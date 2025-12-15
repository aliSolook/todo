import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:todo/utils/image_base_color_finder.dart';

part 'category_add_event.dart';
part 'category_add_state.dart';

class CategoryAddScreenBloc
    extends Bloc<CategoryAddScreenEvent, CategoryAddScreenState> {
  static const titleError = 'این فیلد اجباری است';

  final CategoryRepository _categoryRepository = locator.get();
  final CustomColorRepository _customColorRepository = locator.get();

  CategoryAddScreenBloc([
    super.initialState = const CategoryAddScreenState.init(),
  ]) {
    on<CategoryAddScreenCustomColorsLoadRequested>(_customColorsLoadRequested);
    on<CategoryAddScreenTitleFocusChanged>(_titleFocusChanged);
    on<CategoryAddScreenTitleChanged>(_titleChanged);
    on<CategoryAddScreenImageChanged>(_imageChanged);
    on<CategoryAddScreenColorChanged>(_colorChanged);
    on<CategoryAddScreenCustomColorAdded>(_customColorAdded);
    on<CategoryAddScreenCustomColorDeleteRequested>(
      _customColorDeleteRequested,
    );
    on<CategoryAddScreenSubmitted>(_submitted);
    on<CategoryAddScreenResetRequested>(_reset);
  }

  void _customColorsLoadRequested(
    CategoryAddScreenCustomColorsLoadRequested event,
    Emitter<CategoryAddScreenState> emit,
  ) async {
    emit(state.copyWith(customColorsState: const SubState.inProgress()));

    final either = await _customColorRepository.listCustomColors();

    final newState = either.fold(
      ifLeft: (value) =>
          state.copyWith(customColorsState: SubState.failure(value)),
      ifRight: (value) =>
          state.copyWith(customColorsState: SubState.success(value)),
    );

    emit(newState);
  }

  void _titleFocusChanged(
    CategoryAddScreenTitleFocusChanged event,
    Emitter emit,
  ) {
    if (event.hasFocus || state.title.isNotEmpty) {
      emit(state.copyWith(titleError: ''));
      return;
    }

    emit(state.copyWith(titleError: titleError));
  }

  void _titleChanged(
    CategoryAddScreenTitleChanged event,
    Emitter emit,
  ) => emit(state.copyWith(title: event.value));

  void _imageChanged(
    CategoryAddScreenImageChanged event,
    Emitter emit,
  ) => emit(state.copyWith(image: Right(event.value)));

  void _colorChanged(
    CategoryAddScreenColorChanged event,
    Emitter emit,
  ) => emit(state.copyWith(color: event.value));

  void _reset(
    CategoryAddScreenResetRequested event,
    Emitter emit,
  ) => emit(
    CategoryAddScreenState.init(
      id: state.id,
      customColorDeleteState: state.customColorDeleteState,
      customColorsState: state.customColorsState,
      submitState: state.submitState,
    ),
  );

  void _customColorAdded(
    CategoryAddScreenCustomColorAdded event,
    Emitter<CategoryAddScreenState> emit,
  ) {
    if (!state.customColorsState.isSuccess) return;

    emit(
      state.copyWith(
        customColorsState: SubState.success(
          state.customColorsState.value.followedBy([event.value]).toList(),
        ),
      ),
    );
  }

  void _customColorDeleteRequested(
    CategoryAddScreenCustomColorDeleteRequested event,
    Emitter<CategoryAddScreenState> emit,
  ) async {
    if (state.customColorDeleteState.isInProgress(event.value)) return;
    emit(
      state.copyWith(
        customColorDeleteState: state.customColorDeleteState.copyAdd(
          ListableDeleteState(
            status: StateStatus.inProgress,
            item: event.value,
          ),
        ),
      ),
    );

    final either = await _customColorRepository.deleteCustomColor(event.value);

    final newState = either.fold(
      ifLeft: (error) => state.copyWith(
        customColorDeleteState: state.customColorDeleteState.copyUpdate(
          ListableDeleteState(status: StateStatus.failure, item: event.value),
        ),
      ),
      ifRight: (_) {
        final currentColor = state.customColorsState.either
            .orNull()
            ?.firstWhere((e) => e.id == event.value)
            .color;
        final isThisColorSelected = currentColor == state.color;
        return state.copyWith(
          color: isThisColorSelected ? -1 : null,
          customColorDeleteState: state.customColorDeleteState.copyUpdate(
            ListableDeleteState(status: StateStatus.success, item: event.value),
          ),
          customColorsState: !state.customColorsState.isSuccess
              ? null
              : SubState.success(
                  state.customColorsState.value
                      .where((e) => e.id != event.value)
                      .toList(),
                ),
        );
      },
    );

    emit(newState);
    emit(
      state.copyWith(
        customColorDeleteState: state.customColorDeleteState.copyRemove(
          ListableDeleteState(status: StateStatus.success, item: event.value),
        ),
      ),
    );
  }

  void _submitted(
    CategoryAddScreenSubmitted event,
    Emitter emit,
  ) async {
    final titleHasError = state.title.isEmpty;

    if (titleHasError) {
      return emit(state.copyWith(titleError: titleHasError ? titleError : ''));
    }

    emit(state.copyWith(submitState: const SubState.inProgress()));

    final int color;
    if (state.color < 0 && state.image != null) {
      color = await ImageBaseColorFinder(locator.get()).getColor(state.image);
    } else {
      color = state.color < 0 ? -1 : state.color;
    }

    final category = CategoryWrapper(
      id: state.id,
      title: state.title,
      image: state.image,
      color: color,
    );

    final either = await (state.isEditing
        ? _categoryRepository.updateCategory(category)
        : _categoryRepository.addCategory(category.toCategory()));

    either.fold(
      ifLeft: (value) {
        emit(state.copyWith(submitState: SubState.failure(value)));
      },
      ifRight: (id) {
        emit(
          state.copyWith(
            submitState: SubState.success(
              state.isEditing ? category : category.copyWith(id: id),
            ),
          ),
        );
      },
    );
  }
}
