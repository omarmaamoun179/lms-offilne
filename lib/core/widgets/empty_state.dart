import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';
import '../utils/app_strings.dart';
import 'app_icon.dart';

class EmptyState extends StatelessWidget {
  final AppIconData? icon;
  final String title;
  final String? message;
  final Widget? action;
  final double titleSize;
  final double maxWidth;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.action,
    this.titleSize = 24,
    this.maxWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          AppIcon(icon!, size: 40, color: p.accent, strokeWidth: 1.1),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppStrings.heading(titleSize).c(p.text),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: AppStrings.w400(14, 1.85).c(p.neutral700),
            ),
          ),
        ],
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    );
  }
}
