import 'dart:math';
import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/listable/listable.dart';

typedef ItemBuilder<T> =
    Widget Function(BuildContext context, T item, bool? isAscending);

class OrderSelector<T extends Object> extends StatefulWidget {
  OrderSelector.wrap({
    super.key,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
    required this.items,
    List<OrderItem<T>>? selectedItems,
    this.updateData = false,
    required this.itemBuilder,
    this.onChanged,
    this.defaultAnimationDuration = animationDuration,
    this.chipTransformDuration,
    this.orderIconDuration,
    this.repositionDuration,
    this.shadowChangedDuration,
    this.shadow,
  }) : selectedItems = selectedItems ?? [],
       _flexStyle = null,
       _wrapStyle = WrapStyle(
         direction: direction,
         alignment: alignment,
         spacing: spacing,
         runAlignment: runAlignment,
         runSpacing: runSpacing,
         crossAxisAlignment: crossAxisAlignment,
         textDirection: textDirection,
         verticalDirection: verticalDirection,
         clipBehavior: clipBehavior,
       );

  OrderSelector.flex({
    super.key,
    Axis direction = Axis.horizontal,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Clip clipBehavior = Clip.none,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    TextDirection? textDirection,
    double spacing = 0,
    required this.items,
    List<OrderItem<T>>? selectedItems,
    this.updateData = false,
    required this.itemBuilder,
    this.onChanged,
    this.defaultAnimationDuration = animationDuration,
    this.chipTransformDuration,
    this.orderIconDuration,
    this.repositionDuration,
    this.shadowChangedDuration,
    this.shadow,
  }) : selectedItems = selectedItems ?? [],
       _wrapStyle = null,
       _flexStyle = FlexStyle(
         textBaseline: textBaseline,
         textDirection: textDirection,
         direction: direction,
         crossAxisAlignment: crossAxisAlignment,
         clipBehavior: clipBehavior,
         mainAxisAlignment: mainAxisAlignment,
         mainAxisSize: mainAxisSize,
         spacing: spacing,
         verticalDirection: verticalDirection,
       );
  // assert(onChanged != null || updateData),

  final WrapStyle? _wrapStyle;
  final FlexStyle? _flexStyle;
  final List<T> items;
  final List<OrderItem<T>> selectedItems;
  final ItemBuilder<T> itemBuilder;
  final void Function(List<OrderItem<T>> selectedItems)? onChanged;
  final Duration defaultAnimationDuration;
  final Duration? chipTransformDuration;
  final Duration? orderIconDuration;
  final Duration? repositionDuration;
  final Duration? shadowChangedDuration;
  final bool updateData;
  final List<BoxShadow>? shadow;

  @override
  State<OrderSelector<T>> createState() => _OrderSelectorState<T>();
}

class _OrderSelectorState<T extends Object> extends State<OrderSelector<T>> {
  @override
  Widget build(BuildContext context) {
    if (widget._wrapStyle != null) {
      return Wrap(
        direction: widget._wrapStyle!.direction,
        crossAxisAlignment: widget._wrapStyle!.crossAxisAlignment,
        runAlignment: widget._wrapStyle!.runAlignment,
        clipBehavior: widget._wrapStyle!.clipBehavior,
        spacing: widget._wrapStyle!.spacing,
        verticalDirection: widget._wrapStyle!.verticalDirection,
        alignment: widget._wrapStyle!.alignment,
        runSpacing: widget._wrapStyle!.runSpacing,
        textDirection: widget._wrapStyle!.textDirection,
        children: [
          ...widget.selectedItems.map((e) => _itemBuilder(e.value, e.isAsc)),
          ..._filterItems.map((e) => _itemBuilder(e, null)),
        ],
      );
    }
    return Flex(
      direction: widget._flexStyle!.direction,
      crossAxisAlignment: widget._flexStyle!.crossAxisAlignment,
      clipBehavior: widget._flexStyle!.clipBehavior,
      mainAxisAlignment: widget._flexStyle!.mainAxisAlignment,
      mainAxisSize: widget._flexStyle!.mainAxisSize,
      spacing: widget._flexStyle!.spacing,
      verticalDirection: widget._flexStyle!.verticalDirection,
      textBaseline: widget._flexStyle!.textBaseline,
      textDirection: widget._flexStyle!.textDirection,
      children: [
        ...widget.selectedItems.map((e) => _itemBuilder(e.value, e.isAsc)),
        ..._filterItems.map((e) => _itemBuilder(e, null)),
      ],
    );
  }

  Iterable<T> get _filterItems => widget.items.where(
    (value) => !widget.selectedItems.any((e) => e.value == value),
  );

