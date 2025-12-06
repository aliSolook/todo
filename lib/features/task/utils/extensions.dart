import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

extension JalaliRangeExtension on JalaliRange {
  bool inRange(Jalali other, [bool inclusive = true]) =>
      inclusive ? other >= start && other <= end : other > start && other < end;
  bool get isEmpty => start == end;
}

extension JalaliExtension on Jalali {
  Jalali get withoutTime => Jalali(year, month, day);
  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  Jalali addDuration(Duration duration) => Jalali.fromMillisecondsSinceEpoch(
    millisecondsSinceEpoch + duration.inMilliseconds,
  );
}
