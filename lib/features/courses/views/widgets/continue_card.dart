import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/progress_line.dart';
import '../../models/course_progress.dart';

class ContinueCard extends StatelessWidget {
  final CourseLesson item;
  final VoidCallback onTap;

  const ContinueCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final course = item.course;
    final lesson = item.lesson;
    final radius = BorderRadius.circular(7);
    final meta = AppStrings.w400(12).c(p.neutral700).tabular;
    final place = 'lesson_of'.tr(
      args: ['${course.numberOf(lesson)}', '${course.lessonCount}'],
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: p.accent),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'continue_watching'.tr(),
                          style: AppStrings.w400(12).c(p.accent700),
                        ),
                        Text(
                          lesson.title,
                          style: AppStrings.heading(24, 1.45).c(p.text),
                        ),
                        Text(
                          '${course.course.title} · $place',
                          style: AppStrings.w400(12.5).c(p.neutral700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: p.accent),
                    ),
                    child: PlayGlyph(color: p.accent700),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ProgressLine(value: course.watchedFraction(lesson)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'stopped_at'.tr(args: [item.progress!.position.clock]),
                    style: meta,
                  ),
                  Text(lesson.duration.clock, style: meta),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
