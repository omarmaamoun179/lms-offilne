import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/dashed_border.dart';

class SearchNoResults extends StatelessWidget {
  const SearchNoResults({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return DashedBorder(
      color: p.border,
      radius: 7,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Text(
              'search_empty_title'.tr(),
              textAlign: TextAlign.center,
              style: AppStrings.heading(20).c(p.text),
            ),
            const SizedBox(height: 8),
            Text(
              'search_empty_body'.tr(),
              textAlign: TextAlign.center,
              style: AppStrings.w400(13, 1.7).c(p.neutral700),
            ),
          ],
        ),
      ),
    );
  }
}
