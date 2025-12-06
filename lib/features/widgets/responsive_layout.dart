import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
    this.columnCrossAxisAlignment = CrossAxisAlignment.center,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    required this.widths,
    required this.children,
  }) : assert(widths.length == children.length);

  final List<double> widths;
  final List<Widget> children;
  final double verticalSpacing;
  final double horizontalSpacing;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.length == 1) return children.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final List<List<({double width, Widget widget})>> layout = [[]];

        int verticalIndex = 0;
        double passedWidth = 0;

        for (var i = 0; i < children.length; i++) {
          passedWidth +=
              widths[i] + (i < children.length ? horizontalSpacing : 0);

          if (passedWidth > width) {
            passedWidth = widths[i];
            verticalIndex++;
            layout.add([]);
          }

          layout[verticalIndex].add(
            (width: widths[i], widget: children[i]),
          );
        }

        if (verticalIndex == 0) {
          return row(layout[0]);
        } else {
          return Column(
            spacing: verticalSpacing,
            crossAxisAlignment: columnCrossAxisAlignment,
            children: [
              for (int i = 0; i <= verticalIndex; i++) row(layout[i]),
            ],
          );
        }
      },
    );
  }

  Widget row(List<({double width, Widget widget})> children) {
    if (children.length == 1) return children.first.widget;

    return Row(
      spacing: horizontalSpacing,
      crossAxisAlignment: rowCrossAxisAlignment,
      children: children
          .map(
            (e) => Expanded(
              flex: e.width.toInt(),
              child: e.widget,
            ),
          )
          .toList(),
    );
  }
}
