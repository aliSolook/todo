import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:todo/utils/path_exteras.dart';

class AnimatedThemeIcon extends StatefulWidget {
  const AnimatedThemeIcon({
    super.key,
    required this.themeMode,
    this.color,
    this.strokeWidth = 1.5,
    this.animationDuration = Durations.medium1,
    this.animationCurve = Curves.linear,
    this.size = const Size(24, 24),
  });

  final Color? color;
  final ThemeMode themeMode;
  final double strokeWidth;
  final Duration animationDuration;
  final Curve animationCurve;
  final Size size;

  @override
  State<AnimatedThemeIcon> createState() => _AnimatedThemeIconState();
}

class _AnimatedThemeIconState extends State<AnimatedThemeIcon> {
  late Path _systemPath = _systemSettingsPath(
    widget.strokeWidth / widget.size.shortestSide,
  );
  late Path _lightPath = _lightModePath(
    widget.strokeWidth / widget.size.shortestSide,
  );
  late Path _nightPath = _nightModePath(
    widget.strokeWidth / widget.size.shortestSide,
  );

  @override
  void didUpdateWidget(covariant AnimatedThemeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.size != widget.size ||
        widget.strokeWidth != oldWidget.strokeWidth) {
      _systemPath = _systemSettingsPath(
        widget.strokeWidth / widget.size.shortestSide,
      );
      _lightPath = _lightModePath(
        widget.strokeWidth / widget.size.shortestSide,
      );
      _nightPath = _nightModePath(
        widget.strokeWidth / widget.size.shortestSide,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      curve: widget.animationCurve,
      tween: PathTween(
        end: widget.themeMode == ThemeMode.system
            ? _systemPath
            : widget.themeMode == ThemeMode.light
            ? _lightPath
            : _nightPath,
      ),
      duration: widget.animationDuration,
      builder: (context, path, child) => TweenAnimationBuilder(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        tween: ColorTween(
          end: widget.color ?? ColorScheme.of(context).onSurfaceVariant,
        ),
        builder: (context, color, child) => CustomPaint(
          size: widget.size,
          painter: PathPainter(
            painter: Paint()
              ..color = color!
              ..strokeWidth = widget.strokeWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..style = PaintingStyle.stroke,
            path: path,
          ),
        ),
      ),
    );
  }

  Path _nightModePath(double thickness) {
    const sweepAngle = math.pi * 1.2;
    const startAngle = .5;
    const innerRadius = .55;

    return Path()
      ..arcTo(Offset.zero & const Size(1, 1), startAngle, sweepAngle, false)
      ..arcToPoint(
        Offset(.5 + .5 * math.cos(startAngle), .5 + .5 * math.sin(startAngle)),
        radius: const Radius.circular(innerRadius),
        clockwise: false,
      );
  }

  Path _systemSettingsPath(double thickness) {
    const aspectRatio = 16 / 11;
    // const aspectRatio = 16 / 9;
    const width = .95;
    const height = width / aspectRatio;

    final rect = Rect.fromCenter(
      center: const Offset(.5, height / 2),
      width: width,
      height: height,
    );

    const radius = Radius.circular(.1);
    const dots = [0.0, .1];
    final dotsGap = thickness;
    const padding = .12;
    const thumRadius = .15;

    double calcDotTop(int i, double passedDotsHeight) {
      return radius.y + dotsGap * 2 * (i + 1) + passedDotsHeight;
    }

    void drawSlider(double align, double progress, Path path) {
      final trackWidth = rect.size.width - padding * 2;
      final thumX = progress * trackWidth + padding + rect.left;
      final y = rect.top + rect.height * align;

      if (thumX + thumRadius / 2 > rect.left + padding) {
        path.moveTo(rect.left + padding, y);
        path.lineTo(thumX - thumRadius / 2, y);
      }

      if (thumX + thumRadius / 2 < rect.right - padding) {
        path.moveTo(thumX + thumRadius / 2, y);
        path.lineTo(rect.right - padding, y);
      }

      path.addOval(
        Rect.fromCenter(
          center: Offset(thumX, y),
          width: thumRadius,
          height: thumRadius,
        ),
      );
    }

    final path = Path();

    path
      ..moveTo(
        rect.right,
        rect.top + calcDotTop(dots.length, dots.reduce((a, b) => a + b)),
      )
      ..lineTo(rect.right, rect.bottom - radius.y)
      ..arcToPoint(Offset(rect.right - radius.x, rect.bottom), radius: radius)
      ..lineTo(rect.left + radius.x, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - radius.y), radius: radius)
      ..lineTo(rect.left, rect.top + radius.y)
      ..arcToPoint(Offset(rect.left + radius.x, rect.top), radius: radius)
      ..lineTo(rect.right - radius.x, rect.top)
      ..arcToPoint(Offset(rect.right, radius.y + rect.top), radius: radius);

    double passedDotsHeight = 0;
    for (int i = 0; i < dots.length; i++) {
      final y = calcDotTop(i, passedDotsHeight);
      passedDotsHeight += dots[i];

      path
        ..moveTo(rect.right, rect.top + y)
        ..lineTo(rect.right, rect.top + y + dots[i]);
    }

    final childRect = Rect.fromCenter(
      center: rect.center,
      width: rect.shortestSide - .2,
      height: rect.shortestSide - .2,
    );

    path.addPath(
      _lightModePath(thickness),
      childRect.topLeft,
      matrix4: Matrix4.diagonal3Values(
        childRect.width,
        childRect.height,
        1,
      ).storage,
    );

    // drawSlider(.25, .75, path);
    // drawSlider(.5, .25, path);
    // drawSlider(.75, .75, path);

    final remaining = 1 - rect.bottom;

    path.moveTo(rect.left + radius.x + .2, rect.bottom + remaining / 2);
    path.lineTo(rect.right - radius.x - .2, rect.bottom + remaining / 2);

    path.moveTo(rect.left + radius.x, 1);
    path.lineTo(rect.right - radius.x, 1);

    return path;
  }

  Path _lightModePath(double thickness) {
    const gap = .05;
    const linesCount = 8;

    final circleRect = Rect.fromCenter(
      center: const Offset(.5, .5),
      width: .5 - thickness - gap,
      height: .5 - thickness - gap,
    );

    Offset calcOffset(double angle, double radius) {
      final x = circleRect.center.dx + radius * math.cos(angle);
      final y = circleRect.center.dy + radius * math.sin(angle);
      return Offset(x, y);
    }

    final path = Path();

    final lines = List.generate(
      linesCount,
      (i) => (
        s: calcOffset(
          math.pi * 2 * (i / linesCount),
          .25 + thickness / 2 + gap / 2,
        ),
        e: calcOffset(math.pi * 2 * (i / linesCount), .5 - thickness / 2),
      ),
    );

    path.addArc(circleRect, 0, math.pi * 2);
    for (var line in lines) {
      path.moveTo(line.s.dx, line.s.dy);
      path.lineTo(line.e.dx, line.e.dy);
    }

    return path;
  }
}
