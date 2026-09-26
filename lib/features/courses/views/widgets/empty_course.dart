import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';

class EmptyCourse extends StatelessWidget {
  const EmptyCourse({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      padding: const EdgeInsets.only(bottom: 80),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.palette.divider)),
      ),
      child: EmptyState(
        icon: AppIcons.book,
        title: 'empty_course_title'.tr(),
        message: 'empty_course_body'.tr(),
        action: AppButton(
          label: 'back_to_courses'.tr(),
          height: 44,
          fontSize: 14.5,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          onPressed: context.goBack,
        ),
      ),
    );
  }
}
