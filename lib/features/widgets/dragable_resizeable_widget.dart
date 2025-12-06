

// class DragableResizableWidget extends StatefulWidget {
//   const DragableResizableWidget({
//     super.key,
//     this.minSize = const Size(100, 100),
//     this.maxSize = Size.infinite,
//     this.onChanged,
//     this.borderColor = Colors.black,
//     this.borderWidth = .05,
//     required this.rect,
//     required this.child,
//   });

//   final Rect rect;
//   final Size minSize;
//   final Size maxSize;
//   final Widget child;
//   final Color borderColor;
//   final double borderWidth;
//   final void Function(Rect rect)? onChanged;

//   @override
//   State<DragableResizableWidget> createState() =>
//       _DragableResizableWidgetState();
// }

// class _DragableResizableWidgetState extends State<DragableResizableWidget> {
//   late Rect rect = widget.rect;

//   @override
//   void didUpdateWidget(DragableResizableWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.rect != widget.rect) rect = widget.rect;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fromRect(
//       rect: rect,
//       child: ResizableWidget(
//         thickness: widget.borderWidth,
//         color: widget.borderColor,
//         rect: rect,
//         minSize: widget.minSize,
//         maxSize: widget.maxSize,
//         onChanged: (newRect) {
//           setState(() => rect = newRect);
//           widget.onChanged?.call(rect);
//         },
//         child: DragableWidget(
//           onChanged: (offset) {
//             setState(() => rect = offset & rect.size);
//             widget.onChanged?.call(rect);
//           },
//           offset: rect.topLeft,
//           child: widget.child,
//         ),
//       ),
//     );
//   }
// }

// class DragableWidget extends StatefulWidget {
//   const DragableWidget({
//     super.key,
//     required this.offset,
//     required this.child,
//     required this.onChanged,
//     this.onStart,
//     this.onEnd,
//   });

//   final Widget child;
//   final Offset offset;
//   final void Function(Offset offset) onChanged;
//   final void Function(Offset offset)? onStart;
//   final void Function(Offset offset)? onEnd;

//   @override
//   State<DragableWidget> createState() => _DragableWidgetState();
// }

// class _DragableWidgetState extends State<DragableWidget> {
//   late Offset _initOffset = widget.offset;
//   Offset _panLocalPos = Offset.zero;
//   bool _isMoving = false;

//   @override
//   void didUpdateWidget(covariant DragableWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (!_isMoving) _initOffset = widget.offset;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanStart: (details) {
//         _isMoving = true;
//         _initOffset = widget.offset;
//         _panLocalPos = details.localPosition;
//         widget.onStart?.call(widget.offset);
//       },
//       onPanUpdate: (details) {
//         widget.onChanged(details.localPosition + _initOffset - _panLocalPos);
//       },
//       onPanEnd: (details) {
//         _isMoving = false;
//         widget.onEnd?.call(widget.offset);
//       },
//       child: widget.child,
//     );
//   }
// }

// class ResizableWidget extends StatefulWidget {
//   const ResizableWidget({
//     super.key,
//     this.thickness = .05,
//     this.color = Colors.black,
//     required this.child,
//     required this.rect,
//     required this.onChanged,
//     this.onStart,
//     this.onEnd,
//     this.minSize = Size.zero,
//     this.maxSize = Size.infinite,
//   });

//   final Widget child;
//   final Rect rect;
//   final Color color;
//   final double thickness;
//   final Size minSize;
//   final Size maxSize;
//   final void Function(Rect newRect) onChanged;
//   final void Function(Rect newRect)? onStart;
//   final void Function(Rect newRect)? onEnd;

//   @override
//   State<ResizableWidget> createState() => _ResizableWidgetState();
// }

// class _ResizableWidgetState extends State<ResizableWidget> {
//   late Rect _initRect = widget.rect;
//   Offset _localPanPos = Offset.zero;
//   bool _isResizing = false;

