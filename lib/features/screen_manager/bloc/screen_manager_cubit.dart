import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'screen_manager_state.dart';

final class ScreenManagerCubit extends Cubit<ScreenManagerState> {
  ScreenManagerCubit() : super(const ScreenManagerState());

  void screenChanged(int index) {
    final isVisible = state.initiatedTabs.contains(index)
        ? state.fabCallbacks.containsKey(index)
        : null;

    if (isVisible != null) {
      emit(
        state.copyWith(
          selectedIndex: index,
          isFabVisible: isVisible,
        ),
      );
    } else {
      emit(state.copyWith(selectedIndex: index));
    }
  }

  void scrolled(ScrollUpdateNotification notification) {
    if (notification.depth > 0) return;

    final isVisible =
        notification.scrollDelta!.isNegative &&
        state.fabCallbacks.containsKey(state.selectedIndex);

    if (isVisible != state.isFabVisible) {
      emit(state.copyWith(isFabVisible: isVisible));
    }
  }

  void scrollMetricsChanged(
    ScrollMetricsNotification notification,
    Size screenSize,
  ) {
    if (notification.depth > 0) return;

    final isScrollable = notification.metrics.extentTotal > screenSize.height;

    if (isScrollable) return;

    final isVisible = isScrollable
        ? null
        : state.initiatedTabs.contains(state.selectedIndex)
        ? state.fabCallbacks.containsKey(state.selectedIndex)
        : null;

    if (isVisible != null && isVisible != state.isFabVisible) {
      emit(state.copyWith(isFabVisible: isVisible));
    }
  }

  void updateFabCallback(int index, FabCallback? callback) {
    if (!state.initiatedTabs.contains(index)) throw 'tab not initated';

    final fabCallbacks = Map.of(state.fabCallbacks);

    final keyExists = fabCallbacks.containsKey(index);

    fabCallbacks[index] = callback;

    if (!keyExists) {
      if (index == state.selectedIndex) {
        emit(state.copyWith(isFabVisible: true, fabCallbacks: fabCallbacks));
      }
    } else {
      if (index == state.selectedIndex && state.isFabVisible) {
        emit(
          state.copyWith(fabCallbacks: fabCallbacks),
        ); // just updating the fab to update its onPressed
      }
    }
  }

  void removeFabCallback(int index) {
    if (!state.initiatedTabs.contains(index)) throw 'tab not initated';
    if (!state.fabCallbacks.containsKey(index)) return;

    final fabCallbacks = Map.of(state.fabCallbacks);

    fabCallbacks.remove(index);

    if (index == state.selectedIndex && state.isFabVisible) {
      emit(state.copyWith(isFabVisible: false, fabCallbacks: fabCallbacks));
    }
  }

  void initiateTab(
    int index, {
    required bool showFab,
    FabCallback? fabCallback,
  }) {
    var initiatedTabs = state.initiatedTabs;
    if (!initiatedTabs.contains(index)) {
      initiatedTabs = initiatedTabs.followedBy([index]).toList();
    }

    var fabCallbacks = state.fabCallbacks;
    if (showFab) {
      fabCallbacks = Map.of(fabCallbacks);
      fabCallbacks[index] = fabCallback;
    }

    emit(
      state.copyWith(
        isFabVisible: state.selectedIndex != index ? null : showFab,
        fabCallbacks: fabCallbacks,
        initiatedTabs: initiatedTabs,
      ),
    );
  }
}
