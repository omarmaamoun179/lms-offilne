import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';

class AppIcon extends StatelessWidget {
  final AppIconData icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = 18,
    this.color,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.string(
      icon.svg(strokeWidth),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ?? context.palette.text,
        BlendMode.srcIn,
      ),
    );

    final mirrored = icon.directional &&
        Directionality.of(context) == TextDirection.rtl;

    return mirrored ? Transform.flip(flipX: true, child: picture) : picture;
  }
}

class PlayGlyph extends StatelessWidget {
  final double size;
  final Color? color;

  const PlayGlyph({super.key, this.size = 18, this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-size / 9, 0),
      child: AppIcon(AppIcons.play, size: size, color: color),
    );
  }
}
