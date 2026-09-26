import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/percent_format.dart';
import '../../../../core/widgets/progress_line.dart';
import '../../models/course_progress.dart';
import 'course_thumbnail.dart';

class CourseDetailsHeader extends StatelessWidget {
  final CourseProgress course;

  const CourseDetailsHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final info = course.course;
    final parts = [
      info.instructor,
      if (info.hasLessons) ...[
        'sections_count'.plural(info.sections.length),
        'lessons_count'.plural(course.lessonCount),
      ] else
        'no_lessons_yet'.tr(),
    ];

    return Row(
      children: [
        CourseThumbnail(asset: info.thumbnail, size: 72),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.title, style: AppStrings.heading(27, 1.4).c(p.text)),
              Text(
                parts.join(' · '),
                style: AppStrings.w400(13).c(p.neutral700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CourseProgressSummary extends StatelessWidget {
  final CourseProgress course;

  const CourseProgressSummary({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = AppStrings.w400(12.5);

    return Row(
      children: [
        Text(
          'completed_of'.tr(
            args: ['${course.completedCount}', '${course.lessonCount}'],
          ),
          style: style.c(p.neutral700),
        ),
        const SizedBox(width: 10),
        Expanded(child: ProgressLine(value: course.fraction)),
        const SizedBox(width: 10),
        Text(
          course.percent.percentLabel,
          style: style.c(p.accent700).tabular,
        ),
      ],
    );
  }
}