  Widget _itemBuilder(T item, bool? isAscending) {
    final shape =
        ChipTheme.of(context).shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        );
    return AnimatedTo.curve(
      globalKey: GlobalObjectKey(item),
      curve: Curves.elasticOut,
      duration:
          widget.repositionDuration ?? (widget.defaultAnimationDuration * 4),
      child: TweenAnimationBuilder(
        builder: (context, decoration, child) => DecoratedBox(
          decoration: decoration,
          child: child,
        ),
        duration:
            widget.shadowChangedDuration ?? widget.defaultAnimationDuration,
        tween: DecorationTween(
          end: ShapeDecoration(
            shape: shape,
            shadows: widget.shadow,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: shape,
            // chipAnimationStyle: ChipAnimationStyle(
            //   selectAnimation: AnimationStyle(
            //     duration:
            //         widget.chipTransformDuration ??
            //         (widget.defaultAnimationDuration * 4),
            //     curve: Curves.easeInOutCirc,
            //   ),
            // ),
            // selected: isAscending != null,
            // selectedColor: CustomColors.lightGreen,
            // side: const WidgetStateBorderSide.fromMap({
            //   WidgetState.selected: BorderSide(color: CustomColors.green),
            //   WidgetState.any: null,
            // }),
            onTap: () {
              final selectedItems = widget.updateData
                  ? widget.selectedItems
                  : List.of(widget.selectedItems);

              if (isAscending == null) {
                selectedItems.add(OrderItem.asc(item));
              } else if (!isAscending) {
                selectedItems.remove(OrderItem.desc(item));
              } else {
                final index = selectedItems.indexOf(OrderItem.asc(item));
                selectedItems[index] = OrderItem.desc(item);
              }

              if (widget.onChanged == null && widget.updateData) {
                return setState(() {});
              }
              widget.onChanged?.call(selectedItems);
            },
            child: TweenAnimationBuilder(
              builder: (context, value, child) => Ink(
                decoration: ShapeDecoration(
                  color: Color.lerp(
                    ColorScheme.of(context).primary,
                    ColorScheme.of(context).primaryContainer,
                    value,
                  ),
                  shape: shape,
                ),
                child: child,
              ),
              duration:
                  widget.chipTransformDuration ??
                  widget.defaultAnimationDuration,
              tween: Tween<double>(
                end: isAscending == null ? 1 : 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder(
                    builder: (context, value, child) => Visibility(
                      visible: value != 0,
                      child: ClipRect(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          heightFactor: 1,
                          widthFactor: value,
                          child: child,
                        ),
                      ),
                    ),
                    duration:
                        widget.chipTransformDuration ??
                        (widget.defaultAnimationDuration * .5),
                    curve: Curves.easeInOutCirc,
                    tween: Tween<double>(end: isAscending != null ? 1 : 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TweenAnimationBuilder(
                        duration:
                            widget.orderIconDuration ??
                            widget.defaultAnimationDuration,
                        curve: Curves.easeInOutCirc,
                        tween: Tween<double>(
                          end: isAscending ?? false ? 1 : 0,
                        ),
                        builder: (context, value, child) {
                          return Transform(
                            transform: Matrix4.rotationX(
                              pi * value,
                            ),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                        child: TweenAnimationBuilder(
                          duration:
                              widget.chipTransformDuration ??
                              widget.defaultAnimationDuration,
                          tween: Tween<double>(
                            end: isAscending == null ? 1 : 0,
                          ),
                          builder: (context, value, child) => SvgPicture.asset(
                            'assets/icons/sort_asc_icon.svg',
                            colorFilter: ColorFilter.mode(
                              Color.lerp(
                                ColorScheme.of(context).onPrimary,
                                ColorScheme.of(context).primary,
                                value,
                              )!,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TweenAnimationBuilder(
                      duration:
                          widget.chipTransformDuration ??
                          widget.defaultAnimationDuration,
                      tween: Tween<double>(end: isAscending == null ? 1 : 0),
                      builder: (context, value, child) => DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: TextTheme.of(
                            context,
                          ).labelMedium?.fontFamily,
                          color: Color.lerp(
                            ColorScheme.of(context).onPrimary,
                            ColorScheme.of(context).primary,
                            value,
                          ),
                        ),
                        child: child!,
                      ),
                      child: widget.itemBuilder(context, item, isAscending),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlexStyle {
  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;
  final Clip clipBehavior;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final VerticalDirection verticalDirection;
  final TextDirection? textDirection;
  final TextBaseline? textBaseline;

  FlexStyle({
    required this.direction,
    required this.crossAxisAlignment,
    required this.clipBehavior,
    required this.mainAxisAlignment,
    required this.mainAxisSize,
    required this.spacing,
    required this.verticalDirection,
    required this.textDirection,
    required this.textBaseline,
  });
}

class WrapStyle {
  final Axis direction;
  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final Clip clipBehavior;

  WrapStyle({
    required this.direction,
    required this.alignment,
    required this.spacing,
    required this.runAlignment,
    required this.runSpacing,
    required this.crossAxisAlignment,
    required this.textDirection,
    required this.verticalDirection,
    required this.clipBehavior,
  });
}
