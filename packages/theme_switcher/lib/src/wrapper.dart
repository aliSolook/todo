// part of '../theme_switcher.dart';

// class ThemeSwitcher extends StatefulWidget {
//   const ThemeSwitcher({
//     super.key,
//     required this.builder,
//     this.placeHolderSize = const Size(25, 25),
//   });

//   final Widget Function(BuildContext context, ThemeManager themeManager)
//   builder;
//   final Size? placeHolderSize;

//   static ThemeSwitcherAreaState of(BuildContext context) =>
//       _ThemeSwitcherAreaInherited.of(context);

//   static ThemeMode currentMode(BuildContext context) =>
//       _ThemeSwitcherBaseInherited.of(context).themeMode;

//   static ThemeMode nextMode(BuildContext context) =>
//       _ThemeSwitcherBaseInherited.of(context).themeMode;

//   @override
//   State<ThemeSwitcher> createState() => _ThemeSwitcherState();
// }

// class _ThemeSwitcherState extends State<ThemeSwitcher> with RouteAware {
//   final themeSwitcherButtonKey = GlobalKey<State<StatefulWidget>>();
//   ThemeSwitcherAreaState? _areaState;
//   ThemeSwitcherAreaState get areaState {
//     _areaState ??= _ThemeSwitcherAreaInherited.of(context);
//     return _areaState!;
//   }

//   _ThemeSwitcherBaseState? _baseState;
//   _ThemeSwitcherBaseState get baseState {
//     _baseState ??= _ThemeSwitcherBaseInherited.of(context);
//     return _baseState!;
//   }

//   bool animationInvokedByMe = false;
//   var latesTapOffset = Offset.zero;
//   final link = LayerLink();
//   late final OverlayEntry entry;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.placeHolderSize != null) setupOverlay();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     baseState.rotueObserver.subscribe(
//       this,
//       ModalRoute.of(context) as PageRoute,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();

//     baseState.rotueObserver.unsubscribe(this);

//     entry.remove();
//     entry.dispose();
//   }

//   @override
//   void didPushNext() {
//     entry.remove();
//   }

//   // Called when the screen above this one is popped
//   @override
//   void didPopNext() {
//     if (!entry.mounted) insertOverlay();
//   }

//   @override
//   Widget build(BuildContext context) {
//     themeSwitcherButtonKey.currentState?.setState(() {});
//     if (widget.placeHolderSize != null) {
//       return CompositedTransformTarget(
//         link: link,
//         child: SizedBox.fromSize(size: widget.placeHolderSize),
//       );
//     } else {
//       return buildMainChild();
//     }
//   }

//   Widget buildMainChild() {
//     return Listener(
//       onPointerDown: (event) => latesTapOffset = event.position,
//       child: Builder(
//         key: themeSwitcherButtonKey,
//         builder: (context) {
//           return widget.builder(context, ThemeManager._(this));
//         },
//       ),
//     );
//   }

//   void changeTheme(
//     ThemeMode newMode, {
//     Duration? duration,
//     Offset? tapOffset,
//     bool? reversed,
//   }) async {
//     animationInvokedByMe = true;
//     await areaState.changeTheme(
//       newMode: newMode,
//       animationDuration: duration,
//       tapOffset: tapOffset ?? latesTapOffset,
//       reversed: reversed ?? false,
//     );
//     animationInvokedByMe = false;
//   }

//   void setupOverlay() {
//     entry = OverlayEntry(
//       builder: (context) {
//         return Positioned(
//           top: -9999999999,
//           left: -9999999999,
//           child: CompositedTransformFollower(
//             followerAnchor: Alignment.center,
//             targetAnchor: Alignment.center,
//             link: link,
//             child: buildMainChild(),
//           ),
//         );
//       },
//     );

//     insertOverlay();
//   }

//   void insertOverlay() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       if (!entry.mounted) {
//         await Future.delayed(Duration.zero);
//         if (mounted) {
//           Overlay.maybeOf(context)?.insert(entry);
//         }
//       }
//     });
//   }

//   ThemeMode get nextTheme {
//     final themes = baseState.widget.availableThemeModees;
//     final currentThemeIndex = themes.indexOf(baseState.themeMode);
//     return themes[(currentThemeIndex + 1) % themes.length];
//   }

//   void toggleTheme({Duration? duration, Offset? tapOffset, bool? reversed}) {
//     changeTheme(
//       nextTheme,
//       duration: duration,
//       tapOffset: tapOffset,
//       reversed: reversed,
//     );
//   }

//   // @override
//   // void didUpdateWidget(covariant ThemeSwitcher oldWidget) {
//   //   super.didUpdateWidget(oldWidget);

//   //   print('inside the callback');
//   //   // final box = key.currentContext!.findRenderObject() as RenderBox;
//   //   // print('setting state');
//   //   // placeHolderKey.currentState!.setState(() {
//   //   //   placeHolderSize = box.constraints.biggest;
//   //   // });
//   // }
// }

// final class ThemeManager {
//   final _ThemeSwitcherState _state;
//   ThemeManager._(this._state);

//   void change(
//     ThemeMode newMode, {
//     Duration? duration,
//     Offset? tapOffset,
//     bool? reversed,
//   }) {
//     _state.changeTheme(
//       newMode,
//       duration: duration,
//       tapOffset: tapOffset,
//       reversed: reversed,
//     );
//   }

