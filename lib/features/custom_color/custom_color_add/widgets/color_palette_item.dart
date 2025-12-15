import 'package:flutter/material.dart';

class ColorPaletteItem extends StatelessWidget {
  const ColorPaletteItem({
    super.key,
    this.delay,
    this.backgroundColor,
    this.onPressed,
    this.foregroundColor,
    this.shadowColor,
    this.shadowMultiplier = 1,
    this.icon,
    this.overrideOverlayColor = true,
    this.childBuilder,
  }) : assert(childBuilder != null || icon != null),
       assert(shadowMultiplier >= 0);

  final double? delay;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? shadowColor;
  final double shadowMultiplier;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget Function(
    BuildContext context,
    Color? foregroundColor,
    VoidCallback? onPressed,
    Widget? icon,
  )?
  childBuilder;
  final bool overrideOverlayColor;

  @override
  Widget build(BuildContext context) {
    final relativeForegroundColor = backgroundColor != null
        ? backgroundColor!.computeLuminance() > .5
              ? Colors.black
              : Colors.white
        : null;

    final foregroundColor =
        this.foregroundColor ??
        (overrideOverlayColor ? relativeForegroundColor : null);

    final Widget effectiveChild =
        childBuilder?.call(context, foregroundColor, onPressed, icon) ??
        IconButton(
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            overlayColor: foregroundColor,
            foregroundColor: foregroundColor,
          ),
          onPressed: onPressed,
          icon: icon!,
        );

    return TweenAnimationBuilder(
      duration: Durations.short1 * (delay ?? 0) * 2,
      tween: Tween<double>(begin: 0, end: 1),
      curve: const Interval(.5, 1),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: shadowColor == null && backgroundColor == null
          ? effectiveChild
          : DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: (shadowColor ?? backgroundColor!).withAlpha(
                      0.8 * 255 ~/ 1,
                    ),
                    offset: const Offset(1, 2) * shadowMultiplier,
                    blurRadius: 5 * shadowMultiplier,
                  ),
                ],
              ),
              child: effectiveChild,
            ),
    );
  }
}
