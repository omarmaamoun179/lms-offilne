import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../models/course.dart';

class LockedLessonSheet extends StatelessWidget {
  final Lesson locked;
  final Lesson blocker;
  final Duration resumeAt;

  const LockedLessonSheet({
    super.key,
    required this.locked,
    required this.blocker,
    this.resumeAt = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final action = resumeAt > Duration.zero
        ? 'locked_sheet_resume'.tr(args: [blocker.title, resumeAt.clock])
        : 'locked_sheet_start'.tr(args: [blocker.title]);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            const SizedBox(height: 22),
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: p.accent),
              ),
              child: AppIcon(
                AppIcons.lock,
                size: 22,
                color: p.accent700,
                strokeWidth: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'locked_sheet_title'.tr(),
              textAlign: TextAlign.center,
              style: AppStrings.heading(25, 1.4).c(p.text),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'locked_sheet_body'.tr(args: [blocker.title, locked.title]),
                textAlign: TextAlign.center,
                style: AppStrings.w400(14, 1.85).c(p.neutral800),
              ),
            ),
            const SizedBox(height: 22),
            AppButton(
              label: action,
              icon: AppIcons.play,
              expand: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'ok'.tr(),
              variant: AppButtonVariant.plain,
              height: 44,
              fontSize: 14.5,
              expand: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
