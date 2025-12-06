import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/image/models/image_wrapper.dart';
import 'package:todo/features/image/repository/image_repository.dart';
import 'package:todo/di/di.dart';
import 'package:todo/utils/search_comparator.dart';

part 'image_selector_event.dart';
part 'image_selector_state.dart';

final class ImageSelectorBloc
    extends Bloc<ImageSelectorEvent, ImageSelectorState> {
  final ImageRepository _repository = locator();
  StreamSubscription? _listSubscription;
  Completer<bool> _searchDelay = Completer()..complete(false);

  ImageSelectorBloc([ImageSelectorState? initialState])
    : super(initialState ?? ImageSelectorState()) {
    on<ImageSelectorLoadImagesRequested>(_onLoadImages);
    on<ImageSelectorCancelLoadImagesRequested>(_onCancelLoadImages);
    on<ImageSelectorSearchTextChanged>(_onSearchTextChanged);
    on<ImageSelectorOrderChanged>(_onOrderChanged);
    on<ImageSelectorDisposed>(_onDisposed);
  }

  void _onLoadImages(
    ImageSelectorLoadImagesRequested event,
    Emitter emit,
  ) async {
    _listSubscription?.cancel();
    state._images.clear();
    state._sortedImages.clear();
    emit(state.copyWith(status: ImageSelectorStatus.loading));

    final images = await _repository.listImages();

    final newState = images.fold(
      ifLeft: (value) =>
          state.copyWith(error: value, status: ImageSelectorStatus.failure),
      ifRight: (value) {
        state._images.clear();
        state._images.addAll(value);
        _sort();
        return state.copyWith(
          status: ImageSelectorStatus.success,
        );
      },
    );

    emit(newState);
  }

  void _onCancelLoadImages(
    ImageSelectorCancelLoadImagesRequested event,
    Emitter emit,
  ) {
    _listSubscription?.cancel();
  }

  void _onOrderChanged(
    ImageSelectorOrderChanged event,
    Emitter emit,
  ) {
    _sort(order: event.order);
    emit(state.copyWith(order: event.order));
  }

  void _onSearchTextChanged(
    ImageSelectorSearchTextChanged event,
    Emitter emit,
  ) async {
    // canceling the previous search delay
    if (!_searchDelay.isCompleted) _searchDelay.complete(false);

    if (event.withDelay) {
      final myCompleter = _searchDelay = Completer();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!myCompleter.isCompleted) myCompleter.complete(true);
      });

      // search canceled
      if (!await myCompleter.future) return;
    }

    _sort(searchText: event.searchText);
    emit(state.copyWith(searchText: event.searchText));
  }

  void _onDisposed(
    ImageSelectorDisposed event,
    Emitter emit,
  ) {
    _listSubscription?.cancel();
  }

  void _sort({
    String? searchText,
    ImageSelectorOrder? order,
    bool? isAscending,
  }) {
    searchText ??= state.searchText;
    order ??= state.order;
    isAscending ??= state.isAscending;

    final comparator = WeightedSearchFilter<ImageWrapper?>.signle(
      searchText: searchText,
      converter: (e) => e!.title,
    );

    int sortComparator(ImageWrapper? a, ImageWrapper? b) {
      final multiplier = isAscending! ? 1 : -1;

      if (a == b) return 0;
      if (a == null) return 1 * multiplier;
      if (b == null) return -1 * multiplier;

      return comparator.compare(a, b) * multiplier;
    }

    final list = order.isCreated && !isAscending
        ? state._images.reversed
        : state._images;

    state._sortedImages.clear();
    state._sortedImages.addAll(
      searchText.isEmpty
          ? list
          : comparator.filter(list.where((e) => e != null).toList()).cast(),
    );

    if (!order.isCreated || searchText.isNotEmpty) {
      state._sortedImages.sort(sortComparator);
    }
  }
}
