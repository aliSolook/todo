import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:todo/app.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/image/image.dart' hide Image;
import 'package:todo/features/listable/listable.dart';
import 'package:todo/features/screen_manager/screen_manager.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/disable_scroll_into_view_scroll_controller.dart';
import 'package:todo/utils/functions.dart';

const _myCurve = Curves.easeInOutCirc;

class CounterListScreen extends StatefulWidget {
  const CounterListScreen({super.key, this.index});

  final int? index;

  @override
  State<CounterListScreen> createState() => _CounterListScreenState();
}

class _CounterListScreenState extends State<CounterListScreen> {
  final _indicatorKey = GlobalKey<RefreshIndicatorState>();
  final _searchController = TextEditingController();
  final _searchBarFocusNode = FocusNode();
  final _filterFocusNode = FocusNode();
  final _scrollController = ScrollController();

  CounterListBloc get _bloc => BlocProvider.of<CounterListBloc>(context);

  @override
  void initState() {
    _searchBarFocusNode.addListener(() {
      if (_searchBarFocusNode.hasFocus) {
        _scrollController.animateTo(
          0,
          duration: animationDuration,
          curve: Curves.easeInOutCirc,
        );
      }
    });
    if (widget.index != null) {
      BlocProvider.of<ScreenManagerCubit>(
        context,
      ).initiateTab(widget.index!, showFab: true, fabCallback: fabCallback);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _indicatorKey.currentState?.show();
    });

