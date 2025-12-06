import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class PointerLinkerWidget extends StatefulWidget {
  const PointerLinkerWidget({
    super.key,
    this.transfromPointerSignal = true,
    this.transfromPointerDown = true,
    this.transfromPointerUp = true,
    this.transfromPointerCancel = true,
    this.transfromPointerHover = true,
    this.transfromPointerMove = true,
    this.transfromPointerPanZoomEnd = true,
    this.transfromPointerPanZoomStart = true,
    this.transfromPointerPanZoomUpdate = true,
    this.behavior = HitTestBehavior.deferToChild,
    required this.targetKey,
    required this.child,
  });

  const PointerLinkerWidget.only({
    super.key,
    this.transfromPointerSignal = false,
    this.transfromPointerDown = false,
    this.transfromPointerUp = false,
    this.transfromPointerCancel = false,
    this.transfromPointerHover = false,
    this.transfromPointerMove = false,
    this.transfromPointerPanZoomEnd = false,
    this.transfromPointerPanZoomStart = false,
    this.transfromPointerPanZoomUpdate = false,
    this.behavior = HitTestBehavior.deferToChild,
    required this.targetKey,
    required this.child,
  });

  final Widget child;
  final GlobalKey targetKey;
  final HitTestBehavior behavior;
  final bool transfromPointerSignal;
  final bool transfromPointerDown;
  final bool transfromPointerUp;
  final bool transfromPointerCancel;
  final bool transfromPointerHover;
  final bool transfromPointerMove;
  final bool transfromPointerPanZoomEnd;
  final bool transfromPointerPanZoomStart;
  final bool transfromPointerPanZoomUpdate;

  @override
  State<PointerLinkerWidget> createState() => _PointerLinkerWidgetState();
}

class _PointerLinkerWidgetState extends State<PointerLinkerWidget> {
  final GlobalKey _remoteKey = GlobalKey();

  RenderBox? get _getTargetBox =>
      widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? get _getRemoteBox =>
      _remoteKey.currentContext?.findRenderObject() as RenderBox?;

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: _remoteKey,
      behavior: widget.behavior,
      onPointerSignal: widget.transfromPointerSignal
          ? _handelPointerEvent
          : null,
      onPointerDown: widget.transfromPointerDown ? _handelPointerEvent : null,
      onPointerUp: widget.transfromPointerUp ? _handelPointerEvent : null,
      onPointerCancel: widget.transfromPointerCancel
          ? _handelPointerEvent
          : null,
      onPointerHover: widget.transfromPointerHover ? _handelPointerEvent : null,
      onPointerMove: widget.transfromPointerMove ? _handelPointerEvent : null,
      onPointerPanZoomEnd: widget.transfromPointerPanZoomEnd
          ? _handelPointerEvent
          : null,
      onPointerPanZoomStart: widget.transfromPointerPanZoomStart
          ? _handelPointerEvent
          : null,
      onPointerPanZoomUpdate: widget.transfromPointerPanZoomUpdate
          ? _handelPointerEvent
          : null,
      child: widget.child,
    );
  }

  void _handelPointerEvent(PointerEvent event) {
    final targetBox = _getTargetBox;
    final remoteBox = _getRemoteBox;

    if (targetBox == null || remoteBox == null) return;

    final isWithinTargetBoudnries = _isWithinTargetBoudnries(
      targetBox: targetBox,
      remoteBox: remoteBox,
      localPosition: event.localPosition,
    );

    if (isWithinTargetBoudnries) return;

    GestureBinding.instance.handlePointerEvent(
      event.copyWith(
        pointer: event.pointer + 1,
        position: _calcPosition(
          targetBox: targetBox,
          remoteBox: remoteBox,
          localPosition: event.localPosition,
        ),
      ),
    );
  }

  Offset _calcPosition({
    required final RenderBox targetBox,
    required final RenderBox remoteBox,
    required final Offset localPosition,
    bool normalizePosition = true,
  }) {
    return targetBox.localToGlobal(
      normalizePosition
          ? Offset(
              (localPosition.dx / remoteBox.size.width) * targetBox.size.width,
              (localPosition.dy / remoteBox.size.height) *
                  targetBox.size.height,
            )
          : Offset(
              localPosition.dx - remoteBox.size.width + remoteBox.size.width,
              localPosition.dy - remoteBox.size.height + remoteBox.size.height,
            ),
    );
  }

  bool _isWithinTargetBoudnries({
    required final RenderBox targetBox,
    required final RenderBox remoteBox,
    required final Offset localPosition,
  }) {
    final targetRect = targetBox.localToGlobal(Offset.zero) & targetBox.size;
    final globalTapPos = remoteBox.localToGlobal(localPosition);

    return targetRect.contains(globalTapPos);
  }
}
