import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/category/category_add/utils/show_category_add.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/task/task_add/bloc/task_add_screen_bloc.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/task/utils/utils.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/functions.dart';
import 'package:todo/utils/extensions/extensions.dart';

class TaskAddScreen extends StatefulWidget {
  const TaskAddScreen({super.key});

  @override
  State<TaskAddScreen> createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();
  final _dateSelectorFocusNode = FocusNode();
  final _startingTimeFocusNode = FocusNode();

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  final _categoriesScrollController = FixedExtentScrollController(
    initialItem: 0,
  );

  TaskAddScreenBloc get _bloc => BlocProvider.of(context);

  @override
  void initState() {
    _titleController = TextEditingController(text: _bloc.state.title);
    _descriptionController = TextEditingController(
      text: _bloc.state.description,
    );

    _titleFocusNode.addListener(() {
      _bloc.add(TaskAddScreenTitleFocusChanged(_titleFocusNode.hasFocus));
    });
    _durationFocusNode.addListener(() {
      _bloc.add(
        TaskAddScreenDurationFocusChanged(_durationFocusNode.hasFocus),
      );
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
        body: _getBody(context),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    return BlocListener<TaskAddScreenBloc, TaskAddScreenState>(
      listener: _listener,
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          _bloc.add(const TaskAddScreenCategoriesLoadRequested());
          await _bloc.stream.firstWhere((e) => !e.categoriesState.isInProgress);
        },
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            _getAppBar(),
            _gap(32),
            _getTitle(),
            _gap(20),
            _getDescription(),
            _gap(20),
            _getDuration(),
            _gap(20),
            _getDateSelectors(),
            _gap(30),
            _getCategories(),
            _gap(30),
            _getImagePicker(),
            _gap(30),
            _getSubmitButton(),
            const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
            _gap(10),
          ],
        ),
      ),
    );
  }

  void _listener(BuildContext context, TaskAddScreenState state) {
    if (state.title != _titleController.text) {
      _titleController.text = state.title;
    }
    if (state.description != _descriptionController.text) {
      _descriptionController.text = state.description;
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
      // final duration = const Duration(seconds: 3);
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(
      //       snackbarBuilder(
      //         gap: 5,
      //         builder: (_, value) => Row(
      //           children: [
      //             Expanded(
      //               child: Align(
      //                 alignment: AlignmentDirectional.centerStart,
      //                 child: TextButton(
      //                   style: TextButton.styleFrom(
      //                     foregroundColor: Colors.white,
      //                     backgroundColor: CustomColors.green,
      //                   ),
      //                   onPressed: () {
      //                     ScaffoldMessenger.of(
      //                       context,
      //                     ).hideCurrentSnackBar();
      //                   },
      //                   child: const Text(
      //                     'افزودن شمارنده های بیشتر',
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             Text(
      //               'بستن صفحه در ${duration.inSeconds * value ~/ 1 + (value == 0 ? 0 : 1)} ثانیه',
      //               textAlign: TextAlign.end,
      //               overflow: TextOverflow.ellipsis,
      //             ),
      //             const SizedBox(width: 12),
      //             // IconButton(onPressed: () {}, icon: Icon(Icons.close)),
      //           ],
      //         ),
      //       ),
      //     )
      //     .closed
      //     .then((value) {
      //       if (value == SnackBarClosedReason.hide) {
      //       } else {
      //         if (context.mounted) Navigator.pop(context);
      //       }
      //     });

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
          '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} تسک',
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
        child: BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
          buildWhen: (previous, current) => previous.image != current.image,
          builder: (context, state) => BlocProvider(
            create: (context) => ImageSelectorBloc(),
            child: ImageSelectorWidget(
              image: state.image,
              onSelectionChanged: (image) {
                _bloc.add(TaskAddScreenImageChanged(image));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCategories() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                Text(
                  'دسته بندی',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.bold,
                    color: ColorScheme.of(context).onSurface,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 23,
                    child: BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
                      buildWhen: (previous, current) =>
                          previous.categoriesState != current.categoriesState,
                      builder: (context, state) {
                        final categories =
                            state.categoriesState.either.orNull() ?? [];

                        return ListWheelScrollView(
                          itemExtent: 23,
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _categoriesScrollController,
                          children: categories
                              .map(
                                (e) => Align(
                                  heightFactor: 1,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    e.title,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.45,
                                      fontWeight: FontWeight.bold,
                                      color: ColorScheme.of(context).onSurface,
                                      letterSpacing: -0.24,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding / 2,
              ),
              child: BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
                buildWhen: (previous, current) =>
                    previous.categoriesState != current.categoriesState,
                builder: (context, state) {
                  if (!state.categoriesState.isFailure) {
                    final List<CategoryWrapper?> categories =
                        state.categoriesState.either.orNull() ??
                        List.filled(4, null);
                    return AnimatedSwitcher(
                      duration: animationDuration,
                      child: Row(
                        key: ValueKey(state.categoriesState.isSuccess),
                        children: List.generate(
                          categories.length + 1,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: horizontalPadding / 2,
                            ),
                            child: index >= categories.length
                                ? _getCategoryAddButton()
                                : _getCategory(categories[index], index),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryAddButton() {
    return SizedBox(
      width: 130,
      height: 163,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadiusGeometry.all(
            Radius.circular(20),
          ),
          color: ColorScheme.of(context).primaryContainer,
          boxShadow: categoryShadowBuilder(
            ColorScheme.of(context).primary,
            strength: 1,
            opacityMultiplier: 1,
          ),
        ),
        child: FilledButton(
          onPressed: () async {
            final result = await showCategoryAdd(context);

            if (result != null) {
              _bloc.add(const TaskAddScreenCategoriesLoadRequested());
            }
          },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              side: BorderSide(
                color: ColorScheme.of(context).onSurfaceVariant,
                width: 2,
              ),
            ),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            elevation: 0,
            disabledBackgroundColor: Colors.transparent,
            overlayColor: ColorScheme.of(context).primary,
          ),
          child: Icon(
            Icons.add_rounded,
            color: ColorScheme.of(context).onSurfaceVariant,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _getCategory(CategoryWrapper? category, int index) {
    return BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
      buildWhen: (previous, current) => previous.category != current.category,
      builder: (_, state) {
        return CategoryWidget(
          isSelected: category == null || state.category == null
              ? null
              : state.category == category.id,
          category: category?.toCategory(),
          onTap: category == null
              ? null
              : () {
                  // if (category == null) return;
                  _categoriesScrollController.animateToItem(
                    index,
                    duration: animationDuration,
                    curve: Curves.easeInOutCirc,
                  );
                  _bloc.add(
                    TaskAddScreenCategoryChanged(category.id),
                  );
                },
        );
      },
    );
  }

  Widget _getDateSelectors() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: ResponsiveLayout(
          horizontalSpacing: 16,
          verticalSpacing: 10,
          widths: [130, 130],
          children: [
            _getDateSelector(),
            _getStartingTime(),
          ],
        ),
      ),
    );
  }

  Widget _getDescription() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: _textField(
        label: 'توضیحات',
        maxLines: 3,
        onChanged: (value) => _bloc.add(TaskAddScreenDescriptionChanged(value)),
        focusNode: _descriptionFocusNode,
        controller: _descriptionController,
      ),
    );
  }

  Widget _getTitle() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
        buildWhen: (previous, current) =>
            previous.titleError != current.titleError,
        builder: (context, state) {
          return _textField(
            label: 'عنوان تسک',
            focusNode: _titleFocusNode,
            onChanged: (value) => _bloc.add(TaskAddScreenTitleChanged(value)),
            errorText: state.titleError.isEmpty ? null : state.titleError,
            controller: _titleController,
          );
        },
      ),
    );
  }

  Widget _getDuration() {
    final style = TextStyle(
      color: ColorScheme.of(context).onSurface,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      letterSpacing: 0,
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
          buildWhen: (previous, current) =>
              previous.durationError != current.durationError ||
              previous.duration != current.duration,
          builder: (context, state) => DropDownableWidget(
            headerBuilder: (context) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableRegion(
                  selectionControls: materialTextSelectionControls,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        convertDigits(
                          state.duration.inHours.toString().padLeft(2, '0'),
                        ),
                        style: style,
                      ),
                      const SizedBox(width: 2),
                      Text(':', style: style),
                      const SizedBox(width: 2),
                      Text(
                        convertDigits(
                          state.duration.minute.toString().padLeft(2, '0'),
                        ),
                        style: style,
                      ),
                      const SizedBox(width: 2),
                      Text(':', style: style),
                      const SizedBox(width: 2),
                      Text(
                        convertDigits(
                          state.duration.second.toString().padLeft(2, '0'),
                        ),
                        style: style,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bodyBuilder: (context) => TimePicker(
              infiniteHour: true,
              initDuration: state.duration,
              amPm: false,
              onChanged: (duration) =>
                  _bloc.add(TaskAddScreenDurationChanged(duration)),
            ),
            focusNode: _durationFocusNode,
            suffix: SvgPicture.asset(
              'assets/icons/clock_icon.svg',
              colorFilter: ColorFilter.mode(
                ColorScheme.of(context).onSurfaceVariant,
                BlendMode.srcIn,
              ),
              width: 25,
              height: 25,
            ),
            errorText: state.durationError.isEmpty ? null : state.durationError,
            label: 'مدت زمان مورد نیاز',
          ),
        ),
      ),
    );
  }

  Widget _getDateSelector() {
    return BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
      buildWhen: (previous, current) =>
          previous.startingDate.withoutTime != current.startingDate.withoutTime,
      builder: (context, state) {
        return DropDownableWidget(
          targetAnchor: AlignmentDirectional.bottomStart,
          followerAnchor: AlignmentDirectional.topStart,
          dropDownPadding: const EdgeInsetsDirectional.only(end: 48),
          headerBuilder: (context) {
            final style = TextStyle(
              color: ColorScheme.of(context).onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              letterSpacing: 0,
            );

            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableRegion(
                  selectionControls: materialTextSelectionControls,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        convertDigits(state.startingDate.year.toString()),
                        style: style,
                      ),
                      const SizedBox(width: 2),
                      Text('/', style: style),
                      const SizedBox(width: 2),
                      Text(
                        convertDigits(
                          state.startingDate.month.toString().padLeft(
                            2,
                            '0',
                          ),
                        ),
                        style: style,
                      ),
                      const SizedBox(width: 2),
                      Text('/', style: style),
                      const SizedBox(width: 2),
                      Text(
                        convertDigits(
                          state.startingDate.day.toString().padLeft(
                            2,
                            '0',
                          ),
                        ),
                        style: style,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          bodyBuilder: (context) {
            final now = Jalali.now();
            return Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PersianCalendarDatePicker(
                    initialDate: state.startingDate,
                    firstDate: now,
                    lastDate: now.copyWith(year: now.year + 10),
                    onDateChanged: (value) {
                      _bloc.add(
                        TaskAddScreenStartingDateChanged(
                          state.startingDate.copyWith(
                            year: value.year,
                            month: value.month,
                            day: value.day,
                          ),
                        ),
                      );
                      Future.delayed(
                        Durations.short3,
                        _dateSelectorFocusNode.unfocus,
                      );
                    },
                  ),
                ],
              ),
            );
          },
          focusNode: _dateSelectorFocusNode,
          suffix: SvgPicture.asset(
            'assets/icons/calendar_icon.svg',
            colorFilter: ColorFilter.mode(
              ColorScheme.of(context).onSurfaceVariant,
              BlendMode.srcIn,
            ),
            width: 25,
            height: 25,
          ),
          // initState: Jalali.now(),
          label: 'تاریخ شروع تسک',
        );
      },
    );
  }

  Widget _getStartingTime() {
    final style = TextStyle(
      color: ColorScheme.of(context).onSurface,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      letterSpacing: 0,
    );
    final use24Hour = MediaQuery.of(
      context,
    ).alwaysUse24HourFormat;
    final isLtr = Directionality.maybeOf(context) != TextDirection.rtl;
    return BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
      buildWhen: (previous, current) =>
          previous.startingDate.time != current.startingDate.time,
      builder: (context, state) {
        final startingTime = state.startingDate.toTimeOfDay();
        return DropDownableWidget(
          followerAnchor: AlignmentDirectional.topEnd,
          targetAnchor: AlignmentDirectional.bottomEnd,
          dropDownPadding: const EdgeInsetsDirectional.only(start: 48),
          headerBuilder: (context) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SelectableRegion(
                selectionControls: materialTextSelectionControls,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLtr && !use24Hour) ...{
                      Text(
                        startingTime.period == DayPeriod.pm ? 'ب.ظ' : 'ق.ظ',
                        style: style,
                      ),
                      const SizedBox(width: 5),
                    },
                    Text(
                      convertDigits(
                        (use24Hour
                                ? startingTime.hour
                                : startingTime.hourOfPeriod)
                            .toString()
                            .padLeft(2, '0'),
                      ),
                      style: style,
                    ),
                    const SizedBox(width: 2),
                    Text(':', style: style),
                    const SizedBox(width: 2),
                    Text(
                      convertDigits(
                        startingTime.minute.toString().padLeft(2, '0'),
                      ),
                      style: style,
                    ),
                    if (isLtr && !use24Hour) ...{
                      const SizedBox(width: 5),
                      Text(
                        startingTime.hour >= 12 ? 'ب.ظ' : 'ق.ظ',
                        style: style,
                      ),
                    },
                  ],
                ),
              ),
            ),
          ),
          bodyBuilder: (context) => TimePicker(
            initDuration: startingTime.toDuration(),
            amPm: true,
            seconds: false,
            onChanged: (duration) {
              final time = duration.toTimeOfDay();
              _bloc.add(
                TaskAddScreenStartingDateChanged(
                  state.startingDate.copyWith(
                    hour: time.hour,
                    minute: time.minute,
                  ),
                ),
              );
            },
          ),

          focusNode: _startingTimeFocusNode,
          suffix: SvgPicture.asset(
            'assets/icons/clock_icon.svg',
            colorFilter: ColorFilter.mode(
              ColorScheme.of(context).onSurfaceVariant,
              BlendMode.srcIn,
            ),
            width: 25,
            height: 25,
          ),
          label: 'ساعت شروع تسک',
        );
      },
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
        child: BlocBuilder<TaskAddScreenBloc, TaskAddScreenState>(
          buildWhen: (previous, current) =>
              previous.isReadyForSubmition != current.isReadyForSubmition,
          builder: (context, state) => FilledButton(
            onPressed: () {
              _bloc.add(const TaskAddScreenSubmitted());
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
              '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} تسک',
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
}
