import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

class SeekBar extends StatefulWidget {
  final double value;
  final double marker;
  final double thumbSize;
  final ValueChanged<double> onSeek;

  const SeekBar({
    super.key,
    required this.value,
    required this.onSeek,
    this.marker = .9,
    this.thumbSize = 13,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragging;

  double _fractionAt(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    return Directionality.of(context) == TextDirection.rtl
        ? 1 - fraction
        : fraction;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) =>
              widget.onSeek(_fractionAt(details.localPosition.dx, width)),
          onHorizontalDragStart: (details) => setState(
            () => _dragging = _fractionAt(details.localPosition.dx, width),
          ),
          onHorizontalDragUpdate: (details) => setState(
            () => _dragging = _fractionAt(details.localPosition.dx, width),
          ),
          onHorizontalDragEnd: (_) {
            final target = _dragging;
            setState(() => _dragging = null);
            if (target != null) widget.onSeek(target);
          },
          child: SizedBox(
            height: 24,
            width: width,
            child: CustomPaint(
              painter: _SeekPainter(
                value: _dragging ?? widget.value,
                marker: widget.marker,
                thumbSize: widget.thumbSize,
                rtl: Directionality.of(context) == TextDirection.rtl,
                track: p.onVideo.withValues(alpha: .28),
                fill: p.seekFill,
                thumb: p.seekThumb,
                tick: p.onVideo.withValues(alpha: .8),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SeekPainter extends CustomPainter {
  final double value;
  final double marker;
  final double thumbSize;
  final bool rtl;
  final Color track;
  final Color fill;
  final Color thumb;
  final Color tick;

  _SeekPainter({
    required this.value,
    required this.marker,
    required this.thumbSize,
    required this.rtl,
    required this.track,
    required this.fill,
    required this.thumb,
    required this.tick,
  });

  double _x(double fraction, double width) =>
      rtl ? width * (1 - fraction) : width * fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final bar = Rect.fromLTWH(0, mid - 1.5, size.width, 3);
    canvas.drawRect(bar, Paint()..color = track);

    final head = _x(value.clamp(0.0, 1.0), size.width);
    canvas.drawRect(
      rtl
          ? Rect.fromLTRB(head, bar.top, size.width, bar.bottom)
          : Rect.fromLTRB(0, bar.top, head, bar.bottom),
      Paint()..color = fill,
    );

    final markerX = _x(marker, size.width);
    canvas.drawRect(
      Rect.fromLTWH(markerX - .5, mid - 4.5, 1, 9),
      Paint()..color = tick,
    );

    canvas.drawCircle(Offset(head, mid), thumbSize / 2, Paint()..color = thumb);
  }

  @override
  bool shouldRepaint(_SeekPainter old) =>
      old.value != value ||
      old.marker != marker ||
      old.thumbSize != thumbSize ||
      old.rtl != rtl ||
      old.track != track ||
      old.fill != fill ||
      old.thumb != thumb ||
      old.tick != tick;
}
