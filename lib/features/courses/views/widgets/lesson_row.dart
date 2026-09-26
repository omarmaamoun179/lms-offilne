import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/utils/percent_format.dart';
import '../../models/course.dart';
import '../../models/course_progress.dart';
import 'lesson_status_icon.dart';

class LessonRow extends StatelessWidget {
  final CourseProgress course;
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonRow({
    super.key,
    required this.course,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final status = course.statusOf(lesson);
    final highlighted = status == LessonStatus.inProgress;
    final muted = status == LessonStatus.locked;
    final watched = course.watchedFraction(lesson);

    return Column(
      children: [
        Material(
          color: highlighted ? p.accent100 : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  LessonStatusIcon(status: status, watched: watched),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: AppStrings.w400(15.5)
                              .c(muted ? p.neutral700 : p.text),
                        ),
                        Text(
                          _subtitle(status, watched),
                          style: AppStrings.w400(12)
                              .c(highlighted ? p.accent700 : p.neutral700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    lesson.duration.clock,
                    style: AppStrings.w400(13).c(p.neutral700).tabular,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: highlighted ? 0 : 10),
          child: Divider(height: 1, thickness: 1, color: p.divider),
        ),
      ],
    );
  }

  String _subtitle(LessonStatus status, double watched) {
    switch (status) {
      case LessonStatus.completed:
        return 'lesson_completed'.tr();
      case LessonStatus.inProgress:
        return 'lesson_in_progress'.tr(args: [(watched * 100).percentLabel]);
      case LessonStatus.available:
        return 'lesson_not_started'.tr();
      case LessonStatus.locked:
        final blocker = course.current;
        final opensNext =
            blocker != null && course.lessonAfter(blocker)?.id == lesson.id;
        return opensNext
            ? 'lesson_opens_after'.tr(args: [blocker.title])
            : 'lesson_locked'.tr();
    }
  }
}
