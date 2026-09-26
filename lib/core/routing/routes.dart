class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String courses = '/courses';

  static const String courseIdParam = 'courseId';
  static const String lessonIdParam = 'lessonId';

  static const String courseSegment = ':$courseIdParam';
  static const String lessonSegment = 'lessons/:$lessonIdParam';

  static String course(String courseId) => '$courses/$courseId';

  static String lesson(String courseId, String lessonId) =>
      '${course(courseId)}/lessons/$lessonId';
}
