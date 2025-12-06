import 'package:flutter/material.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/widgets/widgets.dart';

class TimeLine extends StatelessWidget {
  const TimeLine({
    super.key,
    required this.children,
    required this.selectedIndex,
    this.onChanged,
  });

  final List<Widget> children;
  final int selectedIndex;
  final void Function(int index)? onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedLineSelector(
      animationDuration: animationDuration,
      selectedIndex: selectedIndex,
      childrenSpacing: 20,
      trackColor: CustomColors.lightGreen,
      trackThickness: 2,
      thumColor: CustomColors.green,
      thumRadius: 5,
      onSelectionChanged: onChanged,
      children: List.generate(
        children.length,
        (i) => FilledButton(
          style: FilledButton.styleFrom(
            shape: const SquircleBorder(strength: .9),
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(3),
            backgroundColor: Colors.transparent,
            elevation: 0,
            overlayColor: CustomColors.green,
          ),
          onPressed: () {
            if (i == selectedIndex) return;
            onChanged?.call(i);
          },
          child: AnimatedDefaultTextStyle(
            key: ValueKey('time_line_child_#$i'),
            duration: animationDuration,
            style: TextStyle(
              inherit: true,
              fontWeight: FontWeight.bold,
              fontFamily: TextTheme.of(
                context,
              ).titleMedium?.fontFamily,
              fontSize: 16,
              color: i == selectedIndex
                  ? CustomColors.black
                  : CustomColors.grey,
              letterSpacing: -0.24,
            ),
            child: children[i],
          ),
        ),
      ),
    );
  }
}
