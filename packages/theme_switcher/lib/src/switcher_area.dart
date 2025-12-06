part of '../theme_switcher.dart';

class ThemeSwitcherArea extends StatefulWidget {
  const ThemeSwitcherArea({
    super.key,
    required this.child,
    this.defaultAnimDuration = const Duration(milliseconds: 300),
    this.darkModeStyle,
    this.lightModeStyle,
  });

  final Widget child;
  final Duration defaultAnimDuration;
  final ThemeSwitcherAnimationStyle? darkModeStyle;
  final ThemeSwitcherAnimationStyle? lightModeStyle;

  @override
  State<ThemeSwitcherArea> createState() => ThemeSwitcherAreaState();
}

class ThemeSwitcherAreaState extends State<ThemeSwitcherArea>
    with SingleTickerProviderStateMixin {
  final _repaintKey = GlobalKey();
  _ThemeSwitcherBaseState? _baseState;

  late final _animController = AnimationController(
    vsync: this,
    duration: widget.defaultAnimDuration,
  );
  ui.Image? _image;
  Offset? _tapOffset;

  _ThemeSwitcherBaseState get _getBaseState =>
      _baseState ??= _ThemeSwitcherBaseInherited.of(context);

  @override
  void dispose() {
    _animController.dispose();
    _image = null;

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_getBaseState.themeMode == ThemeMode.system) {
      MediaQuery.platformBrightnessOf(context); // subscribing
      if (_repaintKey.currentContext != null) {
        changeTheme(newMode: ThemeMode.system, ignoreIfSame: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // return RepaintBoundary(
    //   key: _repaintKey,
    //   child: _ThemeSwitcherAreaInherited(
    //     state: this,
    //     child: AnimatedBuilder(
    //       animation: _animController,
    //       builder: (context, child) {
    //         if (!_animController.isAnimating) _image = null;
    //         final isReversed =
    //             _animController.status == AnimationStatus.reverse;
    //         final isNotReversed =
    //             _animController.status == AnimationStatus.forward;

    //         return Stack(
    //           children: [
    //             if (isNotReversed && _image != null) RawImage(image: _image),
    //             ClipPath(
    //               clipper: _image != null && isNotReversed
    //                   ? _ThemeClipper(_animController.value, _tapOffset, false)
    //                   : null,
    //               child: widget.child,
    //             ),
    //             if (isReversed && _image != null)
    //               ClipPath(
    //                 clipper: _ThemeClipper(
    //                   _animController.value,
    //                   _tapOffset,
    //                   false,
    //                 ),
    //                 child: RawImage(image: _image),
    //               ),
    //           ],
    //         );
    //       },
    //     ),
    //   ),
    // );
    return _ThemeSwitcherAreaInherited(
      state: this,
      child: Stack(
        children: [
          RepaintBoundary(key: _repaintKey, child: widget.child),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                if (!_animController.isAnimating || _image == null) {
                  return const SizedBox();
                }

                return ClipPath(
                  clipper: _ThemeClipper(
                    1 - _animController.value,
                    _tapOffset,
                    _animController.status == AnimationStatus.reverse,
                  ),
                  child: RawImage(image: _image),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool get isAnimating => _animController.isAnimating;

  bool willAnimate(ThemeMode newMode) =>
      !themeEquals(newMode, _getBaseState.themeMode);

  Future<void> changeTheme({
    required ThemeMode newMode,
    Offset? tapOffset,
    Duration? animationDuration,
    bool reversed = false,
    bool ignoreIfSame = true,
  }) async {
    final effectiveMode = newMode != ThemeMode.system
        ? newMode
        : _getSystemTheme(context);

    final animationStyle = effectiveMode == ThemeMode.light
        ? widget.lightModeStyle
        : widget.darkModeStyle;

    if (animationStyle != null) {
      if (animationStyle.fromCenter) tapOffset = null;
      reversed = !animationStyle.forward;
    }

    _tapOffset = tapOffset;

    if (_animController.isAnimating) return;

    if (ignoreIfSame) {
      if (newMode == _getBaseState.themeMode) return;
      if (themeEquals(newMode, _getBaseState.themeMode, true)) {
        _getBaseState.switchTheme(newMode);
        return;
      }
    }

    await _screenShot();

    _getBaseState.switchTheme(newMode);
    _animController.duration = animationDuration ?? widget.defaultAnimDuration;

    if (reversed) {
      return _animController.reverse(from: 1);
    } else {
      return _animController.forward(from: 0);
    }
  }

  bool themeEquals(ThemeMode a, ThemeMode b, [bool subscribe = false]) {
    if (a == b) return true;
    if (a != ThemeMode.system && b != ThemeMode.system) return false;

    final systemTheme = _getSystemTheme(context, subscribe);

    if (a == ThemeMode.system && b == systemTheme) return true;
    if (b == ThemeMode.system && a == systemTheme) return true;

    return false;
  }

  Future<void> _screenShot() async {
    final repaintBoundry =
        _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    _image = await repaintBoundry.toImage(
      pixelRatio: View.of(context).devicePixelRatio,
    );
  }
}

class _ThemeClipper extends CustomClipper<Path> {
  final double animValue;
  final bool isInverted;
  final Offset? expandFrom;

  _ThemeClipper(this.animValue, this.expandFrom, this.isInverted);

  @override
  Path getClip(Size size) {
    final path = Path();
    final expandFrom = this.expandFrom ?? size.center(Offset.zero);
    final expandDistance = expandFrom.distance;

    final offset = expandDistance - size.center(Offset.zero).distance * 2;
    final radius =
        expandDistance +
        (offset.isNegative ? -offset : offset); // make the offset positive

    path.addOval(
      Rect.fromCenter(
        center: expandFrom,
        width: 2 * radius * animValue,
        height: 2 * radius * animValue,
      ),
    );

    if (isInverted) {
      return Path.combine(
        PathOperation.reverseDifference,
        path,
        Path()..addRect(Offset.zero & size),
      );
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => true;
}

class _ThemeSwitcherAreaInherited extends InheritedWidget {
  const _ThemeSwitcherAreaInherited({
    required super.child,
    required this.state,
  });
  final ThemeSwitcherAreaState state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static ThemeSwitcherAreaState of(BuildContext context) => context
      .getInheritedWidgetOfExactType<_ThemeSwitcherAreaInherited>()!
      .state;
}

final class ThemeSwitcherAnimationStyle {
  final bool fromCenter;
  final bool forward;
  final Duration duration;
  final Curve curve;

  const ThemeSwitcherAnimationStyle({
    this.fromCenter = false,
    this.forward = true,
    this.duration = Durations.medium1,
    this.curve = Curves.linear,
  });
}
