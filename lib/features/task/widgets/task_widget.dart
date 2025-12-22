import 'dart:math' as math;
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shimmer/shimmer.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:theme_switcher/theme_switcher.dart';
import 'package:todo/app.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/image/image_selector/utils/utils.dart';
import 'package:todo/features/task/task.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/functions.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({
    super.key,
    this.disabled = false,
    this.selected = false,
    this.onPressed,
    this.onLongPressed,
    this.isLoading = false,
    this.isDeleting = false,
    this.onEditPressed,
    this.task,
  });

  final bool disabled;
  final bool isLoading;
  final bool isDeleting;
  final TaskWrapper? task;
  final bool selected;
  final void Function()? onPressed;
  final void Function()? onLongPressed;
  final void Function()? onEditPressed;

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _getTopSection(context)),
        _getBottomSection(),
      ],
    );
    if (widget.task != null) return _buildWrapper(child);

    return _buildWrapper(
      Shimmer.fromColors(
        baseColor: ColorScheme.of(context).onSurfaceVariant,
        highlightColor: ColorScheme.of(context).surfaceContainer,
        child: child,
      ),
    );
  }

  Widget _buildWrapper(Widget child) {
    return IgnorePointer(
      ignoring: widget.disabled,
      child: SizedBox(
        height: 132,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.transparent,
            boxShadow: App.cardBoxShadow(context),
          ),
          child: Opacity(
            opacity: widget.disabled ? .3 : 1,
            child: TweenAnimationBuilder(
              duration: ThemeSwitcher.of(context).isAnimating
                  ? Duration.zero
                  : animationDuration,
              curve: Curves.easeInOutCirc,
              tween: ColorTween(
                end: widget.isDeleting
                    ? Color.lerp(
                        ColorScheme.of(context).error,
                        ColorScheme.of(context).surfaceContainer,
                        .7,
                      )
                    : widget.selected
                    ? Color.lerp(
                        ColorScheme.of(context).primary,
                        ColorScheme.of(context).primaryContainer,
                        .85,
                      )
                    : ColorScheme.of(context).surfaceContainer,
              ),
              builder: (context, value, child) => FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: value,
                  disabledBackgroundColor: value,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  animationDuration: animationDuration,
                  // overlayColor: Colors.red,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: widget.onPressed,
                onLongPress: widget.onLongPressed,
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBottomSection() {
    final children = [
      _getEditButton(),
      const SizedBox(width: 15),
      _getDuration(),
    ];
    return SizedBox(
      height: 32,
      child: RowSuper(
        children: context.isLtr ? children : children.reversed.toList(),
      ),
    );
  }

  Widget _getTopSection(BuildContext context) {
    final centerWidget = Expanded(
      child: Column(
        spacing: 2,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getTitle(context),
          _getDescription(),
        ],
      ),
    );

    List<Widget> children(BoxConstraints constraints) => [
      if (widget.task == null || widget.task!.image != null)
        _getImage(constraints),
      const SizedBox(width: 15),
      centerWidget,
      _getCheckBox(context),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: children(constraints),
        );
      },
    );
  }

  Widget _getDuration() {
    final formatter = (widget.task?.startingDate ?? Jalali.now()).formatter;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(9999)),
        color: ColorScheme.of(context).primary,
      ),
      child: Center(
        widthFactor: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: SvgPicture.asset(
                      'assets/icons/clock_icon.svg',
                    ),
                  ),
                ),
                TextSpan(
                  text:
                      '${formatter.d} ${formatter.mN} ساعت ${convertDigits('${formatter.tHH}:${formatter.tMM}')}',
                ),
              ],
              style: TextStyle(
                color: ColorScheme.of(context).onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.24,
              ),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _getEditButton() {
    return IgnorePointer(
      ignoring: widget.onEditPressed == null,
      child: FilledButton(
        onPressed: widget.onEditPressed ?? () {},
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          backgroundColor: ColorScheme.of(context).primaryContainer,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: SvgPicture.asset(
                    'assets/icons/edit_icon.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
              const TextSpan(text: 'ویرایش'),
            ],
            style: TextStyle(
              color: ColorScheme.of(context).onPrimaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.24,
            ),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getCheckBox(BuildContext context) {
    final shape = SquircleBorder(
      side: BorderSide(color: ColorScheme.of(context).outline, width: 2),
    );
    return Transform.translate(
      offset: Offset(
        context.isRtl ? -7 : 7,
        -7,
      ),
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: AsyncCheckbox(
          size: const Size.square(24),
          value: widget.task == null || widget.isLoading
              ? null
              : widget.task!.status,
          tristate: true,
          shape: shape,
          isLoading:
              widget.task == null || widget.isDeleting || widget.isLoading,
          padding: const EdgeInsets.all(7),
          splashColor: Theme.of(context).splashColor,
          checkedIconColor: ColorScheme.of(context).primary,
          unCheckedIconColor: Colors.transparent,
          loadingIconColor: widget.isDeleting
              ? ColorScheme.of(context).error
              : widget.task?.status ?? false
              ? ColorScheme.of(context).primary
              : ColorScheme.of(context).outline,
          loadingShape: shape.copyWith(
            side: shape.side.copyWith(
              color: widget.isDeleting
                  ? ColorScheme.of(context).error
                  : widget.task?.status ?? false
                  ? ColorScheme.of(context).primary
                  : ColorScheme.of(context).outline,
            ),
          ),
          unCheckedShape: shape.copyWith(
            side: shape.side.copyWith(color: ColorScheme.of(context).outline),
          ),
          onTap: (value) {
            if (value == null) return;
            widget.onPressed?.call();
          },
        ),
      ),
    );
  }

  Widget _getDescription() {
    if (widget.task == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              color: ColorScheme.of(context).surfaceContainer,
            ),
            child: const Text(
              'لورم ایپسام لورم ایپسام لورم ایپسام',
              maxLines: 2,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.24,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              color: ColorScheme.of(context).surface,
            ),
            child: const Text(
              'لورم ایپسام لورم ایپسام',
              maxLines: 2,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      );
    }
    return Text(
      widget.task!.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ColorScheme.of(context).onSurface,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.24,
      ),
    );
  }

  Widget _getTitle(BuildContext context) {
    if (widget.task == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(9999)),
          color: ColorScheme.of(context).surfaceContainer,
        ),
        child: const SizedBox(
          child: Text(
            'لورم ایپسام',
            style: TextStyle(
              fontSize: 14,
              overflow: TextOverflow.clip,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.24,
            ),
          ),
        ),
      );
    }
    return TextScroll(
      widget.task!.title,
      textDirection: Directionality.of(context),
      style: TextStyle(
        color: ColorScheme.of(context).onSurface,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.24,
      ),
      intervalSpaces: 30,
      velocity: const Velocity(
        pixelsPerSecond: Offset(50, 0),
      ),
      delayBefore: const Duration(
        milliseconds: 500,
      ),
      pauseBetween: const Duration(
        milliseconds: 500,
      ),
    );
  }

  Widget _getImage(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: math.min(116, constraints.maxWidth * .3),
      ),
      child: Center(
        widthFactor: 1,
        child: ClipRRect(
          borderRadius: const BorderRadiusGeometry.all(
            Radius.circular(10),
          ),
          child: widget.task == null
              ? SizedBox.expand(
                  child: SvgPicture.asset('assets/icons/image_icon.svg'),
                )
              : Image(
                  image: CustomImageProvider(
                    imageId: widget.task!.image,
                    repository: RepositoryProvider.of(context),
                  ),
                  errorBuilder: (context, error, stackTrace) => SizedBox.expand(
                    child: SvgPicture.asset(
                      'assets/icons/image_icon.svg',
                      colorFilter: const ColorFilter.mode(
                        CustomColors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

extension _ContextExtension on BuildContext {
  bool get isRtl => Directionality.maybeOf(this) == TextDirection.rtl;
  bool get isLtr => Directionality.maybeOf(this) == TextDirection.ltr;
}
