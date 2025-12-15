import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/listable/listable.dart';
import 'package:todo/utils/functions.dart';

class CategoryAddScreen extends StatefulWidget {
  const CategoryAddScreen({super.key});

  @override
  State<CategoryAddScreen> createState() => _CategoryAddScreenState();
}

class _CategoryAddScreenState extends State<CategoryAddScreen> {
  final _titleFocusNode = FocusNode();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late final TextEditingController _titleController;

  CategoryAddScreenBloc get _bloc => BlocProvider.of(context);

  @override
  void initState() {
    _titleController = TextEditingController(text: _bloc.state.title);

    _titleFocusNode.addListener(() {
      _bloc.add(CategoryAddScreenTitleFocusChanged(_titleFocusNode.hasFocus));
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _refreshIndicatorKey.currentState?.show();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () {
            _bloc.add(const CategoryAddScreenCustomColorsLoadRequested());
            return _bloc.stream.firstWhere(
              (e) =>
                  !e.customColorsState.isInit &&
                  !e.customColorsState.isInProgress,
            );
          },
          key: _refreshIndicatorKey,
          child: _getBody(context),
        ),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    return BlocListener<CategoryAddScreenBloc, CategoryAddScreenState>(
      listener: _listener,
      child: DeferredPointerHandler(
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            _getAppBar(),
            _gap(32),
            _getTitle(),
            _gap(20),
            _getImagePicker(),
            _gap(20),
            _getColorPicker(),
            _gap(20),
            _getCustomColors(),
            _gap(30),
            _getSubmitButton(),
            const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
            _gap(10),
          ],
        ),
      ),
    );
  }

  void _listener(BuildContext context, CategoryAddScreenState state) {
    if (state.title != _titleController.text) {
      _titleController.text = state.title;
    }
    if (state.submitState.isInProgress) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(
                    const Size.square(150),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox.expand(
                      child: Material(
                        color: ColorScheme.of(context).surface,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            backgroundColor: ColorScheme.of(
                              context,
                            ).primaryContainer,
                            strokeWidth: 5,
                            strokeCap: StrokeCap.round,
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
        },
      );
    }
    if (state.submitState.isSuccess || state.submitState.isFailure) {
      Navigator.pop(context);
    }
    if (state.submitState.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackbarBuilder(
          context,
          gap: 5,
          builder: (_, _) => Text(
            state.submitState.error,
            style: TextStyle(
              color: ColorScheme.of(context).error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    if (state.submitState.isSuccess) {
      Navigator.pop(context, state.submitState.value);
    }
  }

  Widget _gap(double gap) {
    return SliverPadding(padding: EdgeInsets.only(top: gap));
  }

  Widget _getAppBar() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverAppBar(
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },

            icon: const Icon(Icons.close),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        floating: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} دسته‌بندی',
          style: TextStyle(
            color: ColorScheme.of(context).onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.24,
          ),
        ),
      ),
    );
  }

  Widget _getImagePicker() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<CategoryAddScreenBloc, CategoryAddScreenState>(
          buildWhen: (previous, current) => previous.image != current.image,
          builder: (context, state) => BlocProvider(
            create: (context) => ImageSelectorBloc(),
            child: ImageSelectorWidget(
              image: state.image,
              onSelectionChanged: (image) {
                _bloc.add(CategoryAddScreenImageChanged(image));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTitle() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: BlocBuilder<CategoryAddScreenBloc, CategoryAddScreenState>(
        buildWhen: (previous, current) =>
            previous.titleError != current.titleError,
        builder: (context, state) {
          return _textField(
            label: 'عنوان دسته‌بندی',
            focusNode: _titleFocusNode,
            onChanged: (value) =>
                _bloc.add(CategoryAddScreenTitleChanged(value)),
            errorText: state.titleError.isEmpty ? null : state.titleError,
            controller: _titleController,
          );
        },
      ),
    );
  }

  Widget _textField({
    required String label,
    FocusNode? focusNode,
    int? maxLines = 1,
    String? errorText,
    TextEditingController? controller,
    void Function(String value)? onChanged,
  }) {
    return SliverToBoxAdapter(
      child: TextField(
        textInputAction: TextInputAction.newline,
        controller: controller,
        focusNode: focusNode,
        onTapOutside: (event) {
          focusNode?.unfocus();
        },
        onChanged: onChanged,
        maxLines: maxLines,
        minLines: 1,
        style: TextStyle(
          color: ColorScheme.of(context).onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: -0.24,
        ),
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
        ),
      ),
    );
  }

  Widget _getSubmitButton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<CategoryAddScreenBloc, CategoryAddScreenState>(
          buildWhen: (previous, current) =>
              previous.isReadyForSubmition != current.isReadyForSubmition,
          builder: (context, state) => FilledButton(
            key: const Key('category_add_screen_submit'),
            onPressed: () {
              _bloc.add(const CategoryAddScreenSubmitted());
            },
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              backgroundColor: state.isReadyForSubmition
                  ? ColorScheme.of(context).primary
                  : ColorScheme.of(context).primaryContainer,
              minimumSize: const Size(0, 50),
              padding: EdgeInsets.zero,
              elevation: 0,
              overlayColor: state.isReadyForSubmition
                  ? ColorScheme.of(context).primaryContainer
                  : null,
            ),
            child: Text(
              '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} دسته‌بندی',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getColorPicker() {
    final colors = [
      ...Colors.primaries,
      Colors.black,
    ];
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<CategoryAddScreenBloc, CategoryAddScreenState>(
          buildWhen: (previous, current) => previous.color != current.color,
          builder: (context, state) => _colorsLayoutBuilder(
            context: context,
            colors: colors,
            itemBuilder: (color, i) => ColorPaletteColor(
              color: color,
              isSelected: color.toARGB32() == state.color,
              delay: (i + 1) * 2,
              onPressed: () {
                _bloc.add(CategoryAddScreenColorChanged(color.toARGB32()));
              },
            ),
            prefixes: [
              ColorPaletteAction(
                key: const Key('category_add_screen_reset_color'),
                icon: const Icon(Icons.close),
                overrideOverlayColor: false,
                shadowColor: Colors.black,
                onPressed: () =>
                    _bloc.add(const CategoryAddScreenColorChanged(-1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCustomColors() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<CategoryAddScreenBloc, CategoryAddScreenState>(
          buildWhen: (previous, current) =>
              previous.color != current.color ||
              previous.customColorsState != current.customColorsState ||
              previous.customColorDeleteState != current.customColorDeleteState,
          builder: (context, state) {
            Widget child;
            if (state.customColorsState.isFailure) {
              child = Text(
                state.customColorsState.error,
                key: const Key('error'),
                style: TextStyle(color: ColorScheme.of(context).error),
              );
            } else {
              final colors =
                  state.customColorsState.isInProgress ||
                      state.customColorsState.isInit
                  ? List.filled(5, Colors.black)
                  : state.customColorsState.value
                        .map((e) => Color(e.color))
                        .toList();

              child = _colorsLayoutBuilder(
                context: context,
                colors: colors,
                itemBuilder: (color, i) {
                  final id = state.customColorsState.either.orNull()?.elementAt(i).id;
                  return ColorPaletteCustomColor(
                    id: id,
                    color: color,
                    isSelected: color.toARGB32() == state.color,
                    shadowMultiplier: state.customColorsState.isSuccess ? 1 : 0,
                    delay: (i + 1) * 2,
                    onPressed: () {
                      _bloc.add(
                        CategoryAddScreenColorChanged(color.toARGB32()),
                      );
                    },
                    deleteInProgress: state.customColorDeleteState.isInProgress(
                      state.customColorsState.either.orNull()?[i].id,
                    ),
                    onDelete: !state.customColorsState.isSuccess
                        ? null
                        : () {
                            if (!state.customColorsState.isSuccess) return;
                            _bloc.add(
                              CategoryAddScreenCustomColorDeleteRequested(id),
                            );
                          },
                  );
                },
                prefixes: [
                  if (state.customColorsState.isSuccess)
                    ColorPaletteAction(
                      key: const Key('category_add_screen_add_custom_color'),
                      backgroundColor: ColorScheme.of(context).surfaceContainer,
                      shadowColor: Colors.black,
                      icon: SvgPicture.asset(
                        'assets/icons/color_palette_icon.svg',
                        width: 25,
                        colorFilter: ColorFilter.mode(
                          ColorScheme.of(context).onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                      overrideOverlayColor: false,
                      onPressed: () async {
                        final colors =
                            state.customColorsState.either.orNull() ?? [];
                        final result = await showColorAdd(
                          context,
                          colors.isEmpty ? null : colors.last.toColor(),
                        );

                        if (result != null) {
                          _bloc.add(CategoryAddScreenCustomColorAdded(result));
                          _bloc.add(
                            CategoryAddScreenColorChanged(result.color),
                          );
                        }
                      },
                    ),
                ],
              );
            }

            if (state.customColorsState.isInProgress ||
                state.customColorsState.isInit) {
              child = Shimmer.fromColors(
                key: const Key('loading'),
                baseColor: ColorScheme.of(context).onSurfaceVariant,
                highlightColor: ColorScheme.of(context).surfaceContainer,
                child: IgnorePointer(child: child),
              );
            }

            return AnimatedSwitcher(
              duration: animationDuration,
              child: Align(
                key: ValueKey(child.key),
                alignment: AlignmentDirectional.centerStart,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _colorsLayoutBuilder({
    required BuildContext context,
    required List<Color> colors,
    required Widget Function(Color color, int index) itemBuilder,
    List<Widget> prefixes = const [],
    List<Widget> suffixes = const [],
  }) => Wrap(
    spacing: 14,
    runSpacing: 14,
    alignment: WrapAlignment.start,
    children: [
      ...prefixes,
      ...List.generate(colors.length, (i) => itemBuilder(colors[i], i)),
      ...suffixes,
    ],
  );
}
