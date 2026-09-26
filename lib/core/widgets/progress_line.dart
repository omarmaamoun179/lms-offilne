import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class ProgressLine extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? trackColor;
  final double height;

  const ProgressLine({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
    this.height = 2,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: trackColor ?? p.neutral300,
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: value.clamp(0.0, 1.0),
          heightFactor: 1,
          child: ColoredBox(color: color ?? p.accent),
        ),
      ),
    );
  }
}
