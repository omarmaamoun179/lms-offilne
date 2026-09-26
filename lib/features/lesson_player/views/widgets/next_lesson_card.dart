import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../view_models/lesson_player_state.dart';
import '../../view_models/lesson_player_view_model.dart';

class NextLessonCard extends StatelessWidget {
  const NextLessonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonPlayerViewModel, LessonPlayerState>(
      buildWhen: (previous, current) =>
          previous.course != current.course ||
          previous.lesson != current.lesson ||
          previous.justCompleted != current.justCompleted,
      builder: (context, state) {
        final next = state.nextLesson;
        if (next == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: _buildCard(context, state),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, LessonPlayerState state) {
    final p = context.palette;
    final next = state.nextLesson!;
    final open = state.nextUnlocked;
    final radius = BorderRadius.circular(4);
    final subtitle = open
        ? [
            ?state.course!.sectionOf(next)?.title,
            next.duration.clock,
            if (state.justCompleted) 'unlocked_now'.tr(),
          ].join(' · ')
        : 'next_locked_hint'.tr();

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        onTap: open
            ? () => context.replaceLesson(state.course!.course.id, next.id)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: open ? p.accent : p.border),
          ),
          child: Row(
            children: [
              open
                  ? AppIcon(AppIcons.play, size: 16, color: p.accent)
                  : AppIcon(
                      AppIcons.lock,
                      size: 16,
                      color: p.neutral700,
                      strokeWidth: 1.7,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'next_lesson'.tr(args: [next.title]),
                      style: AppStrings.w400(14.5)
                          .c(open ? p.text : p.neutral700),
                    ),
                    Text(
                      subtitle,
                      style: AppStrings.w400(12).c(p.neutral700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppIcon(
                AppIcons.forward,
                color: open ? p.accent : p.neutral700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
