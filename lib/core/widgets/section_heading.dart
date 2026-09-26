import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../utils/app_strings.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final double size;
  final Widget? trailing;
  final bool strong;
  final double gap;

  const SectionHeading({
    super.key,
    required this.title,
    this.size = 21,
    this.trailing,
    this.strong = false,
    this.gap = 8,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: EdgeInsets.only(bottom: gap),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: strong ? p.text : p.divider),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(title, style: AppStrings.heading(size).c(p.text)),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
