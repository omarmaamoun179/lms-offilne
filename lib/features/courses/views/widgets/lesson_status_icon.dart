import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/dashed_border.dart';
import '../../models/course_progress.dart';

class LessonStatusIcon extends StatelessWidget {
  final LessonStatus status;
  final double watched;

  const LessonStatusIcon({super.key, required this.status, this.watched = 0});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SizedBox.square(
      dimension: 32,
      child: switch (status) {
        LessonStatus.completed => _circle(
            p.accent,
            AppIcon(
              AppIcons.check,
              size: 15,
              color: p.accent700,
              strokeWidth: 2,
            ),
          ),
        LessonStatus.inProgress => CustomPaint(
            painter: _RingPainter(
              track: p.accent300,
              arc: p.accent,
              value: watched,
              rtl: Directionality.of(context) == TextDirection.rtl,
            ),
            child: Center(child: PlayGlyph(size: 12, color: p.accent700)),
          ),
        LessonStatus.available => _circle(
            p.accent,
            PlayGlyph(size: 12, color: p.accent700),
          ),
        LessonStatus.locked => DashedBorder(
            color: p.neutral500,
            circle: true,
            dash: 3,
            gap: 2.5,
            child: Center(
              child: AppIcon(
                AppIcons.lock,
                size: 14,
                color: p.neutral700,
                strokeWidth: 1.8,
              ),
            ),
          ),
      },
    );
  }

  Widget _circle(Color border, Widget child) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color track;
  final Color arc;
  final double value;
  final bool rtl;

  _RingPainter({
    required this.track,
    required this.arc,
    required this.value,
    required this.rtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - 1,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final sweep = 2 * math.pi * value.clamp(0.0, 1.0);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      rtl ? -sweep : sweep,
      false,
      Paint()
        ..color = arc
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.track != track ||
      old.arc != arc ||
      old.value != value ||
      old.rtl != rtl;
}
