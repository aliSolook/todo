import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  PathPainter({
    required this.painter,
    this.multiplier = 1.0,
    this.pathBuilder,
    this.path,
    this.pathNormalized = true,
  }) : assert(path != null || pathBuilder != null);

  final Paint painter;
  final Path Function(Size size)? pathBuilder;
  final Path? path;
  final bool pathNormalized;
  final double multiplier;

  @override
  void paint(Canvas canvas, Size size) {
    final absolutePath = (path ?? pathBuilder!(size));

    final Path effectivePath;

    if (pathNormalized) {
      effectivePath = absolutePath.transform(
        Matrix4.diagonal3Values(
          size.width * multiplier,
          size.height * multiplier,
          1,
        ).storage,
      );
    } else {
      effectivePath = absolutePath.transform(
        Matrix4.diagonal3Values(multiplier, multiplier, 1).storage,
      );
    }

    canvas.drawPath(effectivePath, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PathTween extends Tween<Path> {
  final Alignment align;
  final double precision;

  PathTween({
    super.begin,
    super.end,
    this.align = Alignment.center,
    this.precision = 0.01,
  });

  @override
  Path lerp(double t) => begin.lerp(end, t, align: align, precision: precision);
}

extension PathExtension on Path? {
  Path lerp(
    Path? b,
    double t, {
    double precision = .01,
    Alignment align = Alignment.center,
    bool loopMetrics = false,
  }) {
    final a = this;

    if (a == null && b == null) return Path();

    if (t == 0) return a ?? Path();
    if (t == 1) return b ?? Path();

    List<PathMetric>? getMetrics(Path? path) {
      if (path == null) return null;
      final output = path.computeMetrics().toList();
      if (output.isEmpty) return null;
      return output;
    }

    final aMetrics = getMetrics(a);
    final bMetrics = getMetrics(b);

    if (aMetrics == null && bMetrics == null) return Path();

    final bounds = bMetrics == null ? a!.getBounds() : b!.getBounds();
    final path = Path();

    Offset? lerpMetricAt(
      PathMetric? a,
      PathMetric? b,
      double? aPos,
      double? bPos,
      double t,
    ) {
      assert(a != null || b != null);
      assert(a == null || aPos != null);
      assert(b == null || bPos != null);

      return Offset.lerp(
        a?.getTangentForOffset(aPos!)?.position ?? align.withinRect(bounds),
        b?.getTangentForOffset(bPos!)?.position ?? align.withinRect(bounds),
        t,
      );
    }

    final length = math.max(aMetrics?.length ?? 0, bMetrics?.length ?? 0);

    for (int i = 0; i < length; i++) {
      final PathMetric? aCurrent;
      final PathMetric? bCurrent;
      if (loopMetrics) {
        aCurrent = aMetrics?.elementAt(i % aMetrics.length);
        bCurrent = bMetrics?.elementAt(i % bMetrics.length);
      } else {
        aCurrent = aMetrics?.elementAtOrNull(i);
        bCurrent = bMetrics?.elementAtOrNull(i);
      }

      final r = lerpMetricAt(aCurrent, bCurrent, 0, 0, t);

      if (r != null) path.moveTo(r.dx, r.dy);

      for (double i = 0; i < 1.1; i += precision) {
        final r = lerpMetricAt(
          aCurrent,
          bCurrent,
          aCurrent?.length.multiply(i),
          bCurrent?.length.multiply(i),
          t,
        );

        if (r == null) continue;

        path.lineTo(r.dx, r.dy);
      }

      if (aCurrent == null && bCurrent!.isClosed) path.close();
      if (bCurrent == null && aCurrent!.isClosed) path.close();
    }

    return path;
  }
}

extension<T extends num> on T {
  T multiply(T multiplier) => (this * multiplier) as T;
}
