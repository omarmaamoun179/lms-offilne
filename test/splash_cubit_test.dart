import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/domain/failure.dart';
import 'package:lms_offline/features/courses/models/course_progress.dart';
import 'package:lms_offline/features/courses/models/lesson_progress.dart';
import 'package:lms_offline/features/courses/repositories/course_repository.dart';
import 'package:lms_offline/features/splash/cubit/splash_cubit.dart';
import 'package:lms_offline/features/splash/cubit/splash_state.dart';

class _SlowCourseRepository implements CourseRepository {
  final Completer<Either<Failure, CourseLibrary>> library = Completer();

  @override
  Stream<String> get progressChanges => const Stream.empty();

  @override
  Future<Either<Failure, CourseLibrary>> getLibrary() => library.future;

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

void main() {
  late _SlowCourseRepository repository;

  setUp(() => repository = _SlowCourseRepository());

  test('stays up until the catalog and progress have loaded', () async {
    final cubit = SplashCubit(repository, minimum: Duration.zero);

    final started = cubit.start();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final whileLoading = cubit.state;
    repository.library.complete(
      const Right(CourseLibrary(studentName: 'نورة', courses: [])),
    );
    await started;

    expect(whileLoading, SplashStatus.loading);
    expect(cubit.state, SplashStatus.ready);
    await cubit.close();
  });

  test('hands off even when the catalog fails, for Courses to report',
      () async {
    final cubit = SplashCubit(repository, minimum: Duration.zero);
    repository.library.complete(
      const Left(CacheFailure(message: 'broken')),
    );

    await cubit.start();

    expect(cubit.state, SplashStatus.ready);
    await cubit.close();
  });

  test('stays up for the minimum time even when loading is instant',
      () async {
    final cubit = SplashCubit(
      repository,
      minimum: const Duration(milliseconds: 150),
    );
    repository.library.complete(
      const Right(CourseLibrary(studentName: 'Noura', courses: [])),
    );

    final started = cubit.start();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final early = cubit.state;
    await started;

    expect(early, SplashStatus.loading);
    expect(cubit.state, SplashStatus.ready);
    await cubit.close();
  });
}
