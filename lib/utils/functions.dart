import 'package:flutter/material.dart';
import 'package:todo/constants/constants.dart';

String durationFormatter(
  Duration duration, {
  bool hours = true,
  bool minutes = true,
  bool seconds = true,
}) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final formatedHours = twoDigits(duration.inHours);
  final formatedMinutes = twoDigits(duration.inMinutes.remainder(60));
  final formatedSeconds = twoDigits(duration.inSeconds.remainder(60));

  final output = [
    if (hours) formatedHours,
    if (minutes) formatedMinutes,
    if (seconds) formatedSeconds,
  ];

  return convertDigits(output.join(':'));
}

String convertDigits(Object input, {bool toPersian = true}) {
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  String output = input.toString();

  for (int i = 0; i < englishDigits.length; i++) {
    output = output.replaceAll(
      toPersian ? englishDigits[i] : persianDigits[i],
      toPersian ? persianDigits[i] : englishDigits[i],
    );
  }

  return output;
}

List<double> fractionSpliter({
  double min = 0,
  double max = 1,
  required List<double> positions,
  required double fraction,
}) {
  if (positions.isEmpty) throw 'positions cannot be empty';

  if (max <= min) throw 'the [max] must be bigger than the [min]';

  if (fraction > max) {
    throw 'the [fraction] must be smaller than or equal to [max]';
  }
  if (fraction < min) {
    throw 'the [fraction] must be bigger than ro equal to [min]';
  }

  for (var i = 1; i < positions.length; i++) {
    if (positions[i - 1] >= positions[i]) {
      throw 'the [positions] cannot be bigger than or equal to the previos one';
    }
  }

  if (positions.first <= min) {
    throw 'the first position must be bigger than [min]';
  }
  if (positions.last >= max) {
    throw 'the last position must be less than [max]';
  }

  final List<double> output;

  if (fraction > positions.last) {
    output = List.filled(positions.length + 1, 1, growable: false);

    double previos = positions[positions.length - 1];
    fraction -= previos;
    fraction /= max - previos;
    output.last = fraction;
  } else {
    output = List.filled(positions.length + 1, 0, growable: false);

    for (var i = 0; i < positions.length; i++) {
      if (fraction <= positions[i]) {
        double previos = i == 0 ? min : positions[i - 1];
        fraction -= previos;
        fraction /= positions[i] - previos;
        output[i] = fraction > 1 ? 1 : fraction;
        break;
      } else {
        output[i] = 1;
      }
    }
  }

  return output;
}

// BoxShadow elevationToBoxShadow(double elevation, {Color? shadowColor}) {
//   // Default shadow color if not provided
//   final Color defaultShadowColor = Colors.black.withAlpha(0.15 * 255 ~/ 1);

//   // Map elevation values to shadow properties
//   // These values are based on Material Design elevation guidelines
//   final double blurRadius;
//   final double spreadRadius;
//   final Offset offset;

//   if (elevation <= 0) {
//     // No shadow for elevation 0 or negative
//     return const BoxShadow(
//       color: Colors.transparent,
//       blurRadius: 0,
//       spreadRadius: 0,
//       offset: Offset.zero,
//     );
//   } else if (elevation <= 1) {
//     blurRadius = 3.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 1);
//   } else if (elevation <= 2) {
//     blurRadius = 6.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 3);
//   } else if (elevation <= 3) {
//     blurRadius = 8.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 3);
//   } else if (elevation <= 4) {
//     blurRadius = 10.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 4);
//   } else if (elevation <= 6) {
//     blurRadius = 15.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 6);
//   } else if (elevation <= 8) {
//     blurRadius = 18.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 8);
//   } else if (elevation <= 12) {
//     blurRadius = 22.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 12);
//   } else if (elevation <= 16) {
//     blurRadius = 26.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 16);
//   } else if (elevation <= 24) {
//     blurRadius = 32.0;
//     spreadRadius = 0.0;
//     offset = const Offset(0, 24);
//   } else {
//     // For elevations above 24, scale proportionally
//     blurRadius = elevation * 1.33;
//     spreadRadius = 0.0;
//     offset = Offset(0, elevation);
//   }

//   return BoxShadow(
//     color: shadowColor ?? defaultShadowColor,
//     blurRadius: blurRadius,
//     spreadRadius: spreadRadius,
//     offset: offset,
//   );
// }

Duration nowInDuration() {
  final now = DateTime.now();
  return Duration(
    hours: now.hour,
    minutes: now.minute,
    seconds: now.second,
  );
}

List<BoxShadow> categoryShadowBuilder(
  Color color, {
  double strength = 1,
  double opacityMultiplier = 2,
}) {
  return [
    BoxShadow(
      color: color.withAlpha(opacityMultiplier * 255 * .1 ~/ 1),
    ),
    BoxShadow(
      offset: const Offset(0, 3) * strength,
      blurRadius: 7 * strength,
      color: color.withAlpha(opacityMultiplier * 255 * .1 ~/ 1),
    ),
    BoxShadow(
      offset: const Offset(0, 12) * strength,
      blurRadius: 12 * strength,
      color: color.withAlpha(opacityMultiplier * 255 * .09 ~/ 1),
    ),
    BoxShadow(
      offset: const Offset(0, 27) * strength,
      blurRadius: 16 * strength,
      color: color.withAlpha(opacityMultiplier * 255 * .05 ~/ 1),
    ),
    BoxShadow(
      offset: const Offset(0, 48) * strength,
      blurRadius: 19 * strength,
      color: color.withAlpha(opacityMultiplier * 255 * .01 ~/ 1),
    ),
  ];
}

SnackBar snackbarBuilder(
  BuildContext context, {
  required Widget Function(BuildContext context, double value) builder,
  double? gap,
  Duration duration = const Duration(seconds: 4),
}) {
  return SnackBar(
    duration: duration,
    backgroundColor: ColorScheme.of(context).primary,
    content: TweenAnimationBuilder(
      duration: duration,
      tween: Tween<double>(begin: 1, end: 0),
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ColorScheme.of(context).onPrimary,
              fontFamily: TextTheme.of(
                context,
              ).bodyLarge?.fontFamily,
            ),
            child: builder(context, value),
          ),
          if (gap != null) SizedBox(height: gap),
          Align(
            heightFactor: 1,
            alignment: AlignmentDirectional.centerStart,
            child: LayoutBuilder(
              builder: (_, constraints) => SizedBox(
                height: 3,
                width: constraints.maxWidth * value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadiusDirectional.only(
                      topEnd: Radius.circular(999),
                      bottomEnd: Radius.circular(999),
                    ),
                    color: ColorScheme.of(context).primaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
