import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/custom_color/custom_color.dart';

Future<CustomColorWrapper?> showColorAdd(BuildContext context, [Color? defaultColor]) {
  return showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider<CustomColorAddCubit>(
        create: (context) => CustomColorAddCubit(
          CustomColorAddState.init(
            color: defaultColor == null
                ? null
                : HSVColor.fromColor(defaultColor),
          ),
        ),
        child: const ColorSelectorDialog(),
      ),
    ),
  );
}
