import 'package:flutter/material.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/custom_color/custom_color.dart';

class ColorPaletteCustomColor extends StatelessWidget {
  ColorPaletteCustomColor({
    this.shadowMultiplier = 1,
    this.delay,
    required dynamic id,
    required this.isSelected,
    required this.color,
    required this.onPressed,
    required this.onDelete,
    required this.deleteInProgress,
  }) : super(key: generateKey(id));

  final VoidCallback onPressed;
  final Color color;
  final double shadowMultiplier;
  final bool isSelected;
  final double? delay;
  final VoidCallback? onDelete;
  final bool deleteInProgress;

  /// if id is null then returns null
  static Key? generateKey(dynamic id) =>
      id == null ? null : Key('color_palette_custom_color: $id');

  @override
  Widget build(BuildContext context) {
    const deleteIconOffset = Offset(-10, -10);
    const deleteIconSize = Size(25, 25);

    return ColorPaletteItem(
      delay: delay,
      shadowMultiplier: shadowMultiplier,
      backgroundColor: color,
      onPressed: onPressed,
      childBuilder: (context, foregroundColor, onPressed, icon) => Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.topStart,
        children: [
          IconButton(
            onPressed: onPressed,
            style: IconButton.styleFrom(
              foregroundColor: foregroundColor,
              overlayColor: foregroundColor,
            ),
            icon: AnimatedOpacity(
              duration: const Duration(milliseconds: 210),
              opacity: isSelected ? 1 : 0,
              child: const Icon(Icons.done),
            ),
          ),
          Builder(
            builder: (context) => Positioned(
              top: deleteIconOffset.dy,
              right: Directionality.of(context) == TextDirection.rtl
                  ? deleteIconOffset.dx
                  : null,
              left: Directionality.of(context) == TextDirection.ltr
                  ? deleteIconOffset.dx
                  : null,
              width: deleteIconSize.width,
              height: deleteIconSize.height,
              child: ClipPath(
                clipper: _ShadowOnlyClipper(
                  const CircleBorder(),
                  const EdgeInsets.all(100),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorScheme.of(context).shadow,
                        offset: const Offset(1, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Builder(
            builder: (context) => Positioned(
              top: deleteIconOffset.dy,
              right: Directionality.of(context) == TextDirection.rtl
                  ? deleteIconOffset.dx
                  : null,
              left: Directionality.of(context) == TextDirection.ltr
                  ? deleteIconOffset.dx
                  : null,
              width: deleteIconSize.width,
              height: deleteIconSize.height,
              child: AnimatedSwitcher(
                duration: animationDuration,
                child: deleteInProgress
                    ? const CircularProgressIndicator(
                        key: ValueKey(true),
                        strokeCap: StrokeCap.round,
                      )
                    : DeferPointer(
                        key: const ValueKey(false),
                        child: IconButton(
                          key: const Key('custom_color_delete_button'),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: onDelete,
                          icon: const Icon(Icons.close),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShadowOnlyClipper extends CustomClipper<Path> {
  final EdgeInsets padding;
  final ShapeBorder shape;

  _ShadowOnlyClipper(this.shape, this.padding);

  @override
  Path getClip(Size size) {
    final path1 = shape.getOuterPath(Offset.zero & size);
    final path2 = Path()
      ..addRect(
        Rect.fromLTRB(
          -padding.left,
          -padding.top,
          size.width + padding.right,
          size.height + padding.bottom,
        ),
      );

    return Path.combine(PathOperation.reverseDifference, path1, path2);
  }

  @override
  bool shouldReclip(_ShadowOnlyClipper oldClipper) =>
      padding != oldClipper.padding || shape != oldClipper.shape;
}
