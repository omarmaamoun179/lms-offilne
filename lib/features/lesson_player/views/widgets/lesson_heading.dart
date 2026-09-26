import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../cubit/lesson_player_cubit.dart';
import '../../cubit/lesson_player_state.dart';

class LessonHeading extends StatelessWidget {
  const LessonHeading({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<LessonPlayerCubit, LessonPlayerState>(
      buildWhen: (previous, current) =>
          previous.lesson != current.lesson ||
          previous.status != current.status ||
          previous.completed != current.completed,
      builder: (context, state) {
        final lesson = state.lesson!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'lesson_of'.tr(
                args: ['${state.lessonNumber}', '${state.lessonCount}'],
              ),
              style: AppStrings.w400(12).c(p.accent700),
            ),
            Text(lesson.title, style: AppStrings.heading(28, 1.4).c(p.text)),
            if (state.status == PlayerStatus.failed)
              Text(
                lesson.duration.clock,
                style: AppStrings.w400(12.5).c(p.neutral700).tabular,
              )
            else if (state.completed)
              _buildDoneBadge(context)
            else
              Text(
                'completion_hint'.tr(),
                style: AppStrings.w400(12.5).c(p.neutral700),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDoneBadge(BuildContext context) {
    final p = context.palette;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: p.accent),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(AppIcons.check, size: 13, color: p.accent800, strokeWidth: 2),
          const SizedBox(width: 6),
          Text(
            'lesson_done'.tr(),
            style: AppStrings.w400(12.5).c(p.accent800),
          ),
        ],
      ),
    );
  }
}
