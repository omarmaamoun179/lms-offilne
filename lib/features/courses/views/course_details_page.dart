import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/di_exports.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/app_strings.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/header_icon_button.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_heading.dart';
import '../models/course.dart';
import '../models/course_progress.dart';
import '../view_models/course_details_state.dart';
import '../view_models/course_details_view_model.dart';
import 'widgets/course_details_header.dart';
import 'widgets/empty_course.dart';
import 'widgets/lesson_row.dart';
import 'widgets/locked_lesson_sheet.dart';

class CourseDetailsPage extends StatelessWidget {
  final String courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey('${context.locale.languageCode}/$courseId'),
      create: (_) => sl<CourseDetailsViewModel>()..load(courseId),
      child: const _CourseDetailsView(),
    );
  }
}

class _CourseDetailsView extends StatelessWidget {
  const _CourseDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<CourseDetailsViewModel, CourseDetailsState>(
          listenWhen: (previous, current) =>
              current.status == CourseDetailsStatus.loaded &&
              current.errorMessage != null,
          listener: (context, state) =>
              showAppToast(context, state.errorMessage!, isError: true),
          builder: (context, state) => switch (state.status) {
            CourseDetailsStatus.loaded => _buildLoaded(context, state.course!),
            CourseDetailsStatus.error => _buildError(context, state),
            _ => const LoadingView(),
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, CourseProgress course) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverList.list(
            children: [
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppBackButton(),
              ),
              const SizedBox(height: 14),
              CourseDetailsHeader(course: course),
            ],
          ),
        ),
        if (course.course.hasLessons)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 40),
            sliver: SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CourseProgressSummary(course: course),
                ),
                for (final (index, section) in course.course.sections.indexed)
                  ..._buildSection(context, course, section, index + 1),
              ],
            ),
          )
        else
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyCourse(),
          ),
      ],
    );
  }

  List<Widget> _buildSection(
    BuildContext context,
    CourseProgress course,
    CourseSection section,
    int number,
  ) {
    final p = context.palette;
    final meta = '${'section_label'.tr(args: ['$number'])} · '
        '${section.duration.clock}';

    return [
      const SizedBox(height: 22),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SectionHeading(
          title: section.title,
          size: 20,
          strong: true,
          gap: 6,
          trailing: Text(meta, style: AppStrings.w400(12).c(p.neutral700)),
        ),
      ),
      for (final lesson in section.lessons)
        LessonRow(
          course: course,
          lesson: lesson,
          onTap: () => _openLesson(context, course, lesson),
        ),
    ];
  }

  Future<void> _openLesson(
    BuildContext context,
    CourseProgress course,
    Lesson lesson,
  ) async {
    final blocker = course.current;
    if (course.statusOf(lesson) != LessonStatus.locked || blocker == null) {
      context.openLesson(course.course.id, lesson.id);
      return;
    }

    final resume = await showAppSheet<bool>(
      context,
      builder: (_) => LockedLessonSheet(
        locked: lesson,
        blocker: blocker,
        resumeAt: course.progressOf(blocker)?.position ?? Duration.zero,
      ),
    );
    if (resume == true && context.mounted) {
      context.openLesson(course.course.id, blocker.id);
    }
  }

  Widget _buildError(BuildContext context, CourseDetailsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: AppBackButton(),
        ),
        Expanded(child: ErrorView(message: state.errorMessage ?? '')),
      ],
    );
  }
}
