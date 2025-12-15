import 'package:flutter/material.dart';
import 'package:todo/features/custom_color/custom_color.dart';

class ColorPaletteAction extends StatelessWidget {
  const ColorPaletteAction({
    super.key,
    this.shadowMultiplier = 1,
    this.shadowColor,
    this.forgroundColor,
    this.overrideOverlayColor = true,
    this.delay,
    this.backgroundColor,
    required this.onPressed,
    required this.icon,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? forgroundColor;
  final double shadowMultiplier;
  final bool overrideOverlayColor;
  final double? delay;

  @override
  Widget build(BuildContext context) {
    return ColorPaletteItem(
      backgroundColor:
          backgroundColor ?? ColorScheme.of(context).surfaceContainer,
      foregroundColor: forgroundColor,
      shadowColor: shadowColor ?? ColorScheme.of(context).shadow,
      delay: delay,
      overrideOverlayColor: false,
      shadowMultiplier: shadowMultiplier,
      onPressed: onPressed,
      icon: icon,
    );
  }
}
