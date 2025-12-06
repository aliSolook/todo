import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:todo/utils/functions.dart';
import 'package:todo/utils/extensions/extensions.dart';

class CounterAddScreen extends StatefulWidget {
  const CounterAddScreen({super.key});

  @override
  State<CounterAddScreen> createState() => _CounterAddScreenState();
}

class _CounterAddScreenState extends State<CounterAddScreen> {
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  CounterAddScreenBloc get _bloc => BlocProvider.of(context);

  @override
  void initState() {
    final bloc = _bloc;

    _titleController = TextEditingController(text: bloc.state.title);
    _descriptionController = TextEditingController(
      text: bloc.state.description,
    );

    _titleFocusNode.addListener(() {
      bloc.add(
        CounterAddScreenTitleFocusChanged(_titleFocusNode.hasFocus),
      );
    });
    _durationFocusNode.addListener(() {
      bloc.add(
        CounterAddScreenDurationFocusChanged(_durationFocusNode.hasFocus),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterAddScreenBloc, CounterAddScreenState>(
      listener: listener,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: _getBody(context),
        ),
      ),
    );
  }

  void listener(BuildContext context, CounterAddScreenState state) {
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
    }
    if (_descriptionController.text != state.description) {
      _descriptionController.text = state.title;
    }

    if (state.status.isInProgress) {
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
    if (state.status.isFailure || state.status.isSuccess) {
      Navigator.pop(context);
    }
    if (state.status.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackbarBuilder(
          context,
          gap: 5,
          builder: (_, _) => Text(
            state.error ?? 'مشکلی پیش آمد',
            style: TextStyle(
              color: ColorScheme.of(context).onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    if (state.status.isSuccess) {
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

      Navigator.pop(
        context,
        CounterWrapper(
          id: state.id,
          title: state.title,
          duration: state.duration,
          image: state.image,
          description: state.description,
        ),
      );
    }
  }

  Widget _getBody(BuildContext context) {
    return CustomScrollView(
      clipBehavior: Clip.none,
      slivers: [
        _getAppBar(),
        _gap(32),
        _getTitle(),
        _gap(20),
        _getDescription(),
        _gap(20),
        _getTimeSelector(),
        _gap(30),
        _getImagePicker(),
        _gap(30),
        _getSubmitButton(),
        const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
        _gap(10),
      ],
    );
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
        shadowColor: ColorScheme.of(context).shadow,
        title: Text(
          '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} شمارنده',
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
        child: BlocBuilder<CounterAddScreenBloc, CounterAddScreenState>(
          buildWhen: (previous, current) => previous.image != current.image,
          builder: (context, state) => ImageSelectorWidget(
            image: state.image,
            onSelectionChanged: (newImage) {
              _bloc.add(CounterAddScreenImageChanged(newImage));
            },
          ),
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
        onChanged: (value) =>
            _bloc.add(CounterAddScreenDescriptionChanged(value)),
        focusNode: _descriptionFocusNode,
        controller: _descriptionController,
      ),
    );
  }

  Widget _getTitle() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: BlocBuilder<CounterAddScreenBloc, CounterAddScreenState>(
        buildWhen: (previous, current) =>
            previous.titleError != current.titleError,
        builder: (context, state) {
          return _textField(
            label: 'عنوان شمارنده',
            focusNode: _titleFocusNode,
            onChanged: (value) =>
                _bloc.add(CounterAddScreenTitleChanged(value)),
            errorText: state.titleError,
            controller: _titleController,
          );
        },
      ),
    );
  }

  Widget _getTimeSelector() {
    final style = TextStyle(
      color: ColorScheme.of(context).onSurface,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      letterSpacing: 0,
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<CounterAddScreenBloc, CounterAddScreenState>(
          buildWhen: (previous, current) =>
              previous.durationError != current.durationError,
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
                  _bloc.add(CounterAddScreenDurationChanged(duration)),
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
            errorText: state.durationError,
            label: 'زمان',
          ),
        ),
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
        controller: controller,
        textInputAction: TextInputAction.newline,
        focusNode: focusNode,
        onTapOutside: (event) {
          focusNode?.unfocus();
        },
        onChanged: onChanged,
        maxLines: maxLines,
        minLines: 1,
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
        child: BlocBuilder<CounterAddScreenBloc, CounterAddScreenState>(
          buildWhen: (previous, current) {
            if (previous == current) return false;

            if ((previous.title.isEmpty && current.title.isNotEmpty) ||
                (previous.title.isNotEmpty && current.title.isEmpty)) {
              return true;
            }

            if ((previous.duration == Duration.zero &&
                    current.duration != Duration.zero) ||
                (previous.duration != Duration.zero &&
                    current.duration == Duration.zero)) {
              return true;
            }

            return false;
          },
          builder: (context, state) => FilledButton(
            onPressed: () {
              _bloc.add(const CounterAddScreenSubmitted());
            },
            style: FilledButton.styleFrom(
              // backgroundColor: CustomColors.green,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              minimumSize: const Size(0, 50),
              padding: EdgeInsets.zero,
              elevation: 0,
              backgroundColor:
                  state.title.isEmpty || state.duration == Duration.zero
                  ? ColorScheme.of(context).primaryContainer
                  : ColorScheme.of(context).primary,
              foregroundColor:
                  state.title.isEmpty || state.duration == Duration.zero
                  ? ColorScheme.of(context).primary
                  : ColorScheme.of(context).onPrimary,
              // overlayColor: ColorScheme.of(context).primaryContainer,
            ),
            child: Text(
              '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} شمارنده',
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
