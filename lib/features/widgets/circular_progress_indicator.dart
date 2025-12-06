import 'dart:math';
import 'package:flutter/material.dart';
import 'package:todo/utils/extensions/extensions.dart';

// TODO: add [track_progress] with same customizations as [progress]

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator.fromRadius({
    super.key,
    required this.progress,
    this.indicatorColors = const [Colors.grey, Colors.black],
    this.trackColors = const [Colors.transparent],
    this.thickness = 10,
    this.containChild = true,
    this.displayFullColorTransition = true,
    this.child,
    this.thum,
    this.paintOnForground = true,
    this.borderAlign = 0,
    this.startThum,
    this.startGradientAtThum = false,
    this.endGradientAtThum = true,
    this.strokeCap = StrokeCap.round,
    this.takeAccountStrokeSize = true,
  });

  const CustomProgressIndicator({
    super.key,
    required this.progress,
    this.indicatorColors = const [Colors.grey, Colors.black],
    this.trackColors = const [Colors.transparent],
    this.thickness = 10,
    this.containChild = true,
    this.displayFullColorTransition = true,
    this.child,
    this.thum,
    this.paintOnForground = true,
    this.borderAlign = 0,
    this.startThum,
    this.startGradientAtThum = false,
    this.endGradientAtThum = true,
    this.takeAccountStrokeSize = true,
    this.strokeCap = StrokeCap.round,
  });

  final List<Color> indicatorColors;
  final List<Color> trackColors;
  final double thickness;
  final bool containChild;
  final double borderAlign;
  final bool displayFullColorTransition;
  final double progress;
  final Widget? thum;
  final Widget? startThum;
  final bool paintOnForground;
  final bool startGradientAtThum;
  final bool endGradientAtThum;
  final bool takeAccountStrokeSize;
  final StrokeCap strokeCap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final painter = _CountDownPainter(
            strokeCap: strokeCap,
            takeAccountStrokeSize: takeAccountStrokeSize,
            startGradientAtThum: startGradientAtThum,
            endGradientAtThum: endGradientAtThum && takeAccountStrokeSize,
            borderAlign: borderAlign,
            progress: progress,
            displayFullColorTransition: displayFullColorTransition,
            colors: indicatorColors,
            trackColors: trackColors,
            thickness: thickness,
          );

          Widget outputWidget = CustomPaint(
            size: constraints.biggest,
            painter: paintOnForground ? null : painter,
            foregroundPainter: paintOnForground ? painter : null,
            child: child,
          );

          final radius = constraints.biggest.shortestSide / 2;

          if (containChild) {
            outputWidget = ConstrainedBox(
              constraints: BoxConstraints.loose(
                Size.square((radius) * 2),
              ),
              child: Center(
                child: outputWidget,
              ),
            );
          }

          if (thum != null || startThum != null) {
            final startAngle = takeAccountStrokeSize
                ? _calcSweepingAngle(
                    thickness: thickness,
                    radius: radius + borderAlign * (thickness / 2),
                    progress: progress,
                  )
                : -pi / 2;
            final sweepingAngle = pi * 2 * progress;
            outputWidget = Stack(
              alignment: Alignment.center,
              children: [
                outputWidget,
                if (startThum != null)
                  Transform.translate(
                    offset: Offset(
                      cos(startAngle) *
                          (radius + borderAlign * (thickness / 2)),
                      sin(startAngle) *
                          (radius + borderAlign * (thickness / 2)),
                    ),
                    child: startThum,
                  ),
                if (thum != null)
                  Transform.translate(
                    offset: Offset(
                      cos(startAngle + sweepingAngle) *
                          (radius + borderAlign * (thickness / 2)),
                      sin(startAngle + sweepingAngle) *
                          (radius + borderAlign * (thickness / 2)),
                    ),
                    child: thum,
                  ),
              ],
            );
          }

          return outputWidget;
        },
      ),
    );
  }
}

class _CountDownPainter extends CustomPainter {
  final double progress;
  final double thickness;
  final List<Color> colors;
  final List<Color> trackColors;
  final bool displayFullColorTransition;
  final double borderAlign;
  final _paint = Paint();
  final _trackPaint = Paint();
  final bool startGradientAtThum;
  final bool endGradientAtThum;
  final bool takeAccountStrokeSize;
  final StrokeCap strokeCap;

