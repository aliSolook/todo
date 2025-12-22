import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo/app.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/home/home.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:todo/features/screen_manager/screen_manager.dart';
import 'package:todo/features/task/task.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/disable_scroll_into_view_scroll_controller.dart';
import 'package:todo/utils/functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.index});

  final int index;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchBarFocusNode = FocusNode();
  final _searchController = TextEditingController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final _filterFocusNode = FocusNode();

  HomeBloc get _bloc => BlocProvider.of(context);

  @override
  void initState() {
    BlocProvider.of<ScreenManagerCubit>(
      context,
    ).initiateTab(widget.index, showFab: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _refreshIndicatorKey.currentState?.show();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              _bloc.add(const ListableLoadRequested());
              return _bloc.stream.firstWhere((e) => !e.status.isInProgress);
            },
            child: CustomScrollView(
              clipBehavior: Clip.none,
              restorationId: 'ali',
              slivers: [
                _gap(20),
                _getHeader(),
                _gap(max(0, 12 - MediaQuery.paddingOf(context).top)),
                _getSearchBar(),
                _getCategories(),
                _gap(32),
                _getSectionsTitle(
                  title: 'تسک های امروز',
                  key: const Key('home_screen_show_more_tasks_button'),
                  onTap: () {
                    BlocProvider.of<ScreenManagerCubit>(
                      context,
                    ).screenChanged(1);
                  },
                ),
                // _gap(20),
                // _getTimeLine(),
                // _gap(32),
                _getTaskCards(),
                _getIsEmpty(),
                _gap(80),
              ],
            ),
          ),

          _getSelectionActions(),
        ],
      ),
    );
  }

  Widget _gap(double gap) {
    return SliverPadding(padding: EdgeInsets.only(top: gap));
  }

  Widget _getTaskCards() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.manipulatedItems != current.manipulatedItems,
        builder: (context, state) =>
            AutomaticAnimatedSliverListView<TaskWrapper?>(
              list: state.status.isInProgress || state.status == null
                  ? List.filled(4, null)
                  : state.manipulatedItems,
              itemExtent: 132 + 20,
              itemBuilder: (context, item, data) {
                if (item == null) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: TaskWidget(isLoading: true),
                  );
                }

                return SelectableItem<TaskWrapper, HomeBloc, HomeState>(
                  disableWhenDeleting: true,
                  item: item,
                  buildWhen: (previous, current) =>
                      previous.toggleState.contains(item.id) !=
                      current.toggleState.contains(item.id),
                  onTap: () => _bloc.add(HomeTaskToggled(item)),
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
            ),
      ),
    );
  }

  Widget _getTimeLine() {
    return SliverToBoxAdapter(
      // child: SingleStateWidget<RangeValues>(
      //   initState: const RangeValues(0, 1),
      //   builder: (context, state, child) => RangeSlider(
      //     divisions: 24 * 2,
      //     labels: RangeLabels(
      //       durationFormatter(
      //         const Duration(hours: 24) * state.value.start,
      //         seconds: false,
      //       ),
      //       durationFormatter(
      //         const Duration(hours: 24) * state.value.end,
      //         seconds: false,
      //       ),
      //     ),
      //     values: state.value,
      //     onChanged: (value) {
      //       print(value);
      //       state.setState(() => state.value = value);
      //     },
      //   ),
      // ),
      // child: SingleStateWidget<RangeValues>(
      //   initState: const RangeValues(0, 1),
      //   builder: (context, state, child) => const Text('data'),
      // ),
      child: LayoutBuilder(
        builder: (context, constraint) => SingleChildScrollView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: constraint.copyWith(
              maxHeight: double.infinity,
              maxWidth: double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: TimeLine(
                selectedIndex: 3,
                // onChanged: (index) => setState(() => this.index = index),
                children: [
                  'همه',
                  '۸:۳۰ - ۱۰',
                  '۱۰ - ۱۲',
                  '۱۲ - ۱۳:۳۰',
                  '۱۴ - ۱۶:۲۰',
                  '۸ - ۱۹:۳۰',
                ].map(Text.new).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCategories() {
    return SliverToBoxAdapter(
      child: ListenableBuilder(
        listenable: _searchBarFocusNode,
        builder: (context, child) => TweenAnimationBuilder(
          duration: animationDuration * 3,
          curve: Curves.easeInOutCirc,
          tween: Tween<double>(end: _searchBarFocusNode.hasFocus ? 0 : 1),
          builder: (context, value, child) => ClipPath(
            clipper: _ClipWithGap(gap: EdgeInsets.only(bottom: 70 * value)),
            child: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1,
              heightFactor: value,
              child: child,
            ),
          ),
          child: child,
        ),
        child: Column(
          children: [
            const SizedBox(height: 42),
            _getSectionsTitle(title: 'دسته بندی', isSliver: false),
            const SizedBox(height: 20),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (!state.categoriesState.isFailure) {
                  final List<CategoryWrapper?> categories =
                      state.categoriesState.either.orNull() ??
                      List.filled(4, null);

                  return SingleChildScrollView(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding / 2,
                      ),
                      child: AnimatedSwitcher(
                        duration: animationDuration,
                        child: Row(
                          key: ValueKey(state.categoriesState.either.isRight),
                          children: categories
                              .map(
                                (category) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: horizontalPadding / 2,
                                  ),
                                  child: CategoryWidget(
                                    // opacityMultiplier: 5,
                                    category: category?.toCategory(),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  );
                }

                return Text(
                  state.categoriesState.error,
                  style: TextStyle(
                    color: ColorScheme.of(context).error,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSearchBar() {
    final prefix = Padding(
      padding: const EdgeInsetsDirectional.only(start: 10),
      child: ListenableBuilder(
        listenable: _searchBarFocusNode,
        builder: (_, child) => AnimatedSwitcher(
          duration: animationDuration,
          child: !_searchBarFocusNode.hasFocus
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/search_icon.svg',
                    key: const ValueKey(true),
                    width: 25,
                    colorFilter: ColorFilter.mode(
                      ColorScheme.of(context).onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : AspectRatio(
                  aspectRatio: 1,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(5),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchBarFocusNode.unfocus();
                      _bloc.add(const SearchableSearchTextChanged('', false));
                    },
                    onLongPress: () {},
                    icon: SizedBox.expand(
                      child: FittedBox(
                        child: Icon(
                          Icons.close_rounded,
                          color: ColorScheme.of(context).onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );

    final sufix = BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.searchFields != current.searchFields,
      builder: (context, state) => DropDownableWidget(
        dropDownPadding: EdgeInsets.zero,
        decorate: false,
        expandHorizontally: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        focusNode: _filterFocusNode,
        bodyBuilder: (context) => IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _bloc.add(
                        SearchableSearchFieldsChanged(
                          added: TaskSearchField.values.toSet(),
                        ),
                      );
                    },
                    icon: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.checklist_rtl_rounded
                          : Icons.checklist_rounded,
                      color: ColorScheme.of(context).onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              ...TaskSearchField.values.map(
                (e) => ListTile(
                  title: Text(e.toString().split('.').last),
                  selected: true,
                  selectedColor: ColorScheme.of(context).primary,
                  leading: CustomCheckbox(
                    splashColor: ColorScheme.of(context).primary,
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    size: 24,
                    value: state.searchFields.contains(e),
                    padding: const EdgeInsets.all(7),
                    borderColor: state.searchFields.contains(e)
                        ? ColorScheme.of(context).primary
                        : ColorScheme.of(context).onSurfaceVariant,
                    foregroundColor: ColorScheme.of(context).primary,
                    backgroundColor: Colors.transparent,
                    splashBorderRadius: const BorderRadius.all(
                      Radius.circular(16),
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(9),
                    ),
                    onChanged: (value) {
                      _bloc.add(
                        SearchableSearchFieldToggled(e),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        headerBuilder: (context) => IconButton(
          onHover: (value) {},
          onPressed: () {
            _filterFocusNode.hasFocus
                ? _filterFocusNode.unfocus()
                : _filterFocusNode.requestFocus();
          },
          onLongPress: () {},
          icon: AnimatedSwitcher(
            switchInCurve: Curves.easeInCirc,
            switchOutCurve: Curves.easeOutCirc,
            duration: animationDuration,
            child: _filterFocusNode.hasFocus
                ? Icon(
                    key: const ValueKey(true),
                    Icons.close_rounded,
                    size: 25,
                    color: ColorScheme.of(context).onSurfaceVariant,
                  )
                : SvgPicture.asset(
                    key: const ValueKey(false),
                    'assets/icons/filter_icon.svg',
                    width: 25,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      ColorScheme.of(context).onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
      ),
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: MySliverFloatingHeader(
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
          ),
          shadows: App.cardBoxShadow(context),
        ),
        floatingDecoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
          ),
          shadows: kElevationToShadow[8]
              ?.map(
                (e) => e.copyWith(
                  color: ColorScheme.of(
                    context,
                  ).shadow.withAlpha(e.color.a * 255 ~/ 1),
                ),
              )
              .toList(),
        ),
        topPadding: 10,
        height: 41,
        child: Stack(
          children: [
            TextField(
              key: const Key('home_screen_search_field'),
              focusNode: _searchBarFocusNode,
              controller: _searchController,
              onTapOutside: (event) {
                _searchBarFocusNode.unfocus();
              },
              onChanged: (value) =>
                  _bloc.add(SearchableSearchTextChanged(value)),
              scrollController: DisableScrollIntoViewScrollController(),
              decoration: InputDecoration(
                constraints: const BoxConstraints(maxHeight: 41),
                labelText: 'جستحوی تسکات ...',
                prefixIcon: prefix,
                suffixIcon: const SizedBox(width: 25 + 8), // just a placeholder
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: -0.24,
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: sufix,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getHeader() {
    return SliverSafeArea(
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: Colors.red,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(28),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'سلام، ',
                            style: TextStyle(
                              color: ColorScheme.of(context).onSurface,
                              letterSpacing: -0.24,
                            ),
                          ),
                          TextSpan(
                            text: 'محمد جواد‌👋',
                            style: TextStyle(
                              color: ColorScheme.of(context).primary,
                              letterSpacing: -0.24,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.24,
                      ),
                    ),
                    BlocBuilder<HomeBloc, HomeState>(
                      buildWhen: (previous, current) =>
                          previous.today.withoutTime !=
                          current.today.withoutTime,
                      builder: (context, state) => Text(
                        '${state.today.formatter.d} ${state.today.formatter.mN}',
                        style: TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          color: ColorScheme.of(context).onSurfaceVariant,
                          fontWeight: FontWeight.normal,
                          letterSpacing: -0.24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    previous.sourceItems.length != current.sourceItems.length ||
                    previous.status != current.status,
                builder: (context, state) {
                  Widget child = DecoratedBox(
                    key: const Key('not shimmer'),
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).primaryContainer,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(99999),
                      ),
                    ),
                    child: Padding(
                      key: ValueKey(state.status.isInProgress),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        state.sourceItems.isEmpty && state.status.isSuccess
                            ? 'تسک فعالی وجود ندارد'
                            : '${convertDigits(state.sourceItems.length)} تسک فعال',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorScheme.of(context).primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.24,
                        ),
                      ),
                    ),
                  );

                  if (state.status.isInProgress || state.status == null) {
                    child = Shimmer.fromColors(
                      key: const Key('shimmer'),
                      baseColor: ColorScheme.of(context).onSurfaceVariant,
                      highlightColor: ColorScheme.of(context).surfaceContainer,
                      child: child,
                    );
                  }
                  return AnimatedSize(
                    duration: animationDuration,
                    child: AnimatedSwitcher(
                      duration: animationDuration,
                      child: child,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSectionsTitle({
    required String title,
    void Function()? onTap,
    Key? key,
    bool isSliver = true,
  }) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorScheme.of(context).onSurface,
              letterSpacing: -0.24,
            ),
          ),
          const Spacer(),
          TextButton(
            key: key,
            onPressed: onTap,
            child: Text(
              'مشاهده بیشتر',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: onTap == null
                    ? ColorScheme.of(context).onSurfaceVariant
                    : ColorScheme.of(context).primary,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );

    if (!isSliver) return child;
    return SliverToBoxAdapter(child: child);
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
        child: BlocBuilder<HomeBloc, HomeState>(
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
                          const HomeSelectedToggled(),
                        );
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/check_all_icon.svg',
                        width: 25,
                        colorFilter: ColorFilter.mode(
                          ColorScheme.of(context).onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),

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
                                    key: const ValueKey(true),
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      color: ColorScheme.of(context).error,
                                      strokeCap: StrokeCap.round,
                                    ),
                                  )
                                : Icon(
                                    Icons.delete,
                                    key: const ValueKey(false),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _getIsEmpty() {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeBloc, HomeState>(
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
}

class _ClipWithGap extends CustomClipper<Path> {
  final EdgeInsets gap;
  final BorderRadius borderRadius;

  // ignore: unused_element_parameter
  _ClipWithGap({required this.gap, this.borderRadius = BorderRadius.zero});

  @override
  Path getClip(Size size) {
    final rect = Rect.fromLTWH(
      -gap.left,
      -gap.top,
      gap.horizontal + size.width,
      gap.vertical + size.height,
    );
    return Path()..addRRect(
      RRect.fromRectAndCorners(
        rect,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
      ),
    );
  }

  @override
  bool shouldReclip(covariant _ClipWithGap oldClipper) => gap != oldClipper.gap;
}
