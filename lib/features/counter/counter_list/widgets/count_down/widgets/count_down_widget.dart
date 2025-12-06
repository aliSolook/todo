import 'dart:math';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/functions.dart';

class CountDownWidget extends StatefulWidget {
  const CountDownWidget({
    super.key,
    this.curve = Curves.easeInOutCirc,
  });

  final Curve curve;

  @override
  State<CountDownWidget> createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    value: 1,
  );

  CountDownBloc _getBloc() => BlocProvider.of(context);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CountDownBloc, CountDownState>(
      listener: _listener,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          _getIndicator(),
          const Spacer(),
          _getButtons(),
        ],
      ),
    );
  }

  void _listener(BuildContext context, CountDownState state) {
    if (state.status.isNone) return;

    if (state.status.isSetDuration) {
      Scrollable.maybeOf(context, axis: Axis.vertical)?.position.animateTo(
        0,
        duration: animationDuration,
        curve: Curves.easeOutCirc,
      );
      controller.duration = state.duration;
      controller.animateTo(
        0,
        duration: animationDuration,
        curve: widget.curve,
      );
    }

    if ((controller.duration == null || controller.duration == Duration.zero) &&
        state.status.isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackbarBuilder(
          context,
          builder: (context, value) {
            return const Text('لطفا یک شمارنده وارد کنید');
          },
        ),
      );
    }

    if (state.status.isDone && controller.value != 1) {
      controller.animateTo(
        1,
        duration: animationDuration,
        curve: widget.curve,
      );
    }
    if (state.status.isRunning && controller.value != state.passed) {
      final double requiredProgressForAnimation =
          animationDuration.inMicroseconds /
          controller.duration!.inMicroseconds;

      controller
          .animateTo(
            state.passed + requiredProgressForAnimation.clamp(0, 1),
            duration: animationDuration,
            curve: widget.curve,
          )
          .then((value) {
            controller.forward().then((value) {
              _getBloc().add(const CountDownFinished());
            });
          });
    } else if (state.status.isRunning) {
      controller.forward(from: state.passed).then((value) {
        _getBloc().add(const CountDownFinished());
      });
    }
    if (state.status.isPaused) {
      controller.stop();
    }
  }

  Widget _getIndicator() {
    final thum = DecoratedBox(
      decoration: ShapeDecoration(
        color: ColorScheme.of(context).primary,
        shape: CircleBorder(
          side: BorderSide(
            color: ColorScheme.of(context).surfaceContainer,
            width: 3,
          ),
        ),
      ),
      child: const SizedBox.square(dimension: 24),
    );
    return SizedBox.square(
      dimension: 244,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final value = 1 - controller.value;
          return CustomProgressIndicator(
            trackColors: [ColorScheme.of(context).primaryContainer],
            indicatorColors: [
              ColorScheme.of(context).primaryContainer,
              ColorScheme.of(context).primary,
            ],
            strokeCap: StrokeCap.butt,
            takeAccountStrokeSize: false,
            startGradientAtThum: true,
            progress: value,
            borderAlign: -1,
            thickness: 9,
            thum: thum,
            containChild: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(9999999999999),
                ),
                color: ColorScheme.of(context).surface,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 0,
                    color: ColorScheme.of(context).primary.withAlpha(13), // 5%
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    blurRadius: 6,
                    color: ColorScheme.of(context).primary.withAlpha(13), // 5%
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    blurRadius: 11,
                    color: ColorScheme.of(context).primary.withAlpha(10), // 4%
                    offset: const Offset(0, 11),
                  ),
                  BoxShadow(
                    blurRadius: 15,
                    color: ColorScheme.of(context).primary.withAlpha(8), // 3%
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    blurRadius: 18,
                    color: ColorScheme.of(context).primary.withAlpha(3), // 1%
                    offset: const Offset(0, 45),
                  ),
                ],
              ),
              child: SizedBox.expand(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: -pi * .5,
                      child: ClipPath(
                        clipper: value == 1 ? null : _MyClipper(value),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            12 + 9,
                          ), // 9 is the thickness of the circularProgressIndicator
                          child: DecoratedBox(
                            decoration: DottedDecoration(
                              color: ColorScheme.of(context).primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(99999),
                              ),
                              strokeWidth: 4,
                              dash: [15, 15 ~/ 2],
                              shape: Shape.circle,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                    if (child != null) child,
                  ],
                ),
              ),
            ),
          );
        },
        child: _getCenterSection(),
      ),
    );
  }

  Widget _getCenterSection() {
    return BlocBuilder<CountDownBloc, CountDownState>(
      buildWhen: (previous, current) {
        if (previous == current) return false;

        if (previous.status.isDone && !current.status.isDone) return true;
        if (!previous.status.isDone && current.status.isDone) return true;

        if (previous.status.isPaused && !current.status.isPaused) return true;
        if (!previous.status.isPaused && current.status.isPaused) return true;

        return true;
      },
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: animationDuration,
                  switchInCurve: widget.curve,
                  switchOutCurve: widget.curve,
                  transitionBuilder: (child, animation) => AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Align(
                      alignment: Alignment.topCenter,
                      widthFactor: 1,
                      heightFactor: animation.value,
                      child: Opacity(
                        opacity: animation.value,
                        child: Transform.scale(
                          scale: animation.value,
                          child: child,
                        ),
                      ),
                    ),
                    child: child,
                  ),
                  child: state.status.isDone || state.status.isPaused
                      ? Padding(
                          key: ValueKey(state.status),
                          padding: const EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Text(
                            switch (state.status) {
                              CountDownStatus.done => 'پایان',
                              CountDownStatus.paused => 'توقف',
                              _ => '',
                            },
                            style: TextStyle(
                              color: ColorScheme.of(context).onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: -0.24,
                            ),
                          ),
                        )
                      : SizedBox.shrink(key: ValueKey(state.status)),
                ),
                AnimatedCounter(
                  value: state.duration.inSeconds,
                  curve: widget.curve,
                  duration: animationDuration,
                  builder: (_, seconds, _) => TweenAnimationBuilder(
                    duration: animationDuration,
                    tween: Tween<double>(
                      end: state.status.isDone || state.status.isPaused
                          ? 16
                          : 24,
                    ),
                    builder: (_, fontSize, _) => AnimatedBuilder(
                      animation: controller,
                      builder: (_, _) {
                        final duration = Duration(seconds: seconds);
                        final extraDuration = Duration(
                          seconds:
                              controller.value == 0 || controller.value == 1
                              ? 0
                              : 1,
                        );
                        return Text(
                          durationFormatter(
                            duration * (1 - controller.value) + extraDuration,
                            hours: duration.inHours != 0,
                          ),
                          style: TextStyle(
                            color: ColorScheme.of(context).onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                            letterSpacing: -0.24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: const Alignment(0, .7),
              child: AnimatedCounter(
                duration: animationDuration,
                curve: widget.curve,
                value: state.duration.inSeconds,
                builder: (_, seconds, _) {
                  final duration = Duration(seconds: seconds);
                  return Text(
                    durationFormatter(
                      duration,
                      hours: duration.inHours != 0,
                    ),
                    style: TextStyle(
                      color: ColorScheme.of(context).onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      letterSpacing: -0.24,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getButtons() {
    return BlocBuilder<CountDownBloc, CountDownState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder(
            builder: (_, value, child) => Visibility(
              visible: value != 0,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: value,
                heightFactor: 1,
                child: child,
              ),
            ),
            duration: animationDuration,
            tween: Tween<double>(
              end: state.status.isPaused || state.status.isRunning ? 1 : 0,
            ),
            curve: widget.curve,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 107,
                  minHeight: 36,
                ),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: ColorScheme.of(context).primaryContainer,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: _doneButtonPressed,
                  child: Text(
                    'پایان',
                    style: TextStyle(
                      color: ColorScheme.of(context).primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 107,
              minHeight: 36,
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: ColorScheme.of(context).primary,
                overlayColor: ColorScheme.of(context).onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: state.status.isNone
                  ? null
                  : () => _onMultiActionButtonPressed(state),
              child: AnimatedSwitcher(
                duration: animationDuration,
                switchInCurve: widget.curve,
                switchOutCurve: widget.curve,
                child: () {
                  final text = switch (state.status) {
                    CountDownStatus.done => 'شروع مجدد',
                    CountDownStatus.setDuration ||
                    CountDownStatus.none => 'شروع',
                    CountDownStatus.paused => 'ادامه',
                    CountDownStatus.running => 'توفق',
                  };
                  return Text(
                    text,
                    key: ValueKey(text),
                    style: TextStyle(
                      color: ColorScheme.of(context).onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.24,
                    ),
                  );
                }(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMultiActionButtonPressed(CountDownState state) {
    _getBloc().add(
      switch (state.status) {
        CountDownStatus.done => const CountDownRestartPressed(),
        CountDownStatus.setDuration ||
        CountDownStatus.none ||
        CountDownStatus.paused => const CountDownResumePressed(),
        CountDownStatus.running => CountDownPausePressed(controller.value),
      },
    );
  }

  void _doneButtonPressed() {
    _getBloc().add(const CountDownFinished());
  }
}

class _MyClipper extends CustomClipper<Path> {
  final double progress;

  const _MyClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = size.center(Offset.zero);

    path.moveTo(center.dx, center.dy);
    path.lineTo(size.width, center.dy);

    path.arcTo(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width,
        height: size.height,
      ),
      0,
      pi * 2 * progress,
      false,
    );
    path.close;

    return path;
  }

  @override
  bool shouldReclip(covariant _MyClipper oldClipper) =>
      oldClipper.progress != progress;
}
