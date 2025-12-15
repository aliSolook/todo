import 'dart:math' as math;
import 'dart:math';
import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo/features/image/image.dart' hide Image;
import 'package:todo/constants/constants.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/disable_scroll_into_view_scroll_controller.dart';

enum ImageSelectorStyle { fullMode, tileMode }

class ImageSelectorWidget extends StatefulWidget {
  const ImageSelectorWidget({
    super.key,
    required this.onSelectionChanged,
    this.image,
    this.style = ImageSelectorStyle.fullMode,
    this.errorText,
    this.label,
    this.duration = animationDuration,
    this.aspectRatio = 1,
  });

  final void Function(dynamic image) onSelectionChanged;
  final dynamic image;
  final ImageSelectorStyle style;
  final String? errorText;
  final String? label;
  final Duration duration;
  final double? aspectRatio;

  @override
  State<ImageSelectorWidget> createState() => _ImageSelectorWidgetState();
}

class _ImageSelectorWidgetState extends State<ImageSelectorWidget>
    with TickerProviderStateMixin {
  late final AnimationController _errorAnimationController;
  late final AnimationController _mainAnimationController;
  late String _errorText = widget.errorText ?? '';
  final _buttonFocusNode = FocusNode();

  @override
  void initState() {
    _errorAnimationController = AnimationController(
      vsync: this,
      value: widget.errorText != null ? 1 : 0,
      duration: kThemeAnimationDuration,
    );
    _mainAnimationController = AnimationController(
      vsync: this,
      value: widget.image != null ? 1 : 0,
      duration: kThemeAnimationDuration,
    );

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ImageSelectorWidget oldWidget) {
    if (oldWidget.errorText == null && widget.errorText != null) {
      _errorText = widget.errorText!;
      _errorAnimationController.forward();
    } else if (oldWidget.errorText != null && widget.errorText == null) {
      _errorAnimationController.reverse();
    }

    if (oldWidget.image == null && widget.image != null) {
      _mainAnimationController.forward();
    } else if (oldWidget.image != null && widget.image == null) {
      _mainAnimationController.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _errorAnimationController.dispose();

    _buttonFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        _getButton(),
        _getCloseIcon(),
      ],
    );

    if (widget.aspectRatio == null) return child;
    return AspectRatio(
      aspectRatio: widget.aspectRatio!,
      child: child,
    );
  }

  AnimatedBuilder _getCloseIcon() {
    return AnimatedBuilder(
      animation: _mainAnimationController,
      builder: (_, _) => Visibility(
        visible: _mainAnimationController.value != 0,
        child: Align(
          alignment: AlignmentDirectional.topEnd,
          child: Transform.rotate(
            angle: math.pi * _mainAnimationController.value,
            child: Transform.scale(
              scale: _mainAnimationController.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: IconButton(
                  key: const Key('image_selector_widget_deselect_button'),
                  onPressed: () {
                    if (widget.image == null) return;
                    widget.onSelectionChanged(null);
                  },
                  icon: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: CircleBorder(
                        side: BorderSide(
                          color: Color.lerp(
                            ColorScheme.of(context).onSurfaceVariant,
                            ColorScheme.of(context).primary,
                            _mainAnimationController.value,
                          )!,
                          width: 2,
                        ),
                      ),
                    ),
                    child: CloseIconWidget(
                      size: 25,
                      thickness: 2,
                      color: ColorScheme.of(context).primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AnimatedBuilder _getButton() {
    return AnimatedBuilder(
      animation: _errorAnimationController,
      builder: (context, child) => ListenableBuilder(
        listenable: _buttonFocusNode,
        builder: (context, child) => InputDecorator(
          isFocused: _buttonFocusNode.hasFocus || widget.image != null,
          decoration: InputDecoration(
            visualDensity: VisualDensity.standard,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            label: widget.label == null
                ? null
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(widget.label!),
                  ),
            error: _errorAnimationController.value == 0
                ? null
                : Align(
                    heightFactor: _errorAnimationController.value,
                    widthFactor: 1,
                    child: Opacity(
                      opacity: _errorAnimationController.value,
                      child: Text(
                        _errorText,
                        style: Theme.of(
                          context,
                        ).inputDecorationTheme.errorStyle,
                      ),
                    ),
                  ),
          ),
          child: child,
        ),
        child: child,
      ),
      child: FilledButton(
        onPressed: _onClick,
        style: FilledButton.styleFrom(
          // backgroundColor: CustomColors.green,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: widget.duration,
          child: widget.image == null
              ? SizedBox.expand(
                  key: const ValueKey(
                    'assets/icons/add_photo_icon.svg',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: SvgPicture.asset(
                      'assets/icons/add_photo_icon.svg',
                      colorFilter: ColorFilter.mode(
                        ColorScheme.of(context).onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  key: ValueKey(widget.image),
                  child: Image(
                    image: CustomImageProvider(
                      imageId: widget.image,
                      repository: RepositoryProvider.of(context),
                    ),
                    errorBuilder: (context, error, stackTrace) => Text(
                      'خطا در دریافت فایل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorScheme.of(context).error,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _onClick() async {
    final result = await showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      context: context,
      builder: (_) => RepositoryProvider<ImageRepository>(
        create: (context) => locator.get(),
        child: BlocProvider(
          create: (_) => ImageSelectorBloc(),
          child: const ImageSelectorModalSheet(),
        ),
      ),
    );

    if (result is ImageWrapper && result.id != widget.image) {
      widget.onSelectionChanged(result.id);
    }
  }
}

class ImageSelectorModalSheet extends StatefulWidget {
  const ImageSelectorModalSheet({super.key});

  @override
  State<ImageSelectorModalSheet> createState() =>
      _ImageSelectorModalSheetState();
}

class _ImageSelectorModalSheetState extends State<ImageSelectorModalSheet>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchBarFocusNode = FocusNode();
  final _sheetController = DraggableScrollableController();
  late final SimulationDriver _simulationDriver;
  ImageSelectorBloc? _bloc;

  ImageSelectorBloc get _getBloc {
    return _bloc ?? (_bloc = BlocProvider.of(context));
  }

  @override
  void initState() {
    _simulationDriver = SimulationDriver(
      onTick: (x) {
        if (!_sheetController.isAttached) return;
        _sheetController.jumpTo(
          _sheetController.pixelsToSize(x).clamp(0, 1),
        );
      },
      vsync: this,
    );

    _getBloc.add(ImageSelectorLoadImagesRequested());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _sheetController.dispose();
    _getBloc.add(ImageSelectorDisposed());
  }

  void dragDownHandler(DragDownDetails details) {
    _simulationDriver.stop();
  }

  void dragUpdateHandler(DragUpdateDetails details) {
    if (!_sheetController.isAttached) return;
    _sheetController.jumpTo(
      _sheetController.pixelsToSize(
        _sheetController.pixels - details.delta.dy,
      ),
    );
  }

  void dragEndHandler(DragEndDetails details) {
    if (!_sheetController.isAttached) return;

    final velocity = details.velocity.pixelsPerSecond.dy;

    if (velocity.abs() < 50) return;

    final simulation = FrictionSimulation(
      0.0001,
      _sheetController.pixels,
      -velocity,
      tolerance: const Tolerance(velocity: 30),
    );

    _simulationDriver.start(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragDown: dragDownHandler,
        onVerticalDragUpdate: dragUpdateHandler,
        onVerticalDragEnd: dragEndHandler,
        onTap: () => Navigator.pop(context),
        child: GestureDetector(
          onTap: () {},
          child: SafeArea(
            top: true,
            bottom: false,
            left: false,
            right: false,
            child: DraggableScrollableSheet(
              expand: true,
              initialChildSize: .8,
              controller: _sheetController,
              builder: (context, scrollController) => SafeArea(
                top: true,
                bottom: false,
                right: false,
                left: false,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadiusGeometry.vertical(
                        top: Radius.circular(10),
                      ),
                      child: ColoredBox(
                        color: ColorScheme.of(context).surface,
                        child: _getScrollView(scrollController),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onVerticalDragEnd: dragEndHandler,
                        onVerticalDragUpdate: dragUpdateHandler,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            height: 5,
                            width: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(999),
                                ),
                                color: ColorScheme.of(context).onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
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

  Widget _getScrollView(ScrollController scrollController) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 20)),
        _getSearchBar(),
        _getGridView(),
      ],
    );
  }

  Widget _getSearchBar() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: MySliverFloatingHeader(
        topPadding: 20,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        floatingDecoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: kElevationToShadow[4],
        ),
        height: 48,
        child: TextField(
          focusNode: _searchBarFocusNode,
          controller: _searchController,
          onTapOutside: (event) {
            _searchBarFocusNode.unfocus();
          },
          onChanged: (value) =>
              _getBloc.add(ImageSelectorSearchTextChanged(value)),
          scrollController: DisableScrollIntoViewScrollController(),
          decoration: InputDecoration(
            constraints: const BoxConstraints(maxHeight: 48, minHeight: 48),
            labelText: 'جستحوی عکسات ...',
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10),
              child: ListenableBuilder(
                listenable: _searchBarFocusNode,
                builder: (context, child) {
                  return AnimatedSwitcher(
                    duration: animationDuration,
                    child: !_searchBarFocusNode.hasFocus
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: SvgPicture.asset(
                              'assets/icons/search_icon.svg',
                              key: const ValueKey(true),
                              width: 25,
                            ),
                          )
                        : AspectRatio(
                            aspectRatio: 1,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(5.0),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchBarFocusNode.unfocus();
                                _getBloc.add(
                                  const ImageSelectorSearchTextChanged(
                                    '',
                                    false,
                                  ),
                                );
                              },
                              onLongPress: () {},
                              icon: SizedBox.expand(
                                child: FittedBox(
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: ColorScheme.of(
                                      context,
                                    ).onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
            labelStyle: TextStyle(
              color: ColorScheme.of(context).onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: -0.24,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 15),
              child: SvgPicture.asset(
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
      ),
    );
  }

  Widget _getGridView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      sliver: SliverToBoxAdapter(
        child: LayoutBuilder(
          builder: (context, constraints) =>
              BlocBuilder<ImageSelectorBloc, ImageSelectorState>(
                buildWhen: (previous, current) =>
                    previous.isAscending != current.isAscending ||
                    previous.order != current.order ||
                    previous.searchText != current.searchText ||
                    previous.status != current.status,
                builder: (context, state) {
                  const crossCount = 3;
                  const crossSpacing = 10.0;
                  final maxWidth =
                      constraints.maxWidth - crossSpacing * (crossCount - 1);
                  final itemWidth = maxWidth / crossCount;

                  final addButton = _itemBuilder(
                    title: 'افزودن عکس',
                    onPressed: onNewImage,
                    isLoading: state.status.isLoading,
                    child: SizedBox.expand(
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.add_rounded,
                            color: ColorScheme.of(context).primary,
                          ),
                        ),
                      ),
                    ),
                  );

                  Widget builder(int index) => ConstrainedBox(
                    constraints: BoxConstraints.tight(
                      Size(itemWidth, itemWidth + 50),
                    ),
                    child: index == 0
                        ? addButton
                        : _imageBuilder(
                            isLoading: state.status.isLoading,
                            state.sortedImages[index - 1],
                            constraints.maxWidth,
                          ),
                  );

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      state.sortedImages.length + 1,
                      builder,
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _itemBuilder({
    required void Function() onPressed,
    required Widget child,
    required String? title,
    bool isLoading = false,
    Key? key,
    bool hasError = false,
  }) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: ColorScheme.of(context).onSurfaceVariant,
        highlightColor: ColorScheme.of(context).surfaceContainer,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: ColorScheme.of(context).primaryContainer,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    border: Border.fromBorderSide(
                      BorderSide(
                        width: 2,
                        color: hasError
                            ? ColorScheme.of(context).error
                            : ColorScheme.of(context).onSurfaceVariant,
                      ),
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.fromBorderSide(BorderSide(width: 2)),
              ),
              child: SizedBox(
                width: 60,
                height: 20,
              ),
            ),
          ],
        ),
      );
    }
    return Material(
      child: InkWell(
        key: key,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        hoverColor: ColorScheme.of(context).primary.withAlpha(20),
        highlightColor: ColorScheme.of(context).primary.withAlpha(30),
        focusColor: ColorScheme.of(context).primary.withAlpha(30),
        splashColor: ColorScheme.of(context).primary.withAlpha(30),
        onTap: hasError || isLoading ? null : onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).surfaceContainer,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  border: Border.all(
                    color: hasError
                        ? ColorScheme.of(context).error
                        : ColorScheme.of(context).onSurfaceVariant,
                    width: 2,
                  ),
                ),
                child: child,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title ?? 'مشکلی در خواندن عکس بوجود آمد',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: hasError ? 12 : 14,
                color: hasError
                    ? ColorScheme.of(context).error
                    : ColorScheme.of(context).onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBuilder(
    ImageWrapper? image,
    double maxWidth, {
    bool isLoading = false,
  }) {
    return AnimatedTo.curve(
      globalKey: GlobalObjectKey(image ?? ''),
      slidingFrom: Offset(
        Random().nextInt(maxWidth.ceil() * 2) - maxWidth,
        Random().nextInt(maxWidth.ceil() * 2) - maxWidth,
      ),
      duration: animationDuration * 1.5,
      curve: Curves.easeInOut,
      child: TweenAnimationBuilder(
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        duration: animationDuration * 1.5,
        tween: Tween<double>(begin: 0, end: 1),
        child: _itemBuilder(
          key: ValueKey(image?.id),
          title: image?.title,
          isLoading: isLoading,
          onPressed: () {
            Navigator.pop(context, image);
          },
          hasError: image == null,
          child: image == null || isLoading
              ? Padding(
                  padding: const EdgeInsets.all(horizontalPadding),
                  child: SvgPicture.asset(
                    'assets/icons/image_icon.svg',
                    colorFilter: ColorFilter.mode(
                      ColorScheme.of(context).error,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : Image(
                  image: CustomImageProvider(
                    imageId: image.id,
                    repository: RepositoryProvider.of(context),
                  ),
                ),
        ),
      ),
    );
  }

  void onNewImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ImageAddScreenBloc(),
          child: const ImageAddScreen(),
        ),
      ),
    );

    if (result != null) {
      _getBloc.add(ImageSelectorLoadImagesRequested());
    }
  }
}
