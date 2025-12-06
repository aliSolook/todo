import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/utils/path_exteras.dart';

class AsyncCheckbox extends StatefulWidget {
  const AsyncCheckbox({
    super.key,
    this.onTap,
    this.splashColor,
    this.animationDuration,
    this.tristate = false,
    this.padding = const EdgeInsets.all(8),
    required this.value,
    this.isLoading = false,
    this.shape,
    this.size = const Size.square(24),
    this.trackColor,
    this.showBorderWhenNotLoading = true,
    this.ignorePointerWhenLoading = true,
    this.loadingShape,
    this.checkedShape,
    this.tristateShape,
    this.unCheckedShape,
    this.fillColor,
    this.checkedFillColor,
    this.unCheckedFillColor,
    this.loadingFillColor,
    this.tristateFillColor,
    this.iconColor,
    this.checkedIconColor,
    this.unCheckedIconColor,
    this.loadingIconColor,
    this.tristateIconColor,
  }) : assert(tristate || value != null);

  final bool? value;
  final OutlinedBorder? shape;
  final OutlinedBorder? loadingShape;
  final OutlinedBorder? checkedShape;
  final OutlinedBorder? tristateShape;
  final OutlinedBorder? unCheckedShape;
  final EdgeInsetsGeometry padding;
  final Duration? animationDuration;
  final Color? splashColor;
  final Color? trackColor;
  final Color? fillColor;
  final Color? checkedFillColor;
  final Color? unCheckedFillColor;
  final Color? loadingFillColor;
  final Color? tristateFillColor;
  final Color? iconColor;
  final Color? checkedIconColor;
  final Color? unCheckedIconColor;
  final Color? loadingIconColor;
  final Color? tristateIconColor;
  final Size size;
  final bool tristate;
  final bool showBorderWhenNotLoading;
  final bool ignorePointerWhenLoading;
  final bool isLoading;
  final void Function(bool? value)? onTap;

  @override
  State<AsyncCheckbox> createState() => _AsyncCheckboxState();
}

class _AsyncCheckboxState extends State<AsyncCheckbox> {
  bool isDown = false;

  void _tapDown() {
    if (isDown) return;
    setState(() => isDown = true);
  }

  void _tapUp() {
    if (!isDown) return;
    setState(() => isDown = false);
  }

  @override
  Widget build(BuildContext context) {
    const defaultShape = RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.all(
        Radius.circular(5),
      ),
    );

    final effectiveShape = widget.shape ?? defaultShape;
    final effectiveLoadingShape = widget.loadingShape ?? effectiveShape;
    final effectiveCheckedShape = widget.checkedShape ?? effectiveShape;
    final effectiveTristateShape = widget.tristateShape ?? effectiveShape;
    final effectiveUnCheckedShape = widget.unCheckedShape ?? effectiveShape;

    final resolvedShape = widget.isLoading
        ? effectiveLoadingShape
        : widget.value == true
        ? effectiveCheckedShape
        : widget.value == false
        ? effectiveUnCheckedShape
        : effectiveTristateShape;

    final effectiveFillColor = widget.fillColor ?? Colors.transparent;
    final effectiveLoadingFillColor =
        widget.loadingFillColor ?? effectiveFillColor;
    final effectiveCheckedFillColor =
        widget.checkedFillColor ?? effectiveFillColor;
    final effectiveTristateFillColor =
        widget.tristateFillColor ?? effectiveFillColor;
    final effectiveUnCheckedFillColor =
        widget.unCheckedFillColor ?? effectiveFillColor;

    final resolvedFillColor = widget.isLoading
        ? effectiveLoadingFillColor
        : widget.value == true
        ? effectiveCheckedFillColor
        : widget.value == false
        ? effectiveUnCheckedFillColor
        : effectiveTristateFillColor;

    final effectiveIconColor = widget.iconColor ?? CustomColors.green;
    final effectiveLoadingIconColor =
        widget.loadingIconColor ?? effectiveIconColor;
    final effectiveCheckedIconColor =
        widget.checkedIconColor ?? effectiveIconColor;
    final effectiveTristateIconColor =
        widget.tristateIconColor ?? effectiveIconColor;
    final effectiveUnCheckedIconColor =
        widget.unCheckedIconColor ?? effectiveIconColor;

    final resolvedIconColor = widget.isLoading
        ? effectiveLoadingIconColor
        : widget.value == true
        ? effectiveCheckedIconColor
        : widget.value == false
        ? effectiveUnCheckedIconColor
        : effectiveTristateIconColor;

    return IgnorePointer(
      ignoring: widget.isLoading,
      child: AnimatedScale(
        duration: widget.animationDuration ?? animationDuration * .5,
        scale: isDown ? 0.95 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: widget.shape,
            onTap: () => widget.onTap?.call(
              widget.value == true
                  ? widget.tristate
                        ? null
                        : false
                  : widget.value == false
                  ? true
                  : false,
            ),
            splashColor: widget.splashColor?.withAlpha(50),
            onTapDown: (details) => _tapDown(),
            onTapUp: (details) => _tapUp(),
            onTapCancel: () => _tapUp(),
            child: Padding(
              padding: widget.padding,
              child: SizedBox.fromSize(
                size: widget.size,
                child: TweenAnimationBuilder(
                  duration: widget.animationDuration ?? animationDuration,
                  tween: _BorderPropertiesTween(
                    end: _BorderProperties(
                      trackColor: widget.trackColor ?? Colors.transparent,
                      shape: resolvedShape,
                      fill: resolvedFillColor,
                    ),
                  ),
                  builder: (context, value, child) => _BorderBuilder(
                    trackColor: value.trackColor,
                    isLoading: widget.isLoading,
                    showBorderWhenNotLoading: widget.showBorderWhenNotLoading,
                    duration:
                        widget.animationDuration ?? animationDuration * .5,
                    shape: value.shape,
                    fill: value.fill,
                    child: child!,
                  ),
                  child: TweenAnimationBuilder(
                    duration: widget.animationDuration ?? animationDuration,
                    tween: ColorTween(end: resolvedIconColor),
                    builder: (context, value, child) => _CheckBoxIcon(
                      size: widget.size,
                      color: value!,
                      animationDuration:
                          widget.animationDuration ?? animationDuration * .25,
                      value: widget.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BorderBuilder extends StatefulWidget {
  const _BorderBuilder({
    required this.shape,
    required this.trackColor,
    required this.isLoading,
    required this.duration,
    required this.child,
    required this.showBorderWhenNotLoading,
    required this.fill,
  });

  final OutlinedBorder shape;
  final Color? trackColor;
  final Color fill;
  final bool isLoading;
  final Duration duration;
  final Widget child;
  final bool showBorderWhenNotLoading;

  @override
  State<_BorderBuilder> createState() => _BorderBuilderState();
}

class _BorderPropertiesTween extends Tween<_BorderProperties> {
  _BorderPropertiesTween({super.end});

  @override
  _BorderProperties lerp(double t) => _BorderProperties.lerp(begin, end, t)!;
}

class _BorderProperties {
  final Color trackColor;
  final OutlinedBorder shape;
  final Color fill;

  _BorderProperties({
    required this.trackColor,
    required this.shape,
    required this.fill,
  });

  static _BorderProperties? lerp(
    _BorderProperties? a,
    _BorderProperties? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    return _BorderProperties(
      trackColor: Color.lerp(a?.trackColor, b?.trackColor, t)!,
      shape: OutlinedBorder.lerp(a?.shape, b?.shape, t)!,
      fill: Color.lerp(a?.fill, b?.fill, t)!,
    );
  }
}

class _BorderBuilderState extends State<_BorderBuilder>
    with SingleTickerProviderStateMixin {
  static const int _kIndeterminateCircularDuration = 1333 * 2222;

  static const int _pathCount = _kIndeterminateCircularDuration ~/ 1333;
  static const int _rotationCount = _kIndeterminateCircularDuration ~/ 2222;

  static final Animatable<double> _strokeHeadTween = CurveTween(
    curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(curve: const SawTooth(_pathCount)));
  static final Animatable<double> _strokeTailTween = CurveTween(
    curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(curve: const SawTooth(_pathCount)));
  static final Animatable<double> _offsetTween = CurveTween(
    curve: const SawTooth(_pathCount),
  );
  static final Animatable<double> _rotationTween = CurveTween(
    curve: const SawTooth(_rotationCount),
  );

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kIndeterminateCircularDuration),
      vsync: this,
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_BorderBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: widget.duration,
      tween: Tween<double>(end: widget.isLoading ? 1 : 0),
      builder: (context, value, child) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _BorderPainter(
            trackColor: widget.trackColor,
            fill: widget.fill,
            headValue: lerpDouble(
              widget.showBorderWhenNotLoading ? 1.333333 : 0,
              _strokeHeadTween.evaluate(_controller),
              value,
            )!,
            tailValue: lerpDouble(
              0,
              _strokeTailTween.evaluate(_controller),
              value,
            )!,
            offsetValue: _offsetTween.evaluate(_controller),
            rotationValue: _rotationTween.evaluate(_controller),
            shape: widget.shape,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _BorderPainter extends CustomPainter {
  final Color? trackColor;
  final double headValue;
  final double tailValue;
  final double offsetValue;
  final double rotationValue;
  final double arcStart;
  final double arcSweep;
  final OutlinedBorder shape;
  final Color fill;

  _BorderPainter({
    required this.trackColor,
    required this.headValue,
    required this.tailValue,
    required this.offsetValue,
    required this.rotationValue,
    required this.shape,
    required this.fill,
  }) : arcStart =
           _startAngle +
           tailValue * 3 / 2 * math.pi +
           rotationValue * math.pi * 2.0 +
           offsetValue * 0.5 * math.pi,
       arcSweep = math.max(
         headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi,
         _epsilon,
       );

  static const double _epsilon = .001;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final side = shape.side;
    final fillPainter = Paint()..color = fill;
    canvas.drawPath(shape.getInnerPath(rect), fillPainter);

    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final Paint paint = side.toPaint();
        final path = shape.getInnerPath(rect)..close();

        final pathBounds = path.getBounds();

        final clipper = Path()
          ..moveTo(rect.center.dx, rect.center.dy)
          ..arcTo(
            Rect.fromCenter(
              center: size.center(Offset.zero),
              width: pathBounds.width * 1.5,
              height: pathBounds.height * 1.5,
            ),
            arcStart,
            arcSweep,
            false,
          )
          ..close();

        if (trackColor != null) {
          paint.color = trackColor!;
          canvas.drawPath(path, paint);
        }

        paint.color = side.color;

        canvas
          ..clipPath(clipper)
          ..drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) =>
      trackColor != oldDelegate.trackColor ||
      headValue != oldDelegate.headValue ||
      tailValue != oldDelegate.tailValue ||
      offsetValue != oldDelegate.offsetValue ||
      rotationValue != oldDelegate.rotationValue ||
      shape != oldDelegate.shape;
}

class _CheckBoxIcon extends StatefulWidget {
  const _CheckBoxIcon({
    required this.color,
    required this.animationDuration,
    required this.value,
    required this.size,
  });

  final Color color;
  final bool? value;
  final Duration animationDuration;
  final Size size;

  @override
  State<_CheckBoxIcon> createState() => _CheckBoxIconState();
}

class _CheckBoxIconState extends State<_CheckBoxIcon> {
  final _truePath = Path()
    ..moveTo(0.2, 0.5)
    ..lineTo(0.4, 0.7)
    ..lineTo(0.8, 0.3);

  final _tristatePath = Path()
    ..moveTo(0.2, 0.5)
    ..lineTo(0.8, 0.5);

  final Path _falsePath = Path();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: PathTween(
        end: widget.value == true
            ? _truePath
            : widget.value == null
            ? _tristatePath
            : _falsePath,
      ),
      duration: widget.animationDuration,
      builder: (context, value, child) => CustomPaint(
        size: widget.size,
        painter: PathPainter(
          path: value,
          painter: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..color = widget.color,
        ),
      ),
    );
  }
}
