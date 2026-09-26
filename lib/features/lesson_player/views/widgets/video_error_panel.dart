import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';

class VideoErrorPanel extends StatelessWidget {
  const VideoErrorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: p.video,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              AppIcons.alert,
              size: 28,
              color: p.seekFill,
              strokeWidth: 1.5,
            ),
            const SizedBox(height: 8),
            Text(
              'video_failed_title'.tr(),
              textAlign: TextAlign.center,
              style: AppStrings.heading(21).c(p.onVideo),
            ),
            const SizedBox(height: 8),
            Text(
              'video_failed_body'.tr(),
              textAlign: TextAlign.center,
              style: AppStrings.w400(12.5, 1.7).c(p.onVideoMuted),
            ),
          ],
        ),
      ),
    );
  }
}
