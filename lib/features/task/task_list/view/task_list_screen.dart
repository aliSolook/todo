import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo/app.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:todo/features/screen_manager/screen_manager.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/task/task.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/functions.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.index});

  final int index;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _indicatorKey = GlobalKey<RefreshIndicatorState>();

  TaskListBloc get _bloc => BlocProvider.of(context);

  @override
  void initState() {
    BlocProvider.of<ScreenManagerCubit>(
      context,
    ).initiateTab(widget.index, showFab: true, fabCallback: fabCallback);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _indicatorKey.currentState?.show();
    });

    super.initState();
  }

  void fabCallback() async {
    final result = await showTaskAdd(context);

    if (result != null && mounted) {
      _bloc.add(ListableItemAdded(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Stack(
      children: [
        RefreshIndicator(
          key: _indicatorKey,
          onRefresh: () {
            final bloc = _bloc;
            bloc.add(const ListableLoadRequested());

            return bloc.stream.firstWhere((state) {
              if (state.status == null) return false;

              return state.status!.isFailure || state.status!.isSuccess;
            });
          },
          child: CustomScrollView(
            clipBehavior: Clip.none,
            paintOrder: SliverPaintOrder.lastIsTop,
            slivers: [
              const SliverSafeArea(sliver: SliverToBoxAdapter()),
              _gap(20),
              _getHeader(),
              _gap(32),
              _getDays(),
              _gap(12),
              _getTaskCards(),
              _doneTasksSplitter(),
              _getTaskCards(true),
              _getTaskCardsIsEmpty(),
              _gap(80),
            ],
          ),
        ),
        _getSelectionActions(),
      ],
    );
  }

  Widget _gap(double gap) {
    return SliverPadding(padding: EdgeInsets.only(top: gap));
  }

  Widget _doneTasksSplitter() {
    return BlocBuilder<TaskListBloc, TaskListState>(
      buildWhen: (previous, current) =>
          (previous.checked.isEmpty || previous.unChecked.isEmpty) !=
              (current.checked.isEmpty || current.unChecked.isEmpty) ||
          current.manipulatedItems.isEmpty !=
              previous.manipulatedItems.isEmpty ||
          (current.status == null || current.status.isInProgress) !=
              (previous.status == null || previous.status.isInProgress),
      builder: (context, state) {
        final bool isVisible = state.status == null || state.status.isInProgress
            ? true
            : state.checked.isNotEmpty && state.unChecked.isNotEmpty;

        return SliverToBoxAdapter(
          child: AnimatedVisibility(
            isVisible: isVisible,
            child: Padding(
              padding: const EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 20,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).surfaceContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: App.cardBoxShadow(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 14),
                      Text(
                        'تسک های انجام شده',
                        style: TextStyle(
                          color: ColorScheme.of(context).onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: -0.24,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/drowp_down_icon.svg',
                        width: 14,
                        colorFilter: ColorFilter.mode(
                          ColorScheme.of(context).onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            Column(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<TaskListBloc, TaskListState>(
                  buildWhen: (previous, current) =>
                      previous.todayState != current.todayState,
                  builder: (context, state) {
                    final now =
                        state.todayState.either.orNull()?.key ?? Jalali.now();
                    return Text(
                      '${convertDigits(now.formatter.d)} ${now.formatter.mN}',
                      style: TextStyle(
                        height: 16 / 24,
                        color: ColorScheme.of(context).onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: -0.24,
                      ),
                    );
                  },
                ),
                BlocBuilder<TaskListBloc, TaskListState>(
                  buildWhen: (previous, current) =>
                      previous.todayState != current.todayState,
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      layoutBuilder: (currentChild, previousChildren) => Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      ),
                      duration: animationDuration,
                      child:
                          state.todayState.isInit ||
                              state.todayState.isInProgress
                          ? Shimmer.fromColors(
                              key: const ValueKey(true),
                              baseColor: ColorScheme.of(
                                context,
                              ).onSurfaceVariant,
                              highlightColor: ColorScheme.of(
                                context,
                              ).surfaceContainer,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: ColorScheme.of(context).surface,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(999),
                                  ),
                                ),
                                child: const Text(
                                  '0 تسک فعال',
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              state.todayState.value.value == 0
                                  ? 'تسک فعالی وجود ندارد'
                                  : '${convertDigits(state.todayState.value.value)} تسک فعال',
                              key: const ValueKey(false),
                              style: TextStyle(
                                color: ColorScheme.of(
                                  context,
                                ).onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: -0.24,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            BlocBuilder<TaskListBloc, TaskListState>(
              // buildWhen: (previous, current) =>
              //     previous.status != current.status ||
              //     previous.manipulatedItems.length !=
              //         current.manipulatedItems.length ||
              //     current.checked.length != previous.checked.length,
              buildWhen: (previous, current) =>
                  (previous.status == null || previous.status.isInProgress) !=
                      (current.status == null || current.status.isInProgress) ||
                  (previous.manipulatedItems.isEmpty
                          ? 0
                          : previous.checked.length /
                                previous.manipulatedItems.length) !=
                      (current.manipulatedItems.isEmpty
                          ? 0
                          : current.checked.length /
                                current.manipulatedItems.length),
              builder: (context, state) {
                // print(state.checked.length / state.manipulatedItems.length);
                // print(state.checked.length);
                // print(state.manipulatedItems.length);
                return TweenAnimationBuilder(
                  duration: animationDuration * 2,
                  tween: Tween<double?>(
                    begin: 0,
                    end: state.manipulatedItems.isEmpty
                        ? 0
                        : state.checked.length / state.manipulatedItems.length,
                  ),
                  builder: (context, value, child) {
                    final isInProgress =
                        state.status == null || state.status.isInProgress;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: animationDuration,
                          child: SizedBox.square(
                            key: ValueKey(isInProgress),
                            dimension: 56,
                            child: CircularProgressIndicator(
                              color: ColorScheme.of(context).primary,
                              backgroundColor: ColorScheme.of(
                                context,
                              ).primaryContainer,
                              strokeWidth: 6,
                              strokeAlign: -1,
                              value: isInProgress ? null : value,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                        TweenAnimationBuilder(
                          duration: animationDuration,
                          tween: Tween(end: isInProgress ? 0.0 : 1.0),
                          builder: (context, value, child) {
                            const begin = 0.0;
                            const end = .5;

                            final delayedValue = const Interval(
                              begin,
                              end,
                            ).transform(value);

                            final offset = 30 * (1 - delayedValue);
                            return Opacity(
                              opacity: value,
                              child: Transform(
                                alignment: Alignment.bottomCenter,
                                transform:
                                    Matrix4.translationValues(0, offset, 0)
                                      ..setEntry(0, 0, value)
                                      ..setEntry(1, 1, value)
                                      ..setEntry(2, 2, 1)
                                      ..setEntry(3, 3, 1),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            '${convertDigits((value! * 100).toStringAsFixed(0))}%',
                            style: TextStyle(
                              color: ColorScheme.of(context).onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -.24,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 24),
            SizedBox.square(
              dimension: 56,
              child: InkWell(
                customBorder: const SquircleBorder(),
                onTap: () async {
                  final result = await showPersianDateRangePicker(
                    context: context,
                    firstDate: Jalali.min,
                    lastDate: Jalali.max,
                    builder: (context, child) {
                      return Center(child: child);
                    },
                    initialDateRange: _bloc.state.dateRange.first,
                    initialDate: _bloc.state.dateRange.first.start,
                  );

                  if (result != null) {
                    _bloc.add(TaskListDateRangeChanged([result]));
                  }
                },
                child: Ink(
                  decoration: ShapeDecoration(
                    color: ColorScheme.of(context).primary,
                    shape: const SquircleBorder(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset('assets/icons/calendar_icon.svg'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDays() {
    return SliverToBoxAdapter(
      child: BlocBuilder<TaskListBloc, TaskListState>(
        buildWhen: (previous, current) =>
            previous.daysState != current.daysState ||
            previous.dateRange != current.dateRange,
        builder: (context, state) => AnimatedSwitcher(
          duration: animationDuration,
          child: () {
            if (state.daysState.isFailure) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: AnimatedContainer(
                    key: const ValueKey(false),
                    width: 71,
                    height: 87,
                    duration: animationDuration,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).error,
                      boxShadow: kElevationToShadow[12]
                          ?.map(
                            (e) => e.copyWith(
                              color: ColorScheme.of(context).error.withAlpha(
                                e.color.a * 255 ~/ 1,
                              ),
                            ),
                          )
                          .toList(),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: AnimatedDefaultTextStyle(
                      style: TextStyle(
                        color: ColorScheme.of(context).onError,
                        letterSpacing: -.24,
                        fontFamily: TextTheme.of(
                          context,
                        ).bodyMedium?.fontFamily,
                      ),
                      duration: animationDuration,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Center(
                          child: Text(state.daysState.error),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final List<Widget> children;

            if (state.daysState.isInProgress || state.daysState.isInit) {
              children = List.generate(
                7,
                (_) => Shimmer.fromColors(
                  baseColor: ColorScheme.of(context).onSurfaceVariant,
                  highlightColor: ColorScheme.of(context).surfaceContainer,
                  child: Container(
                    width: 71,
                    height: 87,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).surface,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ).toList();
            } else {
              children = state.daysState.value.entries.map(
                (e) {
                  final bool selected = state.dateRange.any(
                    (d) => d.inRange(e.key),
                  );
                  return TweenAnimationBuilder(
                    duration: animationDuration,
                    tween: Tween<double>(end: selected ? 1 : 0),
                    builder: (context, value, child) => Container(
                      width: 71,
                      height: 87,
                      decoration: BoxDecoration.lerp(
                        BoxDecoration(
                          color: ColorScheme.of(context).primaryContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        BoxDecoration(
                          color: ColorScheme.of(context).primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          boxShadow: kElevationToShadow[12]
                              ?.map(
                                (e) => e.copyWith(
                                  color: ColorScheme.of(context).primary
                                      .withAlpha(
                                        e.color.a * 255 ~/ 1,
                                      ),
                                ),
                              )
                              .toList(),
                        ),
                        value,
                      ),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          overlayColor: Color.lerp(
                            ColorScheme.of(context).onPrimary,
                            ColorScheme.of(context).primary,
                            value,
                          ),
                        ),
                        onPressed: () => _bloc.add(TaskListDateToggled(e.key)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                e.key.formatter.wN,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -.24,
                                  fontSize: 14,
                                  color: Color.lerp(
                                    ColorScheme.of(context).primary,
                                    ColorScheme.of(context).onPrimary,
                                    value,
                                  ),
                                ),
                              ),
                              Text(
                                convertDigits(e.key.day),
                                style: TextStyle(
                                  letterSpacing: -.24,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color.lerp(
                                    ColorScheme.of(context).primary,
                                    ColorScheme.of(context).onPrimary,
                                    value,
                                  ),
                                ),
                              ),
                              SizedBox.square(
                                dimension: 5,
                                child: TweenAnimationBuilder(
                                  duration: animationDuration,
                                  tween: Tween<double>(end: e.value ? 0 : 1),
                                  builder: (context, value2, child) =>
                                      DecoratedBox(
                                        decoration: ShapeDecoration(
                                          color: Color.lerp(
                                            Color.lerp(
                                              ColorScheme.of(context).primary,
                                              ColorScheme.of(context).onPrimary,
                                              value,
                                            ),
                                            Colors.transparent,
                                            value2,
                                          ),
                                          shape: const CircleBorder(),
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList();
            }

            return SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Row(
                  key: const ValueKey(null),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  spacing: 20,
                  children: children,
                ),
              ),
            );
          }(),
        ),
      ),
    );
  }

  Widget _getTaskCards([bool checked = false]) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: BlocBuilder<TaskListBloc, TaskListState>(
        buildWhen: (previous, current) {
          if (previous.status != current.status) return true;
          return checked
              ? previous.checked != current.checked
              : previous.unChecked != current.unChecked;
        },
        builder: (context, state) {
          final list = state.status.isInProgress || state.status == null
              ? List.filled(checked ? 2 : 4, null)
              : checked
              ? state.checked
              : state.unChecked;

          return AutomaticAnimatedSliverListView<TaskWrapper?>(
            list: list,
            itemExtent: 132 + 20,
            itemBuilder: (context, item, data) {
              if (item == null) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: TaskWidget(),
                );
              }

              return SelectableItem<TaskWrapper, TaskListBloc, TaskListState>(
                disableWhenDeleting: true,
                item: item,
                buildWhen: (previous, current) =>
                    previous.toggleState.contains(item.id) !=
                    current.toggleState.contains(item.id),
                onTap: () {
                  _bloc.add(TaskListTaskToggled(item));
                },
                onEditPressed: (item) async {
                  final result = await showTaskAdd(context, item);

                  if (result != null && context.mounted) {
                    _bloc.add(ListableEditingFinished(result));
                  }
                },
                builder:
                    (context, state, onPressed, onLongPressed, isDeleting) =>
                        TaskWidget(
                          selected: state.selectedItems.any(
                            (e) => e.id == item.id,
                          ),
                          isDeleting: isDeleting,
                          disabled: checked,
                          task: item,
                          isLoading: state.toggleState.contains(item.id),
                          onPressed: onPressed,
                          onLongPressed: onLongPressed,
                          onEditPressed: () async {
                            final result = await showTaskAdd(context, item);

                            if (result != null) {
                              _bloc.add(ListableEditingFinished(item));
                            }
                          },
                        ),
              );
            },
            comparator: AnimatedListDiffListComparator(
              sameItem: (a, b) => a?.id == b?.id,
              sameContent: (a, b) => a == b,
            ),
          );
        },
      ),
    );
  }

  Widget _getTaskCardsIsEmpty() {
    return SliverToBoxAdapter(
      child: BlocBuilder<TaskListBloc, TaskListState>(
        buildWhen: (previous, current) =>
            (current.status.isSuccess && current.manipulatedItems.isEmpty) !=
            (previous.status.isSuccess && previous.manipulatedItems.isEmpty),
        builder: (context, state) => AnimatedVisibility(
          isVisible: state.status.isSuccess && state.manipulatedItems.isEmpty,
          child: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('تسکی وجود ندارد'),
          ),
        ),
      ),
    );
  }

  Widget _getSelectionActions() {
    final safeAreaPadding = MediaQuery.paddingOf(context);
    final topPadding = safeAreaPadding.top;
    const iconPadding = EdgeInsets.all(8.0);
    const iconSize = 24.0;

    return SafeArea(
      right: true,
      top: true,
      left: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 10, top: 10),
        child: BlocBuilder<TaskListBloc, TaskListState>(
          buildWhen: (previous, current) =>
              previous.selectedItems != current.selectedItems ||
              previous.selectedItems.any(
                    (e) => previous.deleteState.isInProgress(e),
                  ) !=
                  current.selectedItems.any(
                    (e) => current.deleteState.isInProgress(e),
                  ),
          builder: (context, state) => TweenAnimationBuilder(
            builder: (_, value, child) {
              return Visibility(
                visible: value != 0,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    -(topPadding + 10 + iconPadding.top + iconSize) *
                        (1 - value),
                  ),
                  child: Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  ),
                ),
              );
            },
            duration: animationDuration,
            tween: Tween<double>(end: state.selectedItems.isEmpty ? 0 : 1),
            curve: Curves.easeInOutCirc,
            child: Material(
              elevation: 5,
              color: ColorScheme.of(context).surface,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: iconPadding.left,
                  top: 8,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        overlayColor: ColorScheme.of(context).onSurfaceVariant,
                      ),
                      padding: iconPadding,
                      onPressed: () {
                        _bloc.add(
                          const SelectableClearSelectionPressed(),
                        );
                      },
                      icon: Icon(
                        Icons.close,
                        color: ColorScheme.of(context).onSurfaceVariant,
                        size: iconSize,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        bool isLoading = state.selectedItems.any(
                          (e) => state.deleteState.isInProgress(e),
                        );

                        return IconButton(
                          style: IconButton.styleFrom(
                            minimumSize: Size.zero,
                            overlayColor: ColorScheme.of(context).error,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          padding: iconPadding,
                          onPressed: isLoading
                              ? null
                              : () {
                                  _bloc.add(
                                    const SelectableDeleteSelectedPressed(),
                                  );
                                },
                          icon: AnimatedSwitcher(
                            duration: animationDuration,
                            switchInCurve: Curves.easeInOutCirc,
                            switchOutCurve: Curves.easeInOutCirc,
                            child: isLoading
                                ? SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      color: ColorScheme.of(context).error,
                                      strokeCap: StrokeCap.round,
                                    ),
                                  )
                                : Icon(
                                    Icons.delete,
                                    key: UniqueKey(),
                                    color: ColorScheme.of(context).error,
                                    size: iconSize,
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${state.selectedItems.length} انتخاب شده',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorScheme.of(context).onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
