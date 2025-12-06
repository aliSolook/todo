part of '../theme_switcher.dart';

class ThemeSwitcherBase extends StatefulWidget {
  const ThemeSwitcherBase({
    super.key,
    required this.builder,
    this.initThemeMode = ThemeMode.system,
    this.availableThemeModees = const [
      ThemeMode.dark,
      ThemeMode.light,
      ThemeMode.system,
    ],
  });

  final ThemeMode initThemeMode;
  final List<ThemeMode> availableThemeModees;
  final Widget Function(
    BuildContext context,
    ThemeMode themeMode,
    RouteObserver<PageRoute> routeObserver,
  )
  builder;

  @override
  State<ThemeSwitcherBase> createState() => _ThemeSwitcherBaseState();
}

class _ThemeSwitcherBaseState extends State<ThemeSwitcherBase>
    with ChangeNotifier {
  late ThemeMode _themeMode = widget.initThemeMode;
  final rotueObserver = RouteObserver<PageRoute>();

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;

  void switchTheme(ThemeMode newMode) => setState(() => themeMode = newMode);

  @override
  Widget build(BuildContext context) {
    final effectiveMode = themeMode != ThemeMode.system
        ? themeMode
        : _getSystemTheme(context);
    return _ThemeSwitcherBaseInherited(
      this,
      child: widget.builder(context, effectiveMode, rotueObserver),
    );
  }
}

ThemeMode _getSystemTheme(BuildContext context, [bool subscribe = false]) {
  final Brightness? brightness;

  if (subscribe) {
    brightness = MediaQuery.platformBrightnessOf(context);
  } else {
    brightness = context
        .getInheritedWidgetOfExactType<MediaQuery>()
        ?.data
        .platformBrightness;
  }

  if (brightness == null) return ThemeMode.system;
  return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
}

class _ThemeSwitcherBaseInherited extends InheritedWidget {
  const _ThemeSwitcherBaseInherited(this._state, {required super.child});

  final _ThemeSwitcherBaseState _state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static _ThemeSwitcherBaseState of(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<_ThemeSwitcherBaseInherited>()!
        ._state;
  }
}
