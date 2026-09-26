import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/courses/views/course_details_page.dart';
import '../../features/courses/views/courses_page.dart';
import '../../features/lesson_player/views/lesson_player_page.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

String _param(GoRouterState state, String name) =>
    state.pathParameters[name] ?? '';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.courses,
  routes: [
    GoRoute(
      path: AppRoutes.root,
      redirect: (context, state) => AppRoutes.courses,
    ),
    GoRoute(
      path: AppRoutes.courses,
      builder: (context, state) => const CoursesPage(),
      routes: [
        GoRoute(
          path: AppRoutes.courseSegment,
          builder: (context, state) => CourseDetailsPage(
            courseId: _param(state, AppRoutes.courseIdParam),
          ),
          routes: [
            GoRoute(
              path: AppRoutes.lessonSegment,
              builder: (context, state) => LessonPlayerPage(
                courseId: _param(state, AppRoutes.courseIdParam),
                lessonId: _param(state, AppRoutes.lessonIdParam),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
