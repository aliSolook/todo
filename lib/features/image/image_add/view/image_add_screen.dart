import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/image/image_add/image_add.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/image/models/image_wrapper.dart';
import 'package:todo/features/image/image_add/widgets/image_picker_widget.dart';
import 'package:todo/utils/functions.dart';

class ImageAddScreen extends StatefulWidget {
  const ImageAddScreen({super.key});

  @override
  State<ImageAddScreen> createState() => _ImageAddScreenState();
}

class _ImageAddScreenState extends State<ImageAddScreen> {
  final _titleFocusNode = FocusNode();
  late final TextEditingController _titleController;

  ImageAddScreenBloc get _bloc => BlocProvider.of(context);

  @override
  void initState() {
    final bloc = _bloc;

    _titleController = TextEditingController(text: bloc.state.title);

    _titleFocusNode.addListener(() {
      bloc.add(
        ImageAddScreenTitleFocusChanged(_titleFocusNode.hasFocus),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImageAddScreenBloc, ImageAddScreenState>(
      listener: listener,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: _getBody(context),
        ),
      ),
    );
  }

  void listener(BuildContext context, ImageAddScreenState state) {
    if (state.title != _titleController.text) {
      _titleController.text = _titleController.text;
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
            style: const TextStyle(
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
        ImageWrapper(id: state.id, title: state.title),
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
        title: Text(
          '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} عکس',
          style: const TextStyle(
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
        child: BlocBuilder<ImageAddScreenBloc, ImageAddScreenState>(
          buildWhen: (previous, current) =>
              previous.image != current.image ||
              previous.imageError != current.imageError,
          builder: (context, state) => ImagePickerWidget(
            errorText: state.imageError,
            label: 'عکس',
            image: state.image,
            onImageChanged: (image) {
              _bloc.add(ImageAddScreenImageChanged(image));
            },
          ),
        ),
      ),
    );
  }

  Widget _getTitle() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: BlocBuilder<ImageAddScreenBloc, ImageAddScreenState>(
        buildWhen: (previous, current) =>
            previous.titleError != current.titleError,
        builder: (context, state) {
          return _textField(
            label: 'عنوان عکس',
            focusNode: _titleFocusNode,
            onChanged: (value) => _bloc.add(ImageAddScreenTitleChanged(value)),
            errorText: state.titleError,
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
        controller: controller,
        textInputAction: TextInputAction.newline,
        focusNode: focusNode,
        onTapOutside: (event) {
          focusNode?.unfocus();
        },
        onChanged: onChanged,
        maxLines: maxLines,
        minLines: 1,
        style: const TextStyle(
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
        child: BlocBuilder<ImageAddScreenBloc, ImageAddScreenState>(
          buildWhen: (previous, current) {
            if (previous == current) return false;

            if ((previous.title.isEmpty && current.title.isNotEmpty) ||
                (previous.title.isNotEmpty && current.title.isEmpty)) {
              return true;
            }

            if ((previous.image == null && current.image != null) ||
                (previous.image != null && current.image == null)) {
              return true;
            }

            return false;
          },
          builder: (context, state) => FilledButton(
            onPressed: () {
              _bloc.add(const ImageAddScreenSubmitted());
              // _bloc.add(const ImageAddScreenReset());
              // return;
              // _getBloc(context).add(const ImageAddScreenSubmitted());
            },
            style: FilledButton.styleFrom(
              // backgroundColor: CustomColors.green,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              backgroundColor: state.title.isEmpty || state.image == null
                  ? ColorScheme.of(context).primary
                  : ColorScheme.of(context).primaryContainer,
              minimumSize: const Size(0, 50),
              padding: EdgeInsets.zero,
              elevation: 0,
              overlayColor: state.title.isEmpty || state.image == null
                  ? ColorScheme.of(context).primaryContainer
                  : null,
            ),
            child: Text(
              '${_bloc.state.isEditing ? 'ویرایش' : 'افزودن'} عکس',
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
