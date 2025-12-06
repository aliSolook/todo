import 'package:flutter/material.dart';
import 'package:theme_switcher/theme_switcher.dart';
import 'package:todo/constants/durations.dart';
import 'package:todo/features/widgets/widgets.dart';

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(
      builder: (context, themeManager, shouldAnimate) => IconButton(
        onPressed: themeManager.toggle,
        icon: AnimatedThemeIcon(
          animationDuration: shouldAnimate ? animationDuration : Duration.zero,
          themeMode: themeManager.nextMode,
        ),
      ),
    );
  }
}
