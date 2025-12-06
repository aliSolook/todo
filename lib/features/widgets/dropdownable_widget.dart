import 'package:flutter/material.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/widgets/dropdown_body.dart';

typedef WidgetBuilder = Widget Function(BuildContext context);

class DropDownableWidget extends StatefulWidget {
  const DropDownableWidget({
    super.key,
    required this.headerBuilder,
    required this.bodyBuilder,
    this.focusNode,
    this.suffix,
    this.label,
    this.errorText,
    this.targetAnchor,
    this.followerAnchor,
    this.dropDownPadding,
    this.expandHorizontally = true,
    this.decorate = true,
  });
  final WidgetBuilder headerBuilder;
  final WidgetBuilder bodyBuilder;
  final FocusNode? focusNode;
  final Widget? suffix;
  final String? errorText;
  final String? label;
  final AlignmentGeometry? targetAnchor;
  final AlignmentGeometry? followerAnchor;
  final EdgeInsetsGeometry? dropDownPadding;
  final bool decorate;
  final bool expandHorizontally;

  @override
  State<DropDownableWidget> createState() => _DropDownableWidgetState();
}

class _DropDownableWidgetState extends State<DropDownableWidget>
    with SingleTickerProviderStateMixin {
  late final focusNode = widget.focusNode ?? FocusNode();
  late final errorAnimationController = AnimationController(
    vsync: this,
    value: widget.errorText != null ? 1 : 0,
    duration: kThemeAnimationDuration,
  );
  late String errorText = widget.errorText ?? '';

  @override
  void didUpdateWidget(covariant DropDownableWidget oldWidget) {
    if (oldWidget.errorText == null && widget.errorText != null) {
      errorText = widget.errorText!;
      errorAnimationController.forward();
    } else if (oldWidget.errorText != null && widget.errorText == null) {
      errorAnimationController.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Focus(
        focusNode: focusNode,
        child: ListenableBuilder(
          listenable: focusNode,
          builder: (context, child) => AnimatedBuilder(
            animation: errorAnimationController,
            builder: (context, child) => DropdownBody(
              onTapOutside: (event) {
                focusNode.unfocus();
              },
              curve: Curves.easeInOutQuad,
              duration: animationDuration * 1.5,
              targetAnchor: widget.targetAnchor ?? Alignment.bottomCenter,
              followerAnchor: widget.followerAnchor ?? Alignment.topCenter,
              offset: const Offset(0, 10),
              headerBuilder: (context, _) => !widget.decorate
                  ? widget.headerBuilder(context)
                  : InputDecorator(
                      isFocused: focusNode.hasFocus,
                      isEmpty: false,
                      decoration: InputDecoration(
                        labelText: widget.label,
                        error: errorAnimationController.value == 0
                            ? null
                            : Align(
                                heightFactor: errorAnimationController.value,
                                widthFactor: 1,
                                child: Opacity(
                                  opacity: errorAnimationController.value,
                                  child: Text(
                                    errorText,
                                    style: Theme.of(
                                      context,
                                    ).inputDecorationTheme.errorStyle,
                                  ),
                                ),
                              ),
                        // errorStyle: ,
                        suffixIcon: widget.suffix == null
                            ? null
                            : Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 10,
                                ),
                                child: widget.suffix,
                              ),
                        // suffixIconConstraints: BoxConstraints.loose(
                        //   const Size(35, 25),
                        // ),
                      ),
                      child: widget.headerBuilder(context),
                    ),
              // headerBuilder: (context, _) => widget.headerBuilder(context),
              childBuilder: (context, animation) {
                return Padding(
                  padding:
                      widget.dropDownPadding ??
                      const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).surfaceContainer,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color:
                            Color.lerp(
                              ColorScheme.of(context).primary,
                              ColorScheme.of(context).error,
                              errorAnimationController.value,
                            ) ??
                            ColorScheme.of(context).primary,
                        width: 2,
                      ),
                      boxShadow: kElevationToShadow[10],
                    ),
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      fixedCrossAxisSizeFactor: 1,
                      child: widget.expandHorizontally
                          ? SizedBox(
                              width: double.infinity,
                              child: Center(
                                heightFactor: 1,
                                child: widget.bodyBuilder(context),
                              ),
                            )
                          : widget.bodyBuilder(context),
                    ),
                  ),
                );
              },
              isOpen: focusNode.hasFocus,
            ),
          ),
        ),
      ),
    );
  }
}
