import 'package:flutter/material.dart';
import 'package:todo/app.dart';

class DropdownBody extends StatefulWidget {
  const DropdownBody({
    super.key,
    required this.headerBuilder,
    required this.childBuilder,
    this.offset = Offset.zero,
    this.targetAnchor = Alignment.topLeft,
    this.followerAnchor = Alignment.topLeft,
    required this.isOpen,
    this.curve,
    this.reverseCurve,
    this.onTapOutside,
    required this.duration,
    this.reverseDuration,
  });

  final Widget Function(BuildContext context, Animation<double> animation)?
  headerBuilder;
  final Widget Function(BuildContext context, Animation<double> animation)
  childBuilder;
  final Offset offset;
  final AlignmentGeometry targetAnchor;
  final AlignmentGeometry followerAnchor;
  final bool isOpen;
  final Curve? curve;
  final Curve? reverseCurve;
  final Duration duration;
  final Duration? reverseDuration;
  final void Function(PointerDownEvent event)? onTapOutside;

  @override
  State<DropdownBody> createState() => _DropdownBodyState();
}

class _DropdownBodyState extends State<DropdownBody>
    with SingleTickerProviderStateMixin, RouteAware {
  final overlayController = OverlayPortalController();
  final link = LayerLink();
  late final AnimationController animationController;
  late final CurvedAnimation animation;
  late final RouteObserver observer;
  bool isTappedOutside = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    observer.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      value: widget.isOpen ? 1 : 0,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: widget.curve ?? Curves.linear,
      reverseCurve: widget.reverseCurve,
    );
    if (widget.isOpen) overlayController.show();
    observer = App.observerOf(context);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    overlayController.hide();
    super.didPop();
  }

  @override
  void didUpdateWidget(covariant DropdownBody oldWidget) {
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        if (!overlayController.isShowing) {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              overlayController.show();
              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) {
                  animationController.forward();
                },
              );
            },
          );
        }
      } else {
        animationController.reverse().then(
          (_) {
            if (widget.isOpen) return;
            overlayController.hide();
          },
        );
      }
    }
    if (widget.duration != oldWidget.duration) {
      animationController.duration = widget.duration;
    }
    if (widget.reverseDuration != oldWidget.reverseDuration) {
      animationController.reverseDuration = widget.reverseDuration;
    }
    if (widget.curve != oldWidget.curve ||
        widget.reverseCurve != oldWidget.reverseCurve) {
      animation.curve = widget.curve ?? Curves.linear;
      animation.reverseCurve = widget.reverseCurve;
      // animationController.reverseDuration = widget.closeDuration;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var direction = Directionality.of(context);
    var child = OverlayPortal(
      controller: overlayController,
      overlayChildBuilder: (context) {
        var child = Center(
          child: CompositedTransformFollower(
            followerAnchor: widget.followerAnchor.resolve(direction),
            targetAnchor: widget.targetAnchor.resolve(direction),
            offset: widget.offset,
            link: link,
            showWhenUnlinked: true,
            child: Listener(
              onPointerDown: (event) {
                isTappedOutside = false;
              },
              child: widget.childBuilder(context, animation),
            ),
          ),
        );

        if (widget.onTapOutside == null) return child;

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) async {
            await Future.delayed(
              Duration.zero,
            ); // waiting for the tap to reach the parent
            if (isTappedOutside) widget.onTapOutside!(event);
            isTappedOutside = true;
          },
          child: child,
        );
      },
      child: CompositedTransformTarget(
        link: link,
        child: widget.headerBuilder == null
            ? null
            : widget.headerBuilder!(context, animation),
      ),
    );

    if (widget.onTapOutside == null) return child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (overlayController.isShowing) isTappedOutside = false;
      },
      child: child,
    );
  }
}
