import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';
import '../utils/app_strings.dart';
import 'app_icon.dart';

void showAppToast(BuildContext context, String message, {bool isError = false}) {
  final p = context.palette;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.text,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        content: Row(
          children: [
            AppIcon(
              isError ? AppIcons.alert : AppIcons.check,
              size: 16,
              color: p.accent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: AppStrings.w400(13.5, 1.5).c(p.bg)),
            ),
          ],
        ),
      ),
    );
}
