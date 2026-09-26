import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/di_exports.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/app_strings.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_heading.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import 'widgets/continue_card.dart';
import 'widgets/course_search_field.dart';
import 'widgets/course_tile.dart';
import 'widgets/courses_header.dart';
import 'widgets/courses_skeleton.dart';
import 'widgets/search_no_results.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(context.locale.languageCode),
      create: (_) => sl<CoursesCubit>()..load(),
      child: const _CoursesView(),
    );
  }
}

class _CoursesView extends StatefulWidget {
  const _CoursesView();

  @override
  State<_CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<_CoursesView> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onSearchFocus);
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchFocus() {
    if (_searchFocus.hasFocus) context.read<CoursesCubit>().startSearch();
  }

  void _cancelSearch() {
    _search.clear();
    _searchFocus.unfocus();
    context.read<CoursesCubit>().cancelSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<CoursesCubit, CoursesState>(
          listenWhen: (previous, current) =>
              current.status == CoursesStatus.loaded &&
              current.errorMessage != null,
          listener: (context, state) =>
              showAppToast(context, state.errorMessage!, isError: true),
          builder: (context, state) => switch (state.status) {
            CoursesStatus.loaded => _buildLoaded(context, state),
            CoursesStatus.error => ErrorView(
                message: state.errorMessage ?? '',
                onRetry: () => context.read<CoursesCubit>().load(),
              ),
            _ => const CoursesSkeleton(),
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, CoursesState state) {
    final continueWatching = state.continueWatching;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (state.searching)
          const CoursesTitle()
        else
          CoursesHeader(studentName: state.library!.studentName),
        const SizedBox(height: 20),
        CourseSearchField(
          controller: _search,
          focusNode: _searchFocus,
          searching: state.searching,
          onChanged: context.read<CoursesCubit>().search,
          onCancel: _cancelSearch,
        ),
        if (continueWatching != null) ...[
          const SizedBox(height: 20),
          ContinueCard(
            item: continueWatching,
            onTap: () => context.openLesson(
              continueWatching.course.course.id,
              continueWatching.lesson.id,
            ),
          ),
        ],
        if (state.searching && state.hasQuery)
          ..._buildResults(context, state)
        else
          ..._buildAll(context, state),
      ],
    );
  }

  List<Widget> _buildAll(BuildContext context, CoursesState state) {
    final p = context.palette;

    return [
      const SizedBox(height: 24),
      SectionHeading(
        title: 'all_courses'.tr(),
        trailing: Text(
          'courses_count'.plural(state.courses.length),
          style: AppStrings.w400(12.5).c(p.neutral700),
        ),
      ),
      const SizedBox(height: 4),
      ..._buildTiles(context, state),
    ];
  }

  List<Widget> _buildResults(BuildContext context, CoursesState state) {
    final p = context.palette;
    final results = state.visibleCourses;

    return [
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.divider)),
        ),
        child: Text(
          'search_results'.plural(
            results.length,
            name: 'n',
            namedArgs: {'q': state.query.trim()},
          ),
          style: AppStrings.w400(12.5).c(p.neutral700),
        ),
      ),
      if (results.isEmpty) ...[
        const SizedBox(height: 24),
        const SearchNoResults(),
      ] else
        ..._buildTiles(context, state),
    ];
  }

  List<Widget> _buildTiles(BuildContext context, CoursesState state) => [
        for (final course in state.visibleCourses)
          CourseTile(
            course: course,
            query: state.searching ? state.query : '',
            onTap: () {
              _searchFocus.unfocus();
              context.openCourse(course.course.id);
            },
          ),
      ];
}
