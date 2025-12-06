import 'package:flutter/widgets.dart';

class AnimatedCounter extends ImplicitlyAnimatedWidget {
  final int value;

  const AnimatedCounter({
    super.key,
    required this.builder,
    required this.value,
    this.child,
    super.duration = const Duration(milliseconds: 500),
    super.curve = Curves.easeOut,
  });

  final Widget Function(BuildContext context, int value, Widget? child) builder;
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedCounter> createState() =>
      _AnimatedCounterState();
}

class _AnimatedCounterState
    extends ImplicitlyAnimatedWidgetState<AnimatedCounter> {
  IntTween? _valueTween;
  int? previousValue;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final newValue = _valueTween?.evaluate(controller);
      if (newValue != previousValue) {
        setState(() {});
      }

      previousValue = newValue;
    });
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween =
        visitor(
              _valueTween,
              widget.value,
              (dynamic value) => IntTween(begin: value as int),
            )
            as IntTween?;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _valueTween?.evaluate(animation) ?? widget.value,
      widget.child,
    );
  }
}