//   void toggle({Duration? duration, Offset? tapOffset, bool? reversed}) {
//     _state.toggleTheme(
//       duration: duration,
//       tapOffset: tapOffset,
//       reversed: reversed,
//     );
//   }

//   ThemeMode get currentMode => _state.baseState.themeMode;
//   ThemeMode get nextMode => _state.nextTheme;
// }

part of '../theme_switcher.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({
    super.key,
    required this.builder,
    // this.placeHolderSize = const Size.square(40),
    this.placeHolderSize,
  });

  final Widget Function(
    BuildContext context,
    ThemeManager themeManager,
    bool shouldAnimate,
  )
  builder;
  final Size? placeHolderSize;

  static ThemeSwitcherAreaState of(BuildContext context) =>
      _ThemeSwitcherAreaInherited.of(context);

  static ThemeMode currentMode(BuildContext context) =>
      _ThemeSwitcherBaseInherited.of(context).themeMode;

  static ThemeMode nextMode(BuildContext context) =>
      _ThemeSwitcherBaseInherited.of(context).themeMode;

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  ThemeSwitcherAreaState? _areaState;
  ThemeSwitcherAreaState get areaState {
    _areaState ??= _ThemeSwitcherAreaInherited.of(context);
    return _areaState!;
  }

  _ThemeSwitcherBaseState? _baseState;
  _ThemeSwitcherBaseState get baseState {
    _baseState ??= _ThemeSwitcherBaseInherited.of(context);
    return _baseState!;
  }

  late ThemeMode currentTheme;
  late ThemeMode previousTheme;

  bool animationInvokedByMe = false;
  var latesTapOffset = Offset.zero;
  final link = LayerLink();
  final overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();

    baseState.addListener(_onThemeChanged);
    previousTheme = currentTheme = baseState.themeMode;
  }

  @override
  void dispose() {
    super.dispose();

    baseState.removeListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (!mounted) return;
    setState(() {
      previousTheme = currentTheme;
      currentTheme = baseState.themeMode;
    });
  }

  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (!animationInvokedByMe) {
      return SizedBox(key: key, child: buildMainChild());
      // return SizedBox(key: key, child: buildMainChild());
    }
    return OverlayPortal(
      controller: overlayController,
      overlayChildBuilder: (context) => Center(
        child: CompositedTransformFollower(
          link: link,
          followerAnchor: Alignment.center,
          targetAnchor: Alignment.center,
          child: SizedBox.fromSize(
            key: key,
            size: widget.placeHolderSize,
            child: buildMainChild(),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: link,
        child: widget.placeHolderSize == null
            ? Visibility(
                visible: false,
                maintainSize: true,
                child: buildMainChild(),
              )
            : SizedBox.fromSize(size: widget.placeHolderSize),
      ),
    );
  }

  Widget buildMainChild() {
    return Listener(
      onPointerDown: (event) => latesTapOffset = event.position,
      child: Builder(
        builder: (context) {
          final willAnimate = areaState.themeEquals(
            previousTheme,
            currentTheme,
          );
          return widget.builder(
            context,
            ThemeManager._(this),
            willAnimate || animationInvokedByMe,
            // true,
          );
        },
      ),
    );
  }

  void changeTheme(
    ThemeMode newMode, {
    Duration? duration,
    Offset? tapOffset,
    bool? reversed,
  }) async {
    if (!areaState.willAnimate(newMode)) {
      areaState.changeTheme(
        newMode: newMode,
        animationDuration: duration,
        tapOffset: tapOffset ?? latesTapOffset,
        reversed: reversed ?? false,
      );
      return;
    }

    setState(() => animationInvokedByMe = true);
    overlayController.show();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await areaState.changeTheme(
        newMode: newMode,
        animationDuration: duration,
        tapOffset: tapOffset ?? latesTapOffset,
        reversed: reversed ?? false,
      );

      overlayController.hide();
      setState(() => animationInvokedByMe = false);
    });
  }

  ThemeMode get nextTheme {
    final themes = baseState.widget.availableThemeModees;
    final currentThemeIndex = themes.indexOf(baseState.themeMode);
    return themes[(currentThemeIndex + 1) % themes.length];
  }

  void toggleTheme({Duration? duration, Offset? tapOffset, bool? reversed}) {
    changeTheme(
      nextTheme,
      duration: duration,
      tapOffset: tapOffset,
      reversed: reversed,
    );
  }
}

final class ThemeManager {
  final _ThemeSwitcherState _state;
  ThemeManager._(this._state);

  void change(
    ThemeMode newMode, {
    Duration? duration,
    Offset? tapOffset,
    bool? reversed,
  }) {
    _state.changeTheme(
      newMode,
      duration: duration,
      tapOffset: tapOffset,
      reversed: reversed,
    );
  }

  void toggle({Duration? duration, Offset? tapOffset, bool? reversed}) {
    _state.toggleTheme(
      duration: duration,
      tapOffset: tapOffset,
      reversed: reversed,
    );
  }

  ThemeMode get currentMode => _state.baseState.themeMode;
  ThemeMode get nextMode => _state.nextTheme;
}
