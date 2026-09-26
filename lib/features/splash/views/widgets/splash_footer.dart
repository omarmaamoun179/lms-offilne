import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/progress_line.dart';

class SplashFooter extends StatelessWidget {
  final Animation<double> intro;
  final Animation<double> progress;

  const SplashFooter({
    super.key,
    required this.intro,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AnimatedBuilder(
      animation: Listenable.merge([intro, progress]),
      builder: (context, _) => Opacity(
        opacity: Curves.easeOut.transform(
          const Interval(.5, 1).transform(intro.value),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'courses_loading'.tr(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: 120,
                  child: ProgressLine(
                    value: progress.value,
                    color: p.onBrand,
                    trackColor: p.onBrand.withValues(alpha: .25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'brand_latin'.tr(),
              style: AppStrings.heading(13).c(p.onBrand).spaced(2.6),
            ),
          ],
        ),
      ),
    );
  }
}
