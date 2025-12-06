import 'package:flutter/material.dart';
import 'package:todo/constants/constants.dart';

class App extends StatefulWidget {
  const App({super.key, required this.builder});

  final Widget Function(BuildContext context, RouteObserver routeObserver)
  builder;

  @override
  State<App> createState() => _AppState();

  static ThemeData _themeFromColorScheme(ColorScheme scheme) => ThemeData(
    colorScheme: scheme,
    fontFamily: 'Shabnam',
    inputDecorationTheme: InputDecorationTheme(
      errorStyle: TextStyle(
        color: scheme.error,
        fontSize: 12,
        fontFamily: 'Shabnam',
        fontWeight: FontWeight.bold,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12.5,
      ),
      isDense: true,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: -0.24,
      ),
      suffixIconConstraints: const BoxConstraints(maxWidth: 45),
      prefixIconConstraints: const BoxConstraints(maxWidth: 45),
      fillColor: scheme.surfaceContainer,
      filled: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: IconButton.styleFrom(overlayColor: scheme.primary),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(overlayColor: scheme.primary),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(overlayColor: scheme.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        overlayColor: scheme.primary,
        backgroundColor: scheme.primaryContainer,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(overlayColor: scheme.primary),
    ),
    splashColor: scheme.primary.withAlpha(50),
    appBarTheme: AppBarTheme(
      actionsPadding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      backgroundColor: scheme.surfaceContainer,
      foregroundColor: scheme.onSurface,
      elevation: 3,
      shadowColor: scheme.shadow,
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: scheme.surfaceContainer,
      elevation: 3,
      shadowColor: scheme.shadow,
    ),
  );

  static final lightTheme = _themeFromColorScheme(App.lightScheme);
  static final darkTheme = _themeFromColorScheme(App.darkScheme);

  static final lightScheme = ColorScheme.light(
    primary: CustomColors.green,
    onPrimary: Colors.white,
    primaryContainer: CustomColors.lightGreen,
    onPrimaryContainer: CustomColors.green,

    secondary: CustomColors.blue,
    onSecondary: Colors.white,
    secondaryContainer: CustomColors.blue.withAlpha(25),
    error: CustomColors.red,
    onError: Colors.white,

    surface: CustomColors.background,
    onSurface: CustomColors.black,
    surfaceContainer: Colors.white,
    surfaceContainerHigh: CustomColors.mediumGreen,
    onSurfaceVariant: CustomColors.grey,

    outline: CustomColors.grey,
    shadow: Colors.black,
  );

  static final darkScheme = ColorScheme.dark(
    primary: CustomColors.green,
    onPrimary: Colors.white,
    primaryContainer: CustomColors.darkGreen,
    onPrimaryContainer: CustomColors.green,

    secondary: CustomColors.blue,
    onSecondary: Colors.white,
    secondaryContainer: CustomColors.blue.withAlpha(25),
    error: CustomColors.red,
    onError: Colors.white,

    surface: CustomColors.darkBackground,
    onSurface: Colors.white,
    surfaceContainer: CustomColors.darkSurfaceContainer,
    surfaceContainerHigh: CustomColors.mediumGreen,
    onSurfaceVariant: CustomColors.darkGrey,
    outline: CustomColors.darkGrey,
    shadow: Colors.black,
  );

  static List<BoxShadow> cardBoxShadow(
    BuildContext context, {
    Color? color,
    double blurStrength = 1,
  }) {
    color ??= ColorScheme.of(context).shadow;
    return [
      BoxShadow(
        color: color.withAlpha((5 * blurStrength).round().clamp(0, 255)),
      ),
      BoxShadow(
        color: color.withAlpha((5 * blurStrength).round().clamp(0, 255)),
        blurRadius: 23,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: color.withAlpha((5 * blurStrength).round().clamp(0, 255)),
        blurRadius: 42,
        offset: const Offset(0, 42),
      ),
      BoxShadow(
        color: color.withAlpha((3 * blurStrength).round().clamp(0, 255)),
        blurRadius: 56,
        offset: const Offset(0, 94),
      ),
    ];
  }

  static RouteObserver observerOf(BuildContext context) => context
      .getInheritedWidgetOfExactType<_AppInheritedWidget>()!
      .state
      .observer;
}

class _AppState extends State<App> {
  final observer = RouteObserver();

  @override
  Widget build(BuildContext context) {
    return _AppInheritedWidget(
      state: this,
      child: widget.builder(context, observer),
    );
  }
}

class _AppInheritedWidget extends InheritedWidget {
  final _AppState state;

  const _AppInheritedWidget({required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
