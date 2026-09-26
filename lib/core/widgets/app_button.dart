import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';
import '../utils/app_strings.dart';
import 'app_icon.dart';

enum AppButtonVariant { primary, secondary, plain }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppIconData? icon;
  final double iconSize;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.iconSize = 14,
    this.height = 48,
    this.fontSize = 15,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(4);
    final (border, foreground) = switch (variant) {
      AppButtonVariant.primary => (p.accent, p.accent800),
      AppButtonVariant.secondary => (p.border, p.text),
      AppButtonVariant.plain => (null, p.neutral800),
    };

    return Opacity(
      opacity: onPressed == null ? .45 : 1,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            height: height,
            width: expand ? double.infinity : null,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: border == null ? null : Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  AppIcon(
                    icon!,
                    size: iconSize,
                    color: foreground,
                    strokeWidth: 1.7,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStrings.w400(fontSize, 1.2).c(foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
