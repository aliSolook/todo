import 'package:flutter/widgets.dart';
import 'package:todo/constants/durations.dart';

class AnimatedVisibility extends StatelessWidget {
  const AnimatedVisibility({
    super.key,
    this.duration,
    required this.isVisible,
    required this.child,
  });

  final Duration? duration;
  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const gap = 0;
    const fadeTween = Interval(.5 + gap / 2, 1, curve: Curves.easeInOut);
    const sizeTween = Interval(0, .5 - gap / 2, curve: Curves.easeInOut);

    return TweenAnimationBuilder(
      duration: duration == null ? animationDuration * 3 : duration! * 3,
      tween: Tween<double>(end: isVisible ? 1 : 0),
      builder: (context, value, child) {
        final fadeValue = fadeTween.transform(value);
        final sizeValue = sizeTween.transform(value);
        return Opacity(
          opacity: fadeValue,
          child: Align(
            heightFactor: sizeValue,
            widthFactor: 1,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
