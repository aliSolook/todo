import 'dart:math';

import 'package:flutter/material.dart';

class CloseIconWidget extends StatelessWidget {
  const CloseIconWidget({
    super.key,
    this.color = Colors.black,
    this.size = 25,
    this.thickness = 2,
    this.padding = 4,
  });

  final Color color;
  final double size;
  final double thickness;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: pi * .25,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(99),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: thickness,
                  child: ColoredBox(
                    color: color,
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: -pi * .25,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(99),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: thickness,
                  child: ColoredBox(
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