  _CountDownPainter({
    required this.borderAlign,
    required this.takeAccountStrokeSize,
    required this.progress,
    required this.colors,
    required this.thickness,
    required this.trackColors,
    required this.displayFullColorTransition,
    required this.startGradientAtThum,
    required this.endGradientAtThum,
    required this.strokeCap,
  }) {
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = thickness;
    // _paint.strokeJoin = StrokeJoin.bevel;
    _paint.color = colors.first;
    _paint.strokeCap = strokeCap;

    _trackPaint.style = PaintingStyle.stroke;
    _trackPaint.strokeWidth = thickness;
    // _trackPaint.strokeJoin = StrokeJoin.bevel;
    _trackPaint.color = trackColors.first;
    _trackPaint.strokeCap = StrokeCap.butt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2 - (thickness / 2 * -borderAlign);
    final center = Offset(size.width / 2, size.height / 2);

    final startAngle = takeAccountStrokeSize
        ? _calcSweepingAngle(
            thickness: thickness,
            radius: radius,
            progress: progress,
          )
        : -pi / 2;
    if (colors.length > 1) {
      final endAngle =
          (!displayFullColorTransition ? 1 : progress.clamp(0, 1)) * pi * 2 +
          (pi / 2 + startAngle) +
          (endGradientAtThum ? 0 : _calcStartDisplacement(radius) / 180 * pi);

      _paint.shader = progress == 0
          ? null
          : SweepGradient(
              colors: takeAccountStrokeSize
                  ? colors
                  : [...colors, Colors.transparent],
              startAngle: startGradientAtThum
                  ? pi / 2 + startAngle
                  : startAngle,
              stops: takeAccountStrokeSize
                  ? null
                  : [
                      ...List.generate(
                        colors.length,
                        (i) => (i / (colors.length - 1)),
                      ),
                      1,
                    ],
              endAngle: endAngle,
              transform: const GradientRotation(pi / -2),
            ).createShader(
              Rect.fromCenter(
                center: center,
                width: radius * 2,
                height: radius * 2,
              ),
            );
    }

    if (trackColors.length > 1) {
      _trackPaint.shader =
          SweepGradient(
            colors: trackColors,
            transform: const GradientRotation(pi / -2),
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: radius * 2,
              height: radius * 2,
            ),
          );
    }

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      // pi * 2 * progress - (pi / 180 * (90 - _calcStartDisplacement(radius))),
      // pi * 2 * (1 - progress),
      0,
      pi * 2,
      false,
      _trackPaint,
    );

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      startAngle,
      pi * 2 * progress,
      false,
      _paint,
    );
  }

  double _calcStartDisplacement(double radius) {
    final requiredProgress = _calcThicknessRequiredProgress(
      radius: radius,
      thickness: thickness,
    );

    final output = requiredProgress * 90;
    final whenToStart = 1 - requiredProgress / 2;

    if (progress > whenToStart) {
      return output * (1 - progress.map(whenToStart, 1, 0, 1));
    }
    return output;
  }

  @override
  bool shouldRepaint(covariant _CountDownPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.thickness != thickness ||
        oldDelegate.colors != colors ||
        oldDelegate.trackColors != trackColors ||
        oldDelegate.displayFullColorTransition != displayFullColorTransition ||
        oldDelegate.borderAlign != borderAlign ||
        oldDelegate.startGradientAtThum != startGradientAtThum ||
        oldDelegate.endGradientAtThum != endGradientAtThum ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.takeAccountStrokeSize != takeAccountStrokeSize;
  }
}

double _calcSweepingAngle({
  required double thickness,
  required double radius,
  required double progress,
}) {
  final requiredProgress = _calcThicknessRequiredProgress(
    radius: radius,
    thickness: thickness,
  );

  var displacement = requiredProgress * 90;
  final whenToStart = 1 - requiredProgress / 2;

  if (progress > whenToStart) {
    displacement *= (1 - progress.map(whenToStart, 1, 0, 1));
  }

  return pi / 180 * (-90 + displacement);
}

double _calcThicknessRequiredProgress({
  required double thickness,
  required double radius,
}) => (pi / 2 - acos(thickness / 2 / radius)) / (pi / 2);