    super.initState();
  }

  void fabCallback() async {
    final result = await showCounterAdd(context);

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
    return BlocListener<CounterListBloc, CounterListState>(
      listener: (context, state) {
        //TODO: implement this
        // if (state.deleteState.getMessageOrNull(element) != null &&
        //     state.deleteState!.status.isFailure) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(state.deleteState!.message!),
        //     ),
        //   );
        // }
      },
      child: Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: RefreshIndicator(
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
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                  ),
                  _gap(10),
                  _getSearchBar(),
                  _getCountDownWidget(32),
                  _getSplitter(),
                  _gap(10),
                  _getOrderItems(),
                  _gap(10),
                  _getCounters(),
                  _getCounterIsEmpty(),
                  _gap(80),
                ],
              ),
            ),
          ),
          _getSelectionActions(),
        ],
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
                  key: const ValueKey(false),
                  aspectRatio: 1,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(5.0),
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

    final sufix = BlocBuilder<CounterListBloc, CounterListState>(
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
                          added: CounterSearchField.values.toSet(),
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
              ...CounterSearchField.values.map(
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
          shadows: kElevationToShadow[8],
        ),
        topPadding: 10,
        height: 41,
        child: Stack(
          children: [
            TextField(
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
                labelText: 'جستحوی شمارنده ...',
                prefixIcon: prefix,
                suffixIcon: const SizedBox(width: 25 + 8),
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

  Widget _getOrderItems() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        // sliver: MySliverFloatingHeader.builder(
        //   topPadding: 10,
        //   floating: false,
        //   builder: (context, shrinkoffset, overlapsContent) =>
        child: BlocBuilder<CounterListBloc, CounterListState>(
          buildWhen: (previous, current) => previous.order != current.order,
          builder: (context, state) => SingleChildScrollView(
            child: OrderSelector.wrap(
              items: CounterOrder.values,
              selectedItems: state.order,
              itemBuilder: (_, item, _) => Text(item.text),
              spacing: 5,
              runSpacing: 5,
              // shadowChangedDuration: ,
              // shadow: [
              //   BoxShadow(
              //     offset: Offset(0, overlapsContent ? 10 : 0),
              //     color: const Color.fromARGB(50, 0, 0, 0),
              //     blurRadius: overlapsContent ? 20 : 0,
              //     spreadRadius: overlapsContent ? 2 : 0,
              //   ),
              // ],
              // alignment: overlapsContent
              //     ? WrapAlignment.center
              //     : WrapAlignment.start,
              updateData: false,
              onChanged: (selectedItems) {
                _bloc.add(SortableOrderChanged(selectedItems));
              },
            ),
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
        child: BlocBuilder<CounterListBloc, CounterListState>(
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
            curve: _myCurve,
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
                        bool isLoading = state.deleteState.any(
                          (a) => state.selectedItems.any(
                            (b) => a.item.id == b.id,
                          ),
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
                            switchInCurve: _myCurve,
                            switchOutCurve: _myCurve,
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

  Widget _getCountDownWidget(double bottomPadding) {
    return SliverToBoxAdapter(
      child: ClipRect(
        child: ListenableBuilder(
          listenable: _searchBarFocusNode,
          builder: (context, child) => TweenAnimationBuilder(
            builder: (context, value, child) => Align(
              alignment: Alignment.bottomCenter,
              heightFactor: value,
              widthFactor: 1,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: child,
              ),
            ),
            curve: Curves.easeInOutCirc,
            duration: animationDuration,
            tween: Tween<double>(end: _searchBarFocusNode.hasFocus ? 0 : 1),
            child: child,
          ),
          child: const SizedBox(
            height: 49 + 244 + 32 + 36,
            child: CountDownWidget(),
          ),
        ),
      ),
    );
  }

  Widget _getSplitter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            Text(
              'شمارنده های ذخیره',
              style: TextStyle(
                color: ColorScheme.of(context).onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.24,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: _getTimePickerDialog,
                );

                if (result is Duration && mounted) {
                  BlocProvider.of<CountDownBloc>(
                    context,
                  ).add(CountDownDurationUpdateRequested(result));
                }
              },
              icon: Icon(
                Icons.edit,
                color: ColorScheme.of(context).onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTimePickerDialog(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleStateWidget<Duration>(
        initState: const Duration(minutes: 15),
        builder: (context, state, child) {
          return TweenAnimationBuilder(
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: child,
            ),
            duration: animationDuration,
            tween: Tween<double>(begin: 0, end: 1),
            child: AlertDialog(
              backgroundColor: ColorScheme.of(context).surface,
              content: SizedBox(
                width: 100,
                height: 200,
                child: TimePicker(
                  initDuration: state.value,
                  isDuration: true,
                  amPm: false,
                  infiniteHour: true,
                  onChanged: (duration) {
                    state.setState(() => state.value = duration);
                  },
                ),
              ),
              actions: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: ColorScheme.of(context).primaryContainer,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    minimumSize: const Size(90, 36),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'لغو',
                    style: TextStyle(
                      color: ColorScheme.of(context).primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
                TweenAnimationBuilder(
                  duration: animationDuration,
                  tween: Tween<double>(
                    end: state.value == Duration.zero ? 0 : 1,
                  ),
                  curve: _myCurve,
                  builder: (_, value, child) => FilledButton(
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color.lerp(
                        ColorScheme.of(context).onSurfaceVariant,
                        ColorScheme.of(context).primary,
                        value,
                      ),
                      disabledBackgroundColor: Color.lerp(
                        ColorScheme.of(context).onSurfaceVariant,
                        ColorScheme.of(context).primary,
                        value,
                      ),
                      animationDuration: animationDuration,
                      minimumSize: const Size(90, 36),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: state.value == Duration.zero
                        ? null
                        : () {
                            Navigator.pop(context, state.value);
                          },
                    child: child,
                  ),
                  child: Text(
                    'ثبت',
                    style: TextStyle(
                      color: ColorScheme.of(context).onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _gap(double gap) {
    return SliverPadding(padding: EdgeInsets.only(top: gap));
  }

  Widget _getCounters() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: BlocBuilder<CounterListBloc, CounterListState>(
        buildWhen: (previous, current) =>
            previous.manipulatedItems != current.manipulatedItems,
        builder: (context, state) {
          // if (state.type is CounterInitType) {
          // return const SliverToBoxAdapter();
          // // } else if (state.type is! CounterLoadInProgressType &&
          // //     state.sortedCounters.isEmpty) {
          // //   final isFailure = state is CounterLoadFailureType;
          // //   return SliverToBoxAdapter(
          // //     child: Center(
          // //       child: Padding(
          // //         padding: const EdgeInsets.only(top: 10),
          // //         child: TweenAnimationBuilder(
          // //           curve: Curves.easeOutCirc,
          // //           builder: (context, value, child) => Transform.translate(
          // //             offset: Offset(0, -20 * (1 - value)),
          // //             child: Opacity(opacity: value, child: child),
          // //           ),
          // //           duration: animationDuration,
          // //           tween: Tween<double>(begin: 0, end: 1),
          // //           child: Text(
          // //             isFailure
          // //                 ? (state.type as CounterErrorMixin).message
          // //                 : 'شمارنده ای وجود ندارد',
          // //             style: const TextStyle(
          // //               color: CustomColors.grey,
          // //               fontSize: 14,
          // //               fontWeight: FontWeight.normal,
          // //               letterSpacing: -0.24,
          // //             ),
          // //           ),
          // //         ),
          // //       ),
          // //     ),
          // //   );
          // }
          return AutomaticAnimatedSliverListView<CounterWrapper>(
            list: state.manipulatedItems,
            itemExtent: 76 + 20,
            itemBuilder: (context, value, data) => _counterBuilder(value),
            comparator: AnimatedListDiffListComparator(
              sameItem: (elementA, elementB) => elementA.id == elementB.id,
              sameContent: (elementA, elementB) => elementA == elementB,
            ),
          );
        },
      ),
    );
  }

  Widget _counterBuilder(CounterWrapper counter) {
    return SelectableItem<CounterWrapper, CounterListBloc, CounterListState>(
      item: counter,
      onEditPressed: (item) async {
        final result = await showCounterAdd(context, counter);

        if (result != null && mounted) {
          _bloc.add(ListableEditingFinished(result));
        }
      },
      onTap: () {
        BlocProvider.of<CountDownBloc>(context).add(
          CountDownDurationUpdateRequested(
            counter.duration,
          ),
        );
      },
      builder: (context, state, onPressed, onLongPressed, isDeleting) =>
          DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: App.cardBoxShadow(context),
            ),
            child: TweenAnimationBuilder(
              duration: animationDuration,
              tween: Tween<double>(
                end: state.selectedItems.any((e) => e.id == counter.id) ? 1 : 0,
              ),
              // tween: ColorTween(
              //   end: state.selectedItems.any((e) => e.id == counter.id)
              //       ? CustomColors.green.withAlpha(100)
              //       : Colors.white,
              // ),
              builder: (context, value, child) {
                final color = Color.lerp(
                  ColorScheme.of(context).surfaceContainer,
                  ColorScheme.of(context).primary.withAlpha(100),
                  value,
                );
                return FilledButton(
                  onLongPress: onLongPressed,
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    disabledBackgroundColor: color,
                    foregroundColor: ColorScheme.of(context).onSurface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsetsDirectional.zero,
                    elevation: 0,
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 56,
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(
                          end: isDeleting ? 1 : 0,
                        ),
                        curve: _myCurve,
                        duration: animationDuration,
                        builder: (_, borderColorValue, child) => DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: SquircleBorder(
                              side: BorderSide(
                                width: 2,
                                color: Color.lerp(
                                  ColorScheme.of(context).primary,
                                  ColorScheme.of(context).error,
                                  borderColorValue,
                                )!,
                              ),
                            ),
                          ),
                          child: ClipPath(
                            clipper: const ShapeBorderClipper(
                              shape: SquircleBorder(),
                            ),
                            child: child,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: animationDuration,
                          switchInCurve: _myCurve,
                          switchOutCurve: _myCurve,
                          child: counter.image != null
                              ? SizedBox.expand(
                                  child: Image(
                                    image: CustomImageProvider(
                                      imageId: counter.image,
                                      repository: RepositoryProvider.of(
                                        context,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/image_icon.svg',
                                    key: const ValueKey('image_icon'),
                                    colorFilter: ColorFilter.mode(
                                      ColorScheme.of(context).onSurfaceVariant,
                                      BlendMode.srcIn,
                                    ),
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      counter.title,
                      style: TextStyle(
                        color: ColorScheme.of(context).onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: counter.description.isEmpty
                          ? const SizedBox.shrink()
                          : Text(
                              counter.description,
                              maxLines: 2,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: ColorScheme.of(context).onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                letterSpacing: -0.24,
                              ),
                            ),
                    ),
                    Text(
                      durationFormatter(
                        counter.duration,
                        hours: counter.duration.inHours > 0,
                      ),
                      style: TextStyle(
                        color: ColorScheme.of(context).onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.24,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(
                          end: isDeleting ? 1 : 0,
                        ),
                        curve: _myCurve,
                        duration: animationDuration,
                        builder: (_, colorValue, _) => SvgPicture.asset(
                          'assets/icons/play_icon.svg',
                          width: 25,
                          height: 25,
                          colorFilter: ColorFilter.mode(
                            Color.lerp(
                              ColorScheme.of(context).primary,
                              ColorScheme.of(context).error,
                              colorValue,
                            )!,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _getCounterIsEmpty() {
    return SliverToBoxAdapter(
      child: BlocBuilder<CounterListBloc, CounterListState>(
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

/**
   Widget _getHeader() {
    return SliverSafeArea(
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  splashBorderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  overlayColor: WidgetStateColor.fromMap({
                    WidgetState.hovered: CustomColors.green.withAlpha(30),
                    WidgetState.pressed: CustomColors.green.withAlpha(100),
                    WidgetState.focused: CustomColors.green.withAlpha(30),
                  }),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 3),
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(
                      color: CustomColors.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  indicatorColor: CustomColors.green,
                  dividerColor: Colors.transparent,
                  labelColor: CustomColors.black,
                  unselectedLabelColor: CustomColors.grey,
                  labelStyle: TextStyle(
                    fontFamily: TextTheme.of(
                      context,
                    ).titleMedium?.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: -0.24,
                  ),
                  tabs: [
                    const Tab(text: 'شمارنده معکوس'),
                    const Tab(text: 'زمان شمار'),
                  ],
                ),
              ),
              // IconButton(
              //   style: IconButton.styleFrom(
              //     minimumSize: const Size.square(25),
              //   ),
              //   padding: const EdgeInsets.all(10),
              //   onPressed: () {},
              //   icon: SvgPicture.asset('assets/icons/settings_icon.svg'),
              // ),
              // const SizedBox(width: 4),
              // IconButton(
              //   style: IconButton.styleFrom(
              //     minimumSize: const Size.square(25),
              //   ),
              //   padding: const EdgeInsets.all(10),
              //   onPressed: () {},
              //   icon: SvgPicture.asset('assets/icons/add_icon.svg'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabView() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 49 + 244 + 32 + 36,
        child: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: KeepAliveWidget(
                keepAlive: true,
                child: _getTab1(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: KeepAliveWidget(
                keepAlive: true,
                child: _getTab2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTab1() {
    return const CountDownWidget();
  }

  Widget _getTab2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        SizedBox(
          width: 350,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              color: Colors.white,
              boxShadow: _shadows,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: TextTheme.of(context).displayLarge?.fontFamily,
                  color: CustomColors.green,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.24,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('۱۲'),
                          Text(
                            'ساعت',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('۱۲'),
                          Text(
                            'دقیقه',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('۱۲'),
                          Text(
                            'ثانیه',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 107, minHeight: 36),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: CustomColors.lightGreen,
                  overlayColor: CustomColors.green,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {},
                child: const Text(
                  'پایان',
                  style: TextStyle(
                    color: CustomColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: -0.24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 107, minHeight: 36),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: CustomColors.green,
                  overlayColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {},
                child: const Text(
                  'ادامه',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: -0.24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
 */
