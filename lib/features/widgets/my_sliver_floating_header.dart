import 'package:flutter/material.dart';
import 'package:todo/constants/constants.dart';

typedef MyFloatingHeaderWidgetBuilder =
    Widget Function(
      BuildContext context,
      double shrinkoffset,
      bool overlapsContent,
    );

class MySliverFloatingHeader extends StatefulWidget {
  const MySliverFloatingHeader({
    super.key,
    this.height = kToolbarHeight,
    this.topPadding = 0,
    this.inSafeArea = true,
    this.duration = animationDuration,
    this.floating = true,
    this.decoration,
    this.floatingDecoration,
    required Widget child,
  }) : _child = child,
       _builder = null;

  const MySliverFloatingHeader.builder({
    super.key,
    this.height = kToolbarHeight,
    this.topPadding = 0,
    this.inSafeArea = true,
    this.duration = animationDuration,
    this.decoration,
    this.floatingDecoration,
    this.floating = true,
    required MyFloatingHeaderWidgetBuilder builder,
  }) : _builder = builder,
       _child = null;

  final double height;
  final double topPadding;
  final bool inSafeArea;
  final Duration duration;
  final Decoration? decoration;
  final Decoration? floatingDecoration;
  final MyFloatingHeaderWidgetBuilder? _builder;
  final Widget? _child;
  final bool floating;

  @override
  State<MySliverFloatingHeader> createState() => _MySliverFloatingHeaderState();
}

class _MySliverFloatingHeaderState extends State<MySliverFloatingHeader>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      floating: widget.floating,
      delegate: _Delegate(
        context: context,
        animationDuration: widget.duration,
        inSafeArea: widget.inSafeArea,
        height: widget.height,
        topPadding: widget.topPadding,
        foreignVsync: this,
        decoration: widget.decoration ?? const BoxDecoration(),
        floatingDecoration: widget.floatingDecoration ?? const BoxDecoration(),
        builder: widget._builder ?? (_, _, _) => widget._child!,
      ),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final double height;
  final Duration animationDuration;
  final TickerProvider foreignVsync;
  final Decoration floatingDecoration;
  final Decoration decoration;
  final bool inSafeArea;
  final MyFloatingHeaderWidgetBuilder builder;
  final BuildContext context;

  _Delegate({
    required this.context,
    required this.inSafeArea,
    required this.height,
    required this.animationDuration,
    required this.topPadding,
    required this.foreignVsync,
    required this.decoration,
    required this.floatingDecoration,
    required this.builder,
  });

  @override
  TickerProvider? get vsync => foreignVsync;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final topPadding =
        this.topPadding + (inSafeArea ? MediaQuery.paddingOf(context).top : 0);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: TweenAnimationBuilder(
        duration: animationDuration,
        tween: Tween<double>(end: overlapsContent ? 1 : 0),
        builder: (context, value, child) {
          return DecoratedBox(
            decoration: Decoration.lerp(decoration, floatingDecoration, value)!,
            child: child,
          );
        },
        child: builder(context, shrinkOffset, overlapsContent),
      ),
    );
  }

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent =>
      height +
      (topPadding + (inSafeArea ? MediaQuery.paddingOf(context).top : 0));

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) {
    return topPadding != oldDelegate.topPadding ||
        height != oldDelegate.height ||
        foreignVsync != oldDelegate.foreignVsync ||
        decoration != oldDelegate.decoration ||
        floatingDecoration != oldDelegate.floatingDecoration ||
        builder != oldDelegate.builder;
  }
}
