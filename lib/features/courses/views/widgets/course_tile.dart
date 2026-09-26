import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/percent_format.dart';
import '../../../../core/widgets/progress_line.dart';
import '../../models/course_progress.dart';
import 'course_thumbnail.dart';
import 'highlighted_text.dart';

class CourseTile extends StatelessWidget {
  final CourseProgress course;
  final String query;
  final VoidCallback onTap;

  const CourseTile({
    super.key,
    required this.course,
    required this.onTap,
    this.query = '',
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final info = course.course;
    final count = info.hasLessons
        ? 'lessons_count'.plural(course.lessonCount)
        : 'no_lessons_yet'.tr();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.divider)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: CourseThumbnail(asset: info.thumbnail),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightedText(
                      text: info.title,
                      query: query,
                      highlight: p.accent,
                      style: AppStrings.heading(20, 1.4).c(p.text),
                    ),
                    const SizedBox(height: 3),
                    HighlightedText(
                      text: info.instructor,
                      suffix: ' · $count',
                      query: query,
                      highlight: p.accent,
                      style: AppStrings.w400(13).c(p.neutral700),
                    ),
                    const Spacer(),
                    if (info.hasLessons) _buildProgress(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final p = context.palette;
    final started = course.percent > 0;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(child: ProgressLine(value: course.fraction)),
          const SizedBox(width: 10),
          Text(
            course.percent.percentLabel,
            style: AppStrings.w400(12.5, 1.3)
                .c(started ? p.accent700 : p.neutral700)
                .tabular,
          ),
        ],
      ),
    );
  }
}