//   @override
//   void didUpdateWidget(ResizableWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (!_isResizing) _initRect = widget.rect;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         DecoratedBox(
//           decoration: BoxDecoration(
//             border: Border.symmetric(
//               horizontal: BorderSide(
//                 color: widget.color,
//                 width: widget.rect.height * widget.thickness,
//               ),
//               vertical: BorderSide(
//                 color: widget.color,
//                 width: widget.rect.width * widget.thickness,
//               ),
//             ),
//           ),
//           position: DecorationPosition.foreground,
//           child: widget.child,
//         ),

//         ..._Position.values.map(_buildRegions),
//       ],
//     );
//   }

//   Widget _buildRegions(_Position position) {
//     assert(
//       !position.containsTop ||
//           position.containsTop &&
//               position.containsTop != position.containsBottom,
//     );
//     assert(
//       !position.containsBottom ||
//           position.containsBottom &&
//               position.containsTop != position.containsBottom,
//     );

//     assert(
//       !position.containsLeft ||
//           position.containsLeft &&
//               position.containsLeft != position.containsRight,
//     );
//     assert(
//       !position.containsRight ||
//           position.containsRight &&
//               position.containsLeft != position.containsRight,
//     );

//     final vThickness = widget.thickness * widget.rect.height;
//     final hThickness = widget.thickness * widget.rect.width;

//     final height = position.isVertical ? vThickness : null;
//     final width = position.isHorizontal ? hThickness : null;

//     final top = position.containsTop
//         ? 0.0
//         : !position.isVertical
//         ? vThickness
//         : null;
//     final bottom = position.containsBottom
//         ? 0.0
//         : !position.isVertical
//         ? vThickness
//         : null;

//     final right = position.containsRight
//         ? 0.0
//         : !position.isHorizontal
//         ? hThickness
//         : null;
//     final left = position.containsLeft
//         ? 0.0
//         : !position.isHorizontal
//         ? hThickness
//         : null;

//     return Positioned(
//       width: width,
//       height: height,
//       top: top,
//       right: right,
//       bottom: bottom,
//       left: left,
//       child: GestureDetector(
//         onPanStart: _onStart,
//         onPanUpdate: (details) => _onUpdate(details, position),
//         onPanEnd: _onEnd,
//         child: MouseRegion(
//           cursor: switch (position) {
//             _Position.top => SystemMouseCursors.resizeUp,
//             _Position.right => SystemMouseCursors.resizeRight,
//             _Position.bottom => SystemMouseCursors.resizeDown,
//             _Position.left => SystemMouseCursors.resizeLeft,
//             _Position.topRight => SystemMouseCursors.resizeUpRight,
//             _Position.topLeft => SystemMouseCursors.resizeUpLeft,
//             _Position.bottomRight => SystemMouseCursors.resizeDownRight,
//             _Position.bottomLeft => SystemMouseCursors.resizeDownLeft,
//           },
//         ),
//       ),
//     );
//   }

//   void _onStart(DragStartDetails details) {
//     _initRect = widget.rect;
//     _isResizing = true;
//     _localPanPos = details.localPosition;
//     widget.onStart?.call(_initRect);
//   }

//   void _onUpdate(DragUpdateDetails details, _Position position) {
//     var dx = position.isHorizontal
//         ? details.localPosition.dx - _localPanPos.dx
//         : 0;
//     var dy = position.isVertical
//         ? details.localPosition.dy - _localPanPos.dy
//         : 0;

//     if (position.containsRight) {
//       dx = dx.clamp(
//         widget.minSize.width - _initRect.width,
//         _initRect.width + widget.maxSize.width,
//       );
//     } else {
//       dx = (-dx).clamp(
//         widget.minSize.width - _initRect.width,
//         _initRect.width + widget.maxSize.width,
//       );
//       dx = -dx;
//     }

//     if (position.containsBottom) {
//       dy = dy.clamp(
//         widget.minSize.height - _initRect.height,
//         _initRect.height + widget.maxSize.height,
//       );
//     } else {
//       dy = (-dy).clamp(
//         widget.minSize.height - _initRect.height,
//         _initRect.height + widget.maxSize.height,
//       );
//       dy = -dy;
//     }

