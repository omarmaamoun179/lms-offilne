import 'dart:math' as math;

import 'package:flutter/material.dart';

class StripedBox extends StatelessWidget {
  final Color base;
  final Color line;
  final double gap;
  final double lineWidth;
  final Widget? child;

  const StripedBox({
    super.key,
    required this.base,
    required this.line,
    this.gap = 6,
    this.lineWidth = 1,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(base, line, gap, lineWidth),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color base;
  final Color line;
  final double gap;
  final double lineWidth;

  _StripePainter(this.base, this.line, this.gap, this.lineWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = base);

    final stroke = Paint()
      ..color = line
      ..strokeWidth = lineWidth;
    final step = (gap + lineWidth) * math.sqrt2;
    final offset = (gap + lineWidth / 2) * math.sqrt2;

    canvas.save();
    canvas.clipRect(bounds);
    for (var c = offset; c < size.width + size.height; c += step) {
      canvas.drawLine(Offset(c, 0), Offset(0, c), stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripePainter old) =>
      old.base != base ||
      old.line != line ||
      old.gap != gap ||
      old.lineWidth != lineWidth;
}
