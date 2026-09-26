import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/domain/failure.dart';
import 'package:lms_offline/core/utils/text_search.dart';
import 'package:lms_offline/features/courses/models/course.dart';
import 'package:lms_offline/features/courses/models/course_progress.dart';
import 'package:lms_offline/features/courses/models/lesson_progress.dart';
import 'package:lms_offline/features/courses/repositories/course_repository.dart';
import 'package:lms_offline/features/courses/cubit/courses_state.dart';
import 'package:lms_offline/features/courses/cubit/courses_cubit.dart';

class _FakeCourseRepository implements CourseRepository {
  Either<Failure, CourseLibrary> library;
  final StreamController<String> changes = StreamController.broadcast();

  _FakeCourseRepository(this.library);

  @override
  Stream<String> get progressChanges => changes.stream;

  @override
  Future<Either<Failure, CourseLibrary>> getLibrary() async => library;

  @override
  Future<Either<Failure, CourseProgress>> getCourse(String courseId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, CourseLesson>> getLesson(
    String courseId,
    String lessonId,
  ) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> saveProgress(
    String lessonId,
    LessonProgress progress,
  ) =>
      throw UnimplementedError();
}

Course _course(String id, String title, String instructor) => Course(
      id: id,
      title: title,
      instructor: instructor,
      sections: [
        CourseSection(
          id: '$id-s1',
          title: 'section',
          lessons: [
            Lesson(
              id: '$id-1',
              title: 'first',
              duration: const Duration(seconds: 100),
              video: 'assets/videos/$id/lesson1.mp4',
            ),
          ],
        ),
      ],
    );

CourseLibrary _library() => CourseLibrary(
      studentName: 'نورة',
      courses: [
        CourseProgress(
          _course('anatomy', 'مقدمة في التشريح', 'د. سارة العتيبي'),
          {
            'anatomy-1': LessonProgress(
              position: const Duration(seconds: 40),
              updatedAt: DateTime(2026, 9, 1),
            ),
          },
        ),
        CourseProgress(
          _course('physiology', 'أساسيات علم وظائف الأعضاء', 'د. خالد المنصور'),
          const {},
        ),
      ],
    );

void main() {
  late _FakeCourseRepository repository;
  late CoursesCubit cubit;

  setUp(() {
    repository = _FakeCourseRepository(Right(_library()));
    cubit = CoursesCubit(repository);
  });

  tearDown(() => cubit.close());

  test('load shows the library with the lesson to continue', () async {
    await cubit.load();

    expect(cubit.state.status, CoursesStatus.loaded);
    expect(cubit.state.courses, hasLength(2));
    expect(cubit.state.continueWatching?.lesson.id, 'anatomy-1');
  });

  test('a failed first load is an error carrying the message', () async {
    repository.library = const Left(CacheFailure(message: 'broken'));

    await cubit.load();

    expect(cubit.state.status, CoursesStatus.error);
    expect(cubit.state.errorMessage, 'broken');
  });

  test('search matches titles and instructors whatever the hamza', () async {
    await cubit.load();
    List<String> matches(String query) {
      cubit.search(query);
      return [
        for (final entry in cubit.state.visibleCourses) entry.course.id,
      ];
    }

    expect(matches('اساسيات'), ['physiology']);
    expect(matches('وظائف'), ['physiology']);
    expect(matches('سارة'), ['anatomy']);
    expect(matches('astronomy'), isEmpty);
    expect(matches('  '), ['anatomy', 'physiology']);
  });

  test('searching hides the continue card and cancelling brings it back',
      () async {
    await cubit.load();

    cubit.startSearch();
    final hidden = cubit.state.continueWatching;
    cubit.cancelSearch();

    expect(hidden, isNull);
    expect(cubit.state.query, isEmpty);
    expect(cubit.state.continueWatching, isNotNull);
  });

  test('a progress change reloads quietly and keeps the list on failure',
      () async {
    await cubit.load();
    repository.library = const Left(CacheFailure(message: 'disk full'));

    repository.changes.add('anatomy-1');
    await cubit.stream.firstWhere((state) => state.errorMessage != null);

    expect(cubit.state.status, CoursesStatus.loaded);
    expect(cubit.state.courses, hasLength(2));
    expect(cubit.state.errorMessage, 'disk full');
  });

  test('matches are found in the original text despite folded letters', () {
    const title = 'أساسيات علم وظائف الأعضاء';

    final range = TextSearch.find(title, 'الاعضاء');

    expect(range?.textInside(title), 'الأعضاء');
    expect(TextSearch.find('Foundations of Physiology', 'PHYSIO'), isNotNull);
    expect(TextSearch.find(title, ''), isNull);
  });
}
