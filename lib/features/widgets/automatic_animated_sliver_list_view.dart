import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';

class AutomaticAnimatedSliverListView<T> extends StatefulWidget {
  const AutomaticAnimatedSliverListView({
    super.key,
    required this.list,
    required this.comparator,
    required this.itemBuilder,
    this.detectMoves = false,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.animator = const DefaultAnimatedListAnimator(),
    this.addLongPressReorderable = true,
    this.addAnimatedElevation = kDefaultAnimatedElevation,
    this.addFadeTransition = true,
    this.morphResizeWidgets = true,
    this.morphDuration = kDefaultMorphTransitionDuration,
    this.morphComparator,
    this.reorderModel,
    this.initialScrollOffsetCallback,
    this.didFinishLayoutCallback,
    this.holdScrollOffset = false,
  });

  final List<T> list;
  final Widget Function(
    BuildContext context,
    T item,
    AnimatedWidgetBuilderData data,
  )
  itemBuilder;
  final AnimatedListDiffListBaseComparator<T> comparator;
  final bool detectMoves;
  final double? itemExtent;
  final bool addAutomaticKeepAlives;

  final bool addRepaintBoundaries;
  final bool addLongPressReorderable;
  final double addAnimatedElevation;
  final bool addFadeTransition;
  final bool Function(Widget, Widget)? morphComparator;
  final bool morphResizeWidgets;
  final Duration morphDuration;
  final bool holdScrollOffset;
  final InitialScrollOffsetCallback? initialScrollOffsetCallback;
  final AnimatedListBaseReorderModel? reorderModel;
  final AnimatedListAnimator animator;
  final void Function(int, int)? didFinishLayoutCallback;

  @override
  State<AutomaticAnimatedSliverListView<T>> createState() =>
      _AutomaticAnimatedSliverListViewState<T>();
}

class _AutomaticAnimatedSliverListViewState<T>
    extends State<AutomaticAnimatedSliverListView<T>> {
  final controller = AnimatedListController();
  AnimatedListDiffListDispatcher<T>? _dispatcher;

  void _createDispatcher() {
    final oldProcessingList = _dispatcher?.discard();
    _dispatcher = AnimatedListDiffListDispatcher<T>(
      controller: controller,
      currentList: _dispatcher?.currentList ?? widget.list,
      itemBuilder: widget.itemBuilder,
      comparator: widget.comparator,
    );
    if (oldProcessingList != null) {
      _dispatcher!.dispatchNewList(
        oldProcessingList,
        detectMoves: widget.detectMoves,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _createDispatcher();
  }

  @override
  void didUpdateWidget(covariant AutomaticAnimatedSliverListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemBuilder != widget.itemBuilder ||
        oldWidget.comparator != widget.comparator) {
      _createDispatcher();
    }

    _dispatcher!.dispatchNewList(
      widget.list,
      detectMoves: widget.detectMoves,
    );
  }

  @override
  Widget build(BuildContext context) {
    final delegate = AnimatedSliverChildBuilderDelegate(
      (context, index, data) =>
          widget.itemBuilder(context, widget.list[index], data),
      widget.list.length,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addLongPressReorderable: widget.addLongPressReorderable,
      addAnimatedElevation: widget.addAnimatedElevation,
      addFadeTransition: widget.addFadeTransition,
      morphComparator: widget.morphComparator,
      morphResizeWidgets: widget.morphResizeWidgets,
      morphDuration: widget.morphDuration,
      holdScrollOffset: widget.holdScrollOffset,
      initialScrollOffsetCallback: widget.initialScrollOffsetCallback,
      reorderModel: widget.reorderModel,
      animator: widget.animator,
      didFinishLayoutCallback: widget.didFinishLayoutCallback,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
    );
    if (widget.itemExtent == null) {
      return AnimatedSliverList(
        delegate: delegate,
        controller: controller,
      );
    }

    return AnimatedSliverFixedExtentList(
      delegate: delegate,
      controller: controller,
      itemExtent: widget.itemExtent!,
    );
  }
}
