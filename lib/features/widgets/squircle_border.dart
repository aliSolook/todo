import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SquircleBorder extends OutlinedBorder {
  const SquircleBorder({super.side, this.strength = .75});

  final double strength;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return SquircleBorder(side: side.scale(t), strength: strength);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SquircleBorder) {
      return SquircleBorder(
        side: BorderSide.lerp(a.side, side, t),
        strength: lerpDouble(a.strength, strength, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SquircleBorder) {
      return SquircleBorder(
        side: BorderSide.lerp(side, b.side, t),
        strength: lerpDouble(strength, b.strength, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  Path _getPath(Rect rect) {
    final double w = rect.width + (side.width * side.strokeAlign);
    final double h = rect.height + (side.width * side.strokeAlign);
    final double y = rect.top - (side.width / 2 * side.strokeAlign);
    final double x = rect.left - (side.width / 2 * side.strokeAlign);
    final double n = strength;

    final hw = 0.5 * w;
    final hh = 0.5 * h;

    return Path()
      ..moveTo(x + hw, y) // top mid
      ..cubicTo(
        x + hw * (1 - n),
        y,
        x,
        y + hh * (1 - n),
        x,
        y + hh,
      ) // left mid
      ..cubicTo(
        x,
        y + hh + n * hh,
        x + hw - n * hw,
        y + h,
        x + hw,
        y + h,
      ) // bottom mid
      ..cubicTo(
        x + hw + n * hw,
        y + h,
        x + w,
        y + hh + n * hh,
        x + w,
        y + hh,
      ) // right mid
      ..cubicTo(
        x + w,
        y + hh - n * hh,
        x + hw + n * hw,
        y,
        x + hw,
        y,
      ); // top mid
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(rect);
  }

  @override
  SquircleBorder copyWith({BorderSide? side, double? strength}) {
    return SquircleBorder(
      side: side ?? this.side,
      strength: strength ?? this.strength,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) {
      return;
    }
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        canvas.drawPath(
          getOuterPath(rect, textDirection: textDirection),
          side.toPaint(),
        );
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SquircleBorder &&
        other.side == side &&
        other.strength == strength;
  }

  @override
  int get hashCode => Object.hash(side, strength);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'ContinuousRectangleBorder')}($side, $strength)';
  }
}