//     final leftDelta = position.containsLeft ? dx : 0;
//     final widthDelta = position.containsRight ? dx : -dx;

//     final topDelta = position.containsTop ? dy : 0;
//     final heightDelta = position.containsBottom ? dy : -dy;

//     var rect = Rect.fromLTWH(
//       _initRect.left + leftDelta,
//       _initRect.top + topDelta,
//       _initRect.width + widthDelta,
//       _initRect.height + heightDelta,
//     );

//     widget.onChanged(rect);
//   }

//   void _onEnd(DragEndDetails details) {
//     _isResizing = false;
//     widget.onEnd?.call(widget.rect);
//   }
// }

// enum _Position {
//   top(1), // 0001
//   bottom(2), // 0010
//   right(4), // 0100
//   left(8), // 1000

//   topRight(5), // 0101
//   bottomRight(6), // 0110
//   topLeft(9), // 0101
//   bottomLeft(10); // 1010

//   const _Position(this.value);
//   final int value;

//   bool get containsTop => value >> 0 & 1 == 1;
//   bool get containsBottom => value >> 1 & 1 == 1;
//   bool get containsRight => value >> 2 & 1 == 1;
//   bool get containsLeft => value >> 3 & 1 == 1;
//   bool get isVertical => value & 11.b > 0;
//   bool get isHorizontal => value & 1100.b > 0;
// }

// extension IntExtension on int {
//   int get b => int.parse(toRadixString(10), radix: 2);
// }

// // import 'package:flutter/material.dart';
// // import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
// // import 'package:implicitly_animated_reorderable_list_2/transitions.dart'; // For custom transitions if needed

// // class TestScreen extends StatefulWidget {
// //   const TestScreen({super.key});

// //   @override
// //   State<TestScreen> createState() => _TestScreenState();
// // }

// // class _TestScreenState extends State<TestScreen> {
// //   // Sample items with unique keys for diffing/tracking
// //   List<int> items = List.generate(12, (index) => index);

// //   // Shuffle the list (triggers implicit animation via diffing)
// //   void _shuffleItems() {
// //     setState(() {
// //       items
// //           .shuffle(); // Direct shuffle—package detects & animates repositioning
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Animated Shuffle Grid')),
// //       body: Column(
// //         children: [
// //           // Grid with implicit animations on list changes
// //           Expanded(
// //             child: ImplicitlyAnimatedReorderableList<int>(
// //               // Or use .list for row-based
// //               items: items, // The list to animate changes on
// //               itemBuilder: (context, animation, value, index) {
// //                 return Reorderable(
// //                   key: ValueKey(value),
// //                   child: SlideTransition(
// //                     // Default positional slide; customize as needed
// //                     position:
// //                         Tween<Offset>(
// //                           begin: const Offset(
// //                             0,
// //                             -0.1,
// //                           ), // Slight offset for reposition feel
// //                           end: Offset.zero,
// //                         ).animate(
// //                           CurvedAnimation(
// //                             parent: animation,
// //                             curve: Curves.easeInOut,
// //                           ),
// //                         ),
// //                     child: SizeFadeTransition(
// //                       animation: animation,
// //                       child: Card(
// //                         color:
// //                             Colors.primaries[value % Colors.primaries.length],
// //                         child: SizedBox(
// //                           height: 70,
// //                           child: Center(
// //                             child: Text(
// //                               value.toString(),
// //                               style: const TextStyle(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //               onReorderFinished: (item, from, to, newItems) {},
// //               areItemsTheSame: (oldItem, newItem) =>
// //                   oldItem == newItem, // For diffing same items
// //               physics:
// //                   const AlwaysScrollableScrollPhysics(), // Enable scrolling if needed
// //             ),
// //           ),
// //           // Shuffle button
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: ElevatedButton(
// //               onPressed: _shuffleItems,
// //               child: const Text('Shuffle Items'),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }