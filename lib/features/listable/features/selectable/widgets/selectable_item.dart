import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/features/listable/listable.dart';

typedef SelectableWidgetBuilder<T, S extends SelectableState<T>> =
    Widget Function(
      BuildContext context,
      S state,
      VoidCallback? onPressed,
      VoidCallback? onLongPressed,
      bool isDeleting,
    );

class SelectableItem<
  T,
  B extends SelectableBloc<T, S>,
  S extends SelectableState<T>
>
    extends StatelessWidget {
  const SelectableItem({
    super.key,
    required this.item,
    required this.builder,
    this.onEditPressed,
    this.deletable = true,
    this.topPadding = 20,
    this.buildWhen,
    this.overrideDefaultBuildWhen = false,
    this.onTap,
    this.disableWhenDeleting = false,
  }) : assert(!overrideDefaultBuildWhen || buildWhen != null);

  final T item;
  final SelectableWidgetBuilder<T, S> builder;
  final void Function(T item)? onEditPressed;
  final bool deletable;
  final double topPadding;
  final BuildWhenCallBack<T, B, S>? buildWhen;
  final bool overrideDefaultBuildWhen;
  final VoidCallback? onTap;
  final bool disableWhenDeleting;

  @override
  Widget build(BuildContext context) {
    return ListItem<T, B, S>(
      item: item,
      buildWhen: overrideDefaultBuildWhen ? buildWhen : _buildWhen,
      deletable: deletable,
      onEditPressed: onEditPressed,
      overrideDefaultBuildWhen: overrideDefaultBuildWhen,
      topPadding: topPadding,
      builder: (context, state, isDeleting) {
        final bloc = BlocProvider.of<B>(context);
        final onTap = disableWhenDeleting && isDeleting ? null : this.onTap;

        final onLongPressed = isDeleting
            ? null
            : state.selectedItems.isNotEmpty
            ? onTap
            : () {
                bloc.add(SelectableItemToggled(item));
                Slidable.of(context)?.close();
              };

        final onPressed = state.selectedItems.isNotEmpty && !isDeleting
            ? () {
                bloc.add(SelectableItemToggled(item));
                Slidable.of(context)?.close();
                return;
              }
            : onTap;

        return builder(context, state, onPressed, onLongPressed, isDeleting);
      },
    );
  }

  bool _buildWhen(S previous, S current) {
    if (previous == current) return false;

    // selectionChanged
    if (previous.selectedItems.contains(item) !=
        current.selectedItems.contains(item)) {
      return true;
    }

    // selecting
    if (previous.selectedItems.isEmpty != current.selectedItems.isEmpty) {
      return true;
    }

    return buildWhen?.call(previous, current) ?? false;
  }
}
