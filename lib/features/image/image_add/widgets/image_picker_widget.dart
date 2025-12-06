import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/widgets/close_icon_widget.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({
    super.key,
    required this.onImageChanged,
    this.duration = animationDuration,
    this.image,
    this.aspectRatio = 1,
    this.width,
    this.height,
    this.errorText,
    this.label,
  });

  final void Function(Uint8List? image) onImageChanged;
  final Duration duration;
  final Uint8List? image;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final String? errorText;
  final String? label;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget>
    with TickerProviderStateMixin {
  final _picker = ImagePicker();
  var _imageKey = UniqueKey();
  late final errorAnimationController = AnimationController(
    vsync: this,
    value: widget.errorText != null ? 1 : 0,
    duration: kThemeAnimationDuration,
  );
  late final mainAnimationController = AnimationController(
    vsync: this,
    value: widget.image != null ? 1 : 0,
    duration: kThemeAnimationDuration,
  );
  late String errorText = widget.errorText ?? '';

  @override
  void didUpdateWidget(covariant ImagePickerWidget oldWidget) {
    if (!listEquals(oldWidget.image, widget.image)) _imageKey = UniqueKey();

    if (oldWidget.errorText == null && widget.errorText != null) {
      errorText = widget.errorText!;
      errorAnimationController.forward();
    } else if (oldWidget.errorText != null && widget.errorText == null) {
      errorAnimationController.reverse();
    }

    if (oldWidget.image == null && widget.image != null) {
      mainAnimationController.forward();
    } else if (oldWidget.image != null && widget.image == null) {
      mainAnimationController.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: errorAnimationController,
          builder: (context, child) => InputDecorator(
            isFocused: widget.image != null,
            decoration: InputDecoration(
              label: widget.label == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(widget.label!),
                    ),
              error: errorAnimationController.value == 0
                  ? null
                  : Align(
                      heightFactor: errorAnimationController.value,
                      widthFactor: 1,
                      child: Opacity(
                        opacity: errorAnimationController.value,
                        child: Text(
                          errorText,
                          style: Theme.of(
                            context,
                          ).inputDecorationTheme.errorStyle,
                        ),
                      ),
                    ),
            ),
            child: child,
          ),
          child: Builder(
            builder: (context) {
              Widget child = FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  disabledBackgroundColor: Colors.transparent,
                  overlayColor: ColorScheme.of(context).primary,
                ),
                onPressed: () {
                  _picker.pickImage(source: ImageSource.gallery).then((
                    value,
                  ) async {
                    if (value == null) return;
                    final newValue = await File(value.path).readAsBytes();
                    if (listEquals(newValue, widget.image)) return;

                    widget.onImageChanged(newValue);
                  });
                },
                child: AnimatedSwitcher(
                  duration: widget.duration,
                  child: widget.image == null
                      ? SizedBox.expand(
                          key: const ValueKey(
                            'assets/icons/upload_photo_icon.svg',
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/upload_photo_icon.svg',
                            colorFilter: ColorFilter.mode(
                              ColorScheme.of(context).onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                      : SizedBox.expand(
                          key: _imageKey,
                          child: Image.memory(
                            widget.image!,
                            errorBuilder: (context, error, stackTrace) =>
                                Text(
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
              );

              if (widget.aspectRatio != null) {
                child = AspectRatio(
                  aspectRatio: widget.aspectRatio!,
                  child: child,
                );
              }

              return child;
            },
          ),
        ),
        AnimatedBuilder(
          animation: mainAnimationController,
          builder: (_, _) => Visibility(
            visible: mainAnimationController.value != 0,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Transform.rotate(
                angle: pi * mainAnimationController.value,
                child: Transform.scale(
                  scale: mainAnimationController.value,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      splashColor: ColorScheme.of(context).primary.withAlpha(60),
                      hoverColor: ColorScheme.of(context).primary.withAlpha(30),
                      highlightColor: ColorScheme.of(context).primary.withAlpha(30),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(9999),
                      ),
                      onTap: () {
                        if (widget.image == null) return;
                        widget.onImageChanged(null);
                      },
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(
                              color:
                                  Color.lerp(
                                    ColorScheme.of(context).onSurfaceVariant,
                                    ColorScheme.of(context).primary,
                                    mainAnimationController.value,
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
        ),
      ],
    );
  }
}
