import 'package:flutter/material.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/utils/functions.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:todo/utils/extensions/extensions.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({
    super.key,
    this.seconds = true,
    this.minutes = true,
    this.hours = true,
    this.isDuration = false,
    this.infiniteHour = false,
    this.amPm = true,
    this.onChanged,
    this.constraints,
    this.textStyle,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.initDuration,
  }) : assert(
         (infiniteHour && !amPm) || !infiniteHour,
       ); // if inifniteHour is true, then amPm must be false

  final bool seconds;
  final bool infiniteHour;
  final bool minutes;
  final bool hours;
  final bool isDuration;
  final bool amPm;
  final BoxConstraints? constraints;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final void Function(Duration duration)? onChanged;
  final TextStyle? textStyle;
  final Duration? initDuration;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late final now = widget.initDuration ?? nowInDuration();
  late final _hoursController = WheelPickerController(
    itemCount: widget.infiniteHour
        ? 1000
        : widget.amPm
        ? 12
        : 24,
    initialIndex: widget.amPm ? now.hour % 12 : now.hour,
  );
  late final _minutesController = WheelPickerController(
    itemCount: 60,
    initialIndex: now.minute,
    mounts: [_hoursController],
  );
  late final _secondsController = WheelPickerController(
    itemCount: 60,
    initialIndex: now.second,
    mounts: [_minutesController],
  );
  late final _amPmController = WheelPickerController(
    itemCount: 2,
    initialIndex: (now.period == DayPeriod.am) ? 0 : 1,
  );

  @override
  void didUpdateWidget(covariant TimePicker oldWidget) {
    if (widget.amPm != oldWidget.amPm) {
      _hoursController.itemCount = widget.amPm ? 12 : 24;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        widget.textStyle ??
        const TextStyle(
          fontSize: 26.0,
          height: 1.5,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.24,
        );

    final wheelStyle = WheelPickerStyle(
      itemExtent: textStyle.fontSize! * textStyle.height!, // Text height
      squeeze: 1.3,
      diameterRatio: 1,
      surroundingOpacity: .25,
      // magnification: 1,
    );

    var timeWheels = <Widget>[
      if (widget.hours) ...{
        wheelBuilder(
          _hoursController,
          false,
          textStyle,
          wheelStyle,
        ),
        if (widget.seconds || widget.minutes) Text(":", style: textStyle),
      },
      if (widget.minutes) ...{
        wheelBuilder(_minutesController, true, textStyle, wheelStyle),
        if (widget.seconds) Text(":", style: textStyle),
      },
      if (widget.seconds)
        wheelBuilder(_secondsController, true, textStyle, wheelStyle),
    ];

    if ((Directionality.maybeOf(context) ?? TextDirection.ltr) ==
        TextDirection.rtl) {
      timeWheels = timeWheels.reversed.toList();
    }

    final amPmWheel = Expanded(
      child: WheelPicker(
        onIndexChanged: onIndexChanged,
        controller: _amPmController,
        builder: (context, index) {
          return Text(["ق.ظ", "ب.ظ"][index], style: textStyle);
        },
        looping: false,
        style: wheelStyle.copyWith(
          shiftAnimationStyle: const WheelShiftAnimationStyle(
            duration: Duration(seconds: 1),
            curve: Curves.bounceOut,
          ),
        ),
      ),
    );

    return ConstrainedBox(
      constraints:
          widget.constraints ??
          BoxConstraints(
            minWidth: widget.minWidth ?? 240,
            minHeight: widget.minHeight ?? 200,
            maxWidth: widget.maxWidth ?? 300,
            maxHeight: widget.maxHeight ?? 200,
          ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _centerBar(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: !widget.amPm
                  ? timeWheels
                  : [
                      ...timeWheels,
                      const SizedBox(width: 6.0),
                      amPmWheel,
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget itemBuilder(
    BuildContext context,
    int index,
    TextStyle textStyle,
    bool isHour,
  ) {
    if (widget.amPm && isHour) {
      return Text(
        convertDigits("${index + 1}".padLeft(2, '0')),
        style: textStyle,
      );
    }
    return Text(convertDigits("$index".padLeft(2, '0')), style: textStyle);
  }

  Widget wheelBuilder(
    WheelPickerController controller,
    bool looping,
    TextStyle textStyle,
    WheelPickerStyle wheelStyle,
  ) {
    return Expanded(
      child: WheelPicker(
        builder: (context, index) => itemBuilder(
          context,
          index,
          textStyle,
          controller == _hoursController,
        ),
        controller: controller,
        looping: looping,
        style: wheelStyle,
        selectedIndexColor: CustomColors.green,
        onIndexChanged: onIndexChanged,
      ),
    );
  }

  void onIndexChanged(int index, WheelPickerInteractionType interactionType) {
    if (widget.onChanged == null) return;
    final hours = !widget.hours
        ? 0
        : widget.amPm
        ? _amPmController.selected == 0
              ? (_hoursController.selected + 1).remainder(12)
              : (_hoursController.selected + 1).remainder(12) + 12
        : _hoursController.selected;

    widget.onChanged!(
      Duration(
        seconds: !widget.seconds ? 0 : _secondsController.selected,
        minutes: !widget.minutes ? 0 : _minutesController.selected,
        hours: hours,
      ),
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Widget _centerBar(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 38.0,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ColorScheme.of(context).primaryContainer,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
