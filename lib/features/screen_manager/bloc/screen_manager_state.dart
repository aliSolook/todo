part of 'screen_manager_cubit.dart';

typedef FabCallback = void Function();

final class ScreenManagerState extends Equatable {
  final Map<int, FabCallback?> fabCallbacks;
  final bool isFabVisible;
  final List<int> initiatedTabs;
  final int selectedIndex;

  const ScreenManagerState({
    this.fabCallbacks = const {},
    this.initiatedTabs = const [],
    this.selectedIndex = 0,
    this.isFabVisible = false,
  });

  ScreenManagerState copyWith({
    Map<int, FabCallback?>? fabCallbacks,
    List<int>? initiatedTabs,
    int? selectedIndex,
    bool? isFabVisible,
  }) {
    return ScreenManagerState(
      fabCallbacks: fabCallbacks ?? this.fabCallbacks,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isFabVisible: isFabVisible ?? this.isFabVisible,
      initiatedTabs: initiatedTabs ?? this.initiatedTabs,
    );
  }

  @override
  List<Object?> get props => [
    fabCallbacks.entries.toList(),
    initiatedTabs,
    selectedIndex,
    isFabVisible,
  ];
}
