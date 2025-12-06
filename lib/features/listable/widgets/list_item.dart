import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/listable/listable.dart';

typedef BuildWhenCallBack<
  T,
  B extends ListableBloc<T, S>,
  S extends ListableState<T>
> = bool Function(S previous, S current);

class ListItem<T, B extends ListableBloc<T, S>, S extends ListableState<T>>
    extends StatelessWidget {
  const ListItem({
    super.key,
    required this.item,
    required this.builder,
    this.onEditPressed,
    this.deletable = true,
    this.topPadding = 20,
    this.buildWhen,
    this.overrideDefaultBuildWhen = false,
  }) : assert(!overrideDefaultBuildWhen || buildWhen != null);

  final T item;
  final Widget Function(BuildContext context, S state, bool isDeleting) builder;
  final void Function(T item)? onEditPressed;
  final bool deletable;
  final double topPadding;
  final BuildWhenCallBack<T, B, S>? buildWhen;
  final bool overrideDefaultBuildWhen;

  @override
  Widget build(BuildContext context) {
    final spacing = EdgeInsets.only(top: topPadding);
    return LayoutBuilder(
      builder: (_, constraint) {
        return BlocBuilder<B, S>(
          buildWhen: overrideDefaultBuildWhen ? buildWhen! : _buildWhen,
          builder: (context, state) {
            final maxActionsWidth = _calcMaxWidth();
            final deleting = state.deleteState.isInProgress(item);
            // final deleting =
            //     state.deleteState.isInProgress(item) ||
            //     !state.sourceItems.any(
            //       (e) => BlocProvider.of<B>(context).sameItem(e, item),
            //     ); // it means it is in delete aimation

            Widget child = Padding(
              padding: spacing,
              child: builder(context, state, deleting),
            );

            if (maxActionsWidth > 0) {
              child = Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: maxActionsWidth / constraint.maxWidth,
                  children: [
                    if (onEditPressed != null) ...[
                      const Spacer(),
                      _editButton(spacing, deleting),
                    ],
                    if (deletable) ...[
                      const Spacer(),
                      _deleteButton(spacing, deleting, context),
                    ],
                  ],
                ),
                child: child,
              );
            }

            return child;
          },
        );
      },
    );
  }

  Widget _deleteButton(
    EdgeInsets spacing,
    bool deleting,
    BuildContext context,
  ) {
    return Padding(
      padding: spacing,
      child: SizedBox.square(
        dimension: 76,
        child: OutlinedButton(
          onPressed: deleting
              ? null
              : () {
                  BlocProvider.of<B>(
                    context,
                  ).add(ListableDeletePressed(item));
                },
          style: OutlinedButton.styleFrom(
            backgroundColor: CustomColors.red,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            side: BorderSide.none,
          ),
          child: AnimatedSwitcher(
            duration: animationDuration,
            child: deleting
                ? AspectRatio(
                    aspectRatio: 1,
                    child: CircularProgressIndicator(
                      strokeCap: StrokeCap.round,
                      color: Colors.white,
                      key: UniqueKey(),
                    ),
                  )
                : SvgPicture.asset(
                    'assets/icons/delete_icon.svg',
                    key: UniqueKey(),
                    width: 25,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _editButton(EdgeInsets spacing, bool deleting) {
    return Padding(
      padding: spacing,
      child: SizedBox.square(
        dimension: 76,
        child: Builder(
          builder: (context) {
            return OutlinedButton(
              onPressed: deleting
                  ? null
                  : () async {
                      await Slidable.of(
                        context,
                      )?.close(curve: Curves.easeInOutCirc);
                      if (!context.mounted) return;

                      onEditPressed!(item);
                    },
              style: OutlinedButton.styleFrom(
                backgroundColor: CustomColors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                side: BorderSide.none,
              ),
              child: SvgPicture.asset(
                'assets/icons/edit_filled_icon.svg',
                width: 25,
              ),
            );
          },
        ),
      ),
    );
  }

  bool _buildWhen(S previous, S current) {
    if (previous == current) return false;

    // deleteInProgress
    if (previous.deleteState.isInProgress(item) !=
        current.deleteState.isInProgress(item)) {
      return true;
    }

    return buildWhen?.call(previous, current) ?? false;
  }

  double _calcMaxWidth() {
    var count = 2.0;
    if (onEditPressed == null) count--;
    if (!deletable) count--;
    return 76 * count + 20 * count;
  }
}
