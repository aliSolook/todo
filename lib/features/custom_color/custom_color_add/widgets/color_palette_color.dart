// import 'package:defer_pointer/defer_pointer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:todo/constants/constants.dart';

// class ColorBuilder extends StatelessWidget {
//   const ColorBuilder({
//     super.key,
//     required this.color,
//     this.isSelected = true,
//     this.child,
//     this.icon,
//     this.shadow = 1,
//     this.shadowColor,
//     this.overrideOverlayColor = true,
//     this.onPressed,
//     this.delay,
//     this.onDelete,
//     this.deleteInProgress = false,
//   });

//   final Color color;
//   final bool isSelected;
//   final Widget? child;
//   final Widget? icon;
//   final double shadow;
//   final Color? shadowColor;
//   final bool overrideOverlayColor;
//   final VoidCallback? onPressed;
//   final double? delay;
//   final VoidCallback? onDelete;
//   final bool deleteInProgress;

//   @override
//   Widget build(BuildContext context) {
//     assert(shadow >= 0);

//     // final forgroundColor = Color.fromARGB(
//     //   255,
//     //   (1 - color.r) * 255 ~/ 1,
//     //   (1 - color.g) * 255 ~/ 1,
//     //   (1 - color.b) * 255 ~/ 1,
//     // );
//     final forgroundColor = useWhiteForeground(color)
//         ? Colors.white
//         : Colors.black;

//     Widget effectiveChild = DecoratedBox(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color,
//         boxShadow: [
//           BoxShadow(
//             color: (shadowColor ?? color).withAlpha(0.8 * 255 ~/ 1),
//             offset: const Offset(1, 2) * shadow,
//             blurRadius: 5 * shadow,
//           ),
//         ],
//       ),
//       child:
//           child ??
//           IconButton(
//             style: IconButton.styleFrom(
//               padding: EdgeInsets.zero,
//               overlayColor: overrideOverlayColor ? forgroundColor : null,
//             ),
//             onPressed: onPressed,
//             icon:
//                 icon ??
//                 AnimatedOpacity(
//                   duration: const Duration(milliseconds: 210),
//                   opacity: isSelected ? 1 : 0,
//                   child: Icon(
//                     Icons.done,
//                     color: forgroundColor,
//                   ),
//                 ),
//           ),
//     );

//     const deleteIconOffset = Offset(-10, -10);
//     const deleteIconSize = Size(25, 25);

//     return TweenAnimationBuilder(
//       duration: Durations.short1 * (delay ?? 0) * 2,
//       tween: Tween<double>(begin: 0, end: 1),
//       curve: const Interval(.5, 1),
//       builder: (context, value, child) => Opacity(opacity: value, child: child),
//       child: onDelete == null
//           ? effectiveChild
//           : Stack(
//               clipBehavior: Clip.none,
//               alignment: AlignmentDirectional.topStart,
//               children: [
//                 effectiveChild,
//                 Builder(
//                   builder: (context) => Positioned(
//                     top: deleteIconOffset.dy,
//                     right: Directionality.of(context) == TextDirection.rtl
//                         ? deleteIconOffset.dx
//                         : null,
//                     left: Directionality.of(context) == TextDirection.ltr
//                         ? deleteIconOffset.dx
//                         : null,
//                     width: deleteIconSize.width,
//                     height: deleteIconSize.height,
//                     child: ClipPath(
//                       clipper: _ShadowOnlyClipper(
//                         const CircleBorder(),
//                         const EdgeInsets.all(100),
//                       ),
//                       child: DecoratedBox(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: ColorScheme.of(context).shadow,
//                               offset: const Offset(1, 2),
//                               blurRadius: 5,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Builder(
//                   builder: (context) => Positioned(
//                     top: deleteIconOffset.dy,
//                     right: Directionality.of(context) == TextDirection.rtl
//                         ? deleteIconOffset.dx
//                         : null,
//                     left: Directionality.of(context) == TextDirection.ltr
//                         ? deleteIconOffset.dx
//                         : null,
//                     width: deleteIconSize.width,
//                     height: deleteIconSize.height,
//                     child: AnimatedSwitcher(
//                       duration: animationDuration,
//                       child: deleteInProgress
//                           ? const CircularProgressIndicator(
//                               key: ValueKey(true),
//                               strokeCap: StrokeCap.round,
//                             )
//                           : DeferPointer(
//                               key: const ValueKey(false),
//                               child: IconButton(
//                                 style: IconButton.styleFrom(
//                                   padding: EdgeInsets.zero,
//                                 ),
//                                 onPressed: onDelete,
//                                 icon: const Icon(Icons.close),
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

// class _ShadowOnlyClipper extends CustomClipper<Path> {
//   final EdgeInsets padding;
//   final ShapeBorder shape;

//   _ShadowOnlyClipper(this.shape, this.padding);

//   @override
//   Path getClip(Size size) {
//     final path1 = shape.getOuterPath(Offset.zero & size);
//     final path2 = Path()
//       ..addRect(
//         Rect.fromLTRB(
//           -padding.left,
//           -padding.top,
//           size.width + padding.right,
//           size.height + padding.bottom,
//         ),
//       );

//     return Path.combine(PathOperation.reverseDifference, path1, path2);
//   }

//   @override
//   bool shouldReclip(_ShadowOnlyClipper oldClipper) =>
//       padding != oldClipper.padding || shape != oldClipper.shape;
// }

import 'package:flutter/material.dart';
import 'package:todo/features/custom_color/custom_color.dart';

class ColorPaletteColor extends StatelessWidget {
  const ColorPaletteColor({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onPressed,
    this.shadowMultiplier = 1,
    this.delay,
  });

  final Color color;
  final bool isSelected;
  final double shadowMultiplier;
  final VoidCallback onPressed;
  final double? delay;

  @override
  Widget build(BuildContext context) {
    return ColorPaletteItem(
      delay: delay,
      backgroundColor: color,
      onPressed: onPressed,
      shadowMultiplier: shadowMultiplier,
      icon: AnimatedOpacity(
        duration: const Duration(milliseconds: 210),
        opacity: isSelected ? 1 : 0,
        child: const Icon(Icons.done),
      ),
    );
  }
}
