import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/constants/constants.dart' as c;

class AnimatedLineSelector extends StatefulWidget {
  final List<Widget> children;
  final int selectedIndex;
  final Duration animationDuration;
  final Color trackColor;
  final Color thumColor;
  final double trackThickness;
  final double thumRadius;
  final double childrenSpacing;
  final double gap;
  final Curve curve;
  final void Function(int index)? onSelectionChanged;

  const AnimatedLineSelector({
    super.key,
    required this.children,
    required this.selectedIndex,
    this.animationDuration = c.animationDuration,
    this.trackColor = Colors.grey,
    this.thumColor = Colors.blue,
    this.trackThickness = 2.0,
    this.thumRadius = 6.0,
    this.childrenSpacing = 30,
    this.gap = 10,
    this.curve = Curves.easeInOut,
    this.onSelectionChanged,
  }) : assert(children.length > 0, 'Children list cannot be empty'),
       assert(
         selectedIndex >= 0 && selectedIndex < children.length,
         'Selected index must be within the range of children',
       );

  @override
  State<AnimatedLineSelector> createState() => _AnimatedLineSelectorState();
}

class _AnimatedLineSelectorState extends State<AnimatedLineSelector>
    with SingleTickerProviderStateMixin {
  final _sliderKey = GlobalKey();
  final List<({double start, double end})> _positions = [];
  final _sliderPosition = ValueNotifier<double>(0);

  late final List<GlobalKey> _keys;
  late final _animationController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  );
  bool _isSliding = false;
  bool _isClickOnly = false;

  @override
  void initState() {
    super.initState();

    _keys = widget.children.map((e) => GlobalKey()).toList();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _snapToPosition(widget.selectedIndex);
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedLineSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.children.length != widget.children.length) {
      _keys
        ..clear()
        ..addAll(widget.children.map((e) => GlobalKey()));
    }

    if (widget.selectedIndex != oldWidget.selectedIndex && !_isSliding) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _snapToPosition(widget.selectedIndex);
      });
    }

    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getSlider(),
          SizedBox(height: widget.gap),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: widget.childrenSpacing,
              // children: widget.children,
              children: List.generate(widget.children.length, _itemBiulder),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemBiulder(int index) {
    return SizedBox(
      key: _keys[index],
      child: widget.children[index],
    );
  }

  Widget _getSlider() {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: widget.trackThickness,
        trackShape: const RectangularSliderTrackShape(),
        overlayColor: CustomColors.green.withAlpha(30),
        thumbColor: CustomColors.green,
        overlayShape: MyOverlayShape(widget.thumRadius * 3),
        activeTrackColor: CustomColors.lightGreen,
        inactiveTrackColor: CustomColors.lightGreen,
        padding: EdgeInsets.zero,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: widget.thumRadius,
        ),
      ),
      child: ListenableBuilder(
        listenable: _sliderPosition,
        builder: (context, child) => SizedBox(
          child: Slider(
            key: _sliderKey,
            padding: EdgeInsets.zero,
            value: _sliderPosition.value.clamp(0, 1),
            onChangeStart: _onChangeStart,
            onChanged: _onChanged,
            onChangeEnd: _onChangeEnd,
          ),
        ),
      ),
    );
  }

  void _onChangeStart(double value) {
    _isSliding = true;
    _isClickOnly = true;
    _refreshPositions();
  }

  void _onChanged(double value) {
    _animationController.stop();

    final currentlySelected = _getSelectedIndex(value);

    if (_isClickOnly) {
      _animateToPosition(value);
    } else {
      _sliderPosition.value = value;
    }

    _isClickOnly = false;

    _notifyWidget(currentlySelected);
  }

  void _onChangeEnd(double value) {
    _isSliding = false;
    _snapToPosition(widget.selectedIndex);
  }

  void _notifyWidget(int newIndex) {
    if (newIndex == widget.selectedIndex) return;
    widget.onSelectionChanged?.call(newIndex);
  }

  void _scrollToValue(int index) {
    final targetObject = _keys[index].currentContext?.findRenderObject();
    final scrollable = Scrollable.maybeOf(context);

    if (scrollable == null || targetObject == null) return;

    scrollable.position.ensureVisible(
      targetObject,
      alignment: .5,
      duration: widget.animationDuration,
      curve: widget.curve,
    );

    // void _scrollToValue(GlobalKey key) {
    // final targetObject = key.currentContext?.findRenderObject();
    // final scrollable = Scrollable.maybeOf(context);
    // final viewPort = RenderAbstractViewport.maybeOf(targetObject);
    // final maxWidth = _sliderKey.currentContext?.size?.width;

    // if (scrollable == null ||
    //     targetObject == null ||
    //     viewPort == null ||
    //     maxWidth == null) {
    //   return;
    // }

    // final revealedOffset = viewPort
    //     .getOffsetToReveal(
    //       targetObject,
    //       .5,
    //       axis: scrollable.position.axis,
    //     )
    //     .offset
    //     .clamp(
    //       scrollable.position.minScrollExtent,
    //       scrollable.position.maxScrollExtent,
    //     );

    // scrollable.position.ensureVisible(
    //   targetObject,
    //   alignment: .5,
    //   duration: widget.animationDuration,
    //   curve: widget.curve,
    // );

    // print(revealedOffset / maxWidth);

    // _animateToPosition(
    //   revealedOffset.offset / maxWidth + _sliderPosition.value,
    // );
  }

  int _getSelectedIndex(double value) {
    int result = _positions.length - 1;

    for (var i = 0; i < _positions.length - 1; i++) {
      final end = _positions[i].end;
      final gap = _positions[i + 1].start - end;

      if (value <= end + gap / 2) {
        result = i;
        break;
      }
    }

    return result;
  }

  void _snapToPosition(int index) {
    _refreshPositions();

    final newPos = (_positions[index].end + _positions[index].start) / 2;
    _animateToPosition(newPos);

    _scrollToValue(index);
  }

  void _animateToPosition(double newPos, [double? oldPos]) {
    oldPos ??= _sliderPosition.value;

    void listener() {
      final value = widget.curve.transform(_animationController.value);

      _sliderPosition.value = lerpDouble(oldPos, newPos, value)!;
    }

    if (_animationController.isAnimating) {
      _animationController.removeListener(listener);
    }

    _animationController.addListener(listener);
    _animationController.forward(from: 0).whenCompleteOrCancel(
      () {
        _animationController.removeListener(listener);
      },
    );
  }

  void _refreshPositions() {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final maxWidth = _sliderKey.currentContext?.size?.width ?? 1;

    ({double start, double end}) calcPosAndCenter(GlobalKey key) {
      if (key.currentContext == null) return (end: 0, start: 0);
      final renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final pos = renderBox.localToGlobal(
        Offset.zero,
        ancestor: _sliderKey.currentContext?.findRenderObject() as RenderBox?,
      );
      final effectivePos = isRtl ? maxWidth - pos.dx - size.width : pos.dx;

      return (
        start: effectivePos / maxWidth,
        end: (effectivePos + size.width) / maxWidth,
      );
    }

    _positions
      ..clear()
      ..addAll(_keys.map(calcPosAndCenter).toList());
  }
}

class MyOverlayShape extends SliderComponentShape {
  final double radius;

  MyOverlayShape(this.radius);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final paint = Paint()
      ..color = sliderTheme.overlayColor ?? Colors.transparent;

    context.canvas.drawCircle(
      center,
      radius * activationAnimation.value,
      paint,
    );
  }
}
