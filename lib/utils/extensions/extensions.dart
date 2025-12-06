import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  Duration toDuration() => Duration(hours: hour, minutes: minute);
}

extension DurationExtension on Duration {
  TimeOfDay toTimeOfDay() =>
      TimeOfDay(hour: inHours.remainder(24), minute: inMinutes.remainder(60));

  int get hour => inHours.remainder(24);
  int get minute => inMinutes.remainder(60);
  int get second => inSeconds.remainder(60);
  DayPeriod get period => hour > 12 ? DayPeriod.pm : DayPeriod.am;
}

extension NumExtension on num {
  num map(num srcMin, num srcMax, num targetMin, num targetMax) {
    assert(srcMin < srcMax);
    assert(targetMin < targetMax);

    final srcLength = srcMax - srcMin;
    final targetLength = targetMax - targetMin;

    final srcPos = (this - srcMin) / srcLength;

    return targetLength * srcPos + targetMin;
  }

  num loop(num min, num length) {
    if (this >= min) {
      final int count = (this - min) ~/ length;
      return (this - min) - count * length + min;
    } else {
      return (length - abs().loop(min, length));
    }
  }
}
