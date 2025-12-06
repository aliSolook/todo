import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo/constants/durations.dart';
import 'package:todo/features/custom_color/custom_color.dart';

class ColorSelectorDialog extends StatelessWidget {
  const ColorSelectorDialog({super.key});

  CustomColorAddCubit _bloc(BuildContext context) => BlocProvider.of(context);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
        ),
        color: ColorScheme.of(context).surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: BlocConsumer<CustomColorAddCubit, CustomColorAddState>(
            listener: (context, state) {
              if (state.submitState.isSuccess) {
                Navigator.pop(context, state.submitState.value);
              } else if (state.submitState.isFailure) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('خطا'),
                    content: Text(state.submitState.error),
                  ),
                );
              }
            },
            builder: (context, state) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox.square(
                      dimension: 200,
                      child: ColorPickerArea(
                        state.color,
                        _bloc(context).colorChanged,
                        PaletteType.hueWheel,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 250,
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: ShapeDecoration(
                              color: state.color.toColor(),
                              shape: const CircleBorder(),
                            ),
                            child: const SizedBox.square(dimension: 50),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: ColorPickerSlider(
                                    TrackType.value,
                                    state.color,
                                    _bloc(context).colorChanged,
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: ColorPickerSlider(
                                    TrackType.saturation,
                                    state.color,
                                    _bloc(context).colorChanged,
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: ColorPickerSlider(
                                    TrackType.hue,
                                    state.color,
                                    _bloc(context).colorChanged,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 250,
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocBuilder<
                              CustomColorAddCubit,
                              CustomColorAddState
                            >(
                              builder: (context, state) => FilledButton(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(100, 40),
                                ),
                                onPressed: state.submitState.isInProgress ? null : _bloc(context).submit,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedOpacity(
                                      duration: animationDuration,
                                      opacity: state.submitState.isInProgress ? 1 : 0,
                                      child: const SizedBox.square(
                                        dimension: 20,
                                        child:
                                            CircularProgressIndicator(),
                                      ),
                                    ),
                                    AnimatedOpacity(
                                      duration: animationDuration,
                                      opacity: state.submitState.isInProgress ? 0 : 1,
                                      child: const Text('انتخاب'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('لغو'),
                            ),
                            const Spacer(flex: 3),
                          ],
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
    );
  }
}
