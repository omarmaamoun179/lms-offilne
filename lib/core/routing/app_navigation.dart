import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

extension AppNavigation on BuildContext {
  void openCourse(String courseId) => push(AppRoutes.course(courseId));

  void openLesson(String courseId, String lessonId) =>
      push(AppRoutes.lesson(courseId, lessonId));

  void replaceLesson(String courseId, String lessonId) =>
      pushReplacement(AppRoutes.lesson(courseId, lessonId));

  void goBack() => canPop() ? pop() : go(AppRoutes.courses);
}
