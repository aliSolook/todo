import 'dart:math';
import 'package:flutter/material.dart';
import 'package:todo/utils/functions.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.animationFraction,
    this.angleFraction,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    this.borderColor = const Color(0xFF727272),
    this.borderWidth = 2,
    this.size = 18,
    this.borderRadius,
    this.tickThickness = 2,
    this.duration,
    this.tickHeadLength = 9,
    this.tickTailLength = 15,
    this.tickRadius,
    this.splashBorderRadius,
    this.padding = const EdgeInsets.all(8),
    this.splashColor,
  });

  final bool value;
  final void Function(bool newValue) onChanged;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double borderWidth;
  final Duration? duration;
  final double size;
  final BorderRadius? borderRadius;
  final double tickThickness;
  final double? animationFraction;
  final double? angleFraction;
  final double tickHeadLength;
  final double tickTailLength;
  final Radius? tickRadius;
  final BorderRadius? splashBorderRadius;
  final Color? splashColor;
  final EdgeInsets padding;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: widget.duration ?? const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value) {
      _animation.forward();
    } else {
      _animation.reverse();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: widget.splashColor?.withAlpha(50),
        highlightColor: widget.splashColor?.withAlpha(30),
        enableFeedback: false,
        borderRadius:
            widget.splashBorderRadius ??
            const BorderRadius.all(Radius.circular(9999)),
        onTap: () {
          widget.onChanged(!widget.value);
        },
        child: Padding(
          padding: widget.padding,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final fractions = fractionSpliter(
                positions: [.25, .5, .75],
                fraction: _animation.value,
              );
              final scaleFraction = fractions[1] == 1
                  ? 1 - fractions[2]
                  : fractions[1];
              return Transform.scale(
                scale: 1 - scaleFraction * .15,
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: CheckBoxCustomPainter(
                    fraction: widget.animationFraction ?? _animation.value,
                    // fraction: widget.fraction * _animation.value,
                    angleFraction: widget.angleFraction ?? 1,
                    borderColor: widget.borderColor,
                    backgroundColor: widget.backgroundColor,
                    foregroundColor: widget.foregroundColor,
                    tickThickness: widget.tickThickness,
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(2),
                    borderWidth: widget.borderWidth,
                    stat: widget.value,
                    tickHeadLength: widget.tickHeadLength,
                    tickTailLength:
                        widget.tickTailLength - widget.tickThickness,
                    tickRadius: widget.tickRadius ?? Radius.zero,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CheckBoxCustomPainter extends CustomPainter {
  final double fraction;
  final double angleFraction;
  final Color borderColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderWidth;
  final bool stat;
  final double tickThickness;
  final BorderRadius borderRadius;
  final double tickHeadLength;
  final double tickTailLength;
  final Radius tickRadius;

  CheckBoxCustomPainter({
    required this.fraction,
    required this.angleFraction,
    required this.borderColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderWidth,
    required this.stat,
    required this.borderRadius,
    required this.tickThickness,
    required this.tickHeadLength,
    required this.tickTailLength,
    required this.tickRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final fractions = fractionSpliter(
      positions: [.45, .65],
      fraction: fraction,
    );
    final center = Offset(size.width / 2, size.height / 2);

    if (borderWidth > 0) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(
            center: center,
            width: size.width - borderWidth,
            height: size.height - borderWidth,
          ),
          topLeft: borderRadius.topLeft - Radius.circular(borderWidth / 2),
          topRight: borderRadius.topRight - Radius.circular(borderWidth / 2),
          bottomLeft:
              borderRadius.bottomLeft - Radius.circular(borderWidth / 2),
          bottomRight:
              borderRadius.bottomRight - Radius.circular(borderWidth / 2),
        ),
        paint,
      );
    }

    final background = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center,
        width: (size.width) * fractions.first,
        height: (size.height) * fractions.first,
      ),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    final tick = Path();

    tick.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
          center.dx,
          center.dy - tickHeadLength,
          tickThickness,
          tickHeadLength * fractions[1],
        ),
        topRight: tickRadius,
        topLeft: tickRadius,
        bottomLeft: tickRadius,
      ),
    );

    tick.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
          center.dx + tickThickness,
          center.dy - tickThickness,
          tickTailLength * fractions.last,
          tickThickness,
        ),
        topRight: tickRadius,
        bottomRight: tickRadius,
      ),
    );

    // final double tailLength = 3 * fractions[2];
    // final double headLength = 1.2 - (2.2 * (1 - fractions[1]));
    // // double tailLength = 3;
    // // double headLength = 1.2;
    //
    // tick.moveTo(center.dx, center.dy - (tickThickness * headLength));
    // tick.relativeLineTo(0, tickThickness * (headLength + 1));
    // tick.relativeLineTo(tickThickness * (tailLength + 1), 0);
    // tick.relativeLineTo(0, -tickThickness);
    // tick.relativeLineTo(-tickThickness * tailLength, 0);
    // tick.relativeLineTo(0, -tickThickness * headLength);

    // double width = pow(
    //   pow(tickHeadLength, 2) + pow(tickTailLength + tickThickness, 2),
    //   1 / 2,
    // ).toDouble();

    paint.style = PaintingStyle.fill;
    canvas.drawRRect(background, paint..color = backgroundColor);

    canvas.save();
    canvas.translate(
      center.dx + (tickHeadLength - tickTailLength - tickThickness) / 3,
      center.dy - (tickHeadLength - tickTailLength - tickThickness),
    );
    canvas.rotate(-pi / 180 * (45 * angleFraction));
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(tick, paint..color = foregroundColor);
    canvas.restore();

    // canvas.drawLine(
    //   Offset(center.dx, 0),
    //   Offset(center.dx, size.height),
    //   Paint()
    //     ..color = Colors.white
    //     ..strokeWidth = .1,
    // );

    // canvas.drawLine(
    //   Offset(0, center.dy),
    //   Offset(size.width, center.dy),
    //   Paint()
    //     ..color = Colors.white
    //     ..strokeWidth = .1,
    // );
  }

  @override
  bool shouldRepaint(covariant CheckBoxCustomPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.tickThickness != tickThickness ||
        oldDelegate.stat != stat;
  }
}
