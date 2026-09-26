import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/domain/failure.dart';
import 'package:lms_offline/core/localization/content_language.dart';
import 'package:lms_offline/features/courses/models/course_progress.dart';
import 'package:lms_offline/features/courses/models/lesson_progress.dart';
import 'package:lms_offline/features/courses/repositories/course_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  CourseRepositoryImpl repository([String language = 'ar']) =>
      CourseRepositoryImpl(rootBundle, prefs, ContentLanguage(language));

  Future<CourseLibrary> library(String language) async =>
      (await repository(language).getLibrary())
          .fold((failure) => fail('$failure'), (value) => value);

  test('both catalogs parse and describe the same lessons', () async {
    final ar = await library('ar');
    final en = await library('en');
    List<String> ids(CourseLibrary library) => [
          for (final entry in library.courses)
            for (final lesson in entry.lessons) '${entry.course.id}/${lesson.id}',
        ];

    expect(ar.studentName, 'نورة');
    expect(en.studentName, 'Noura');
    expect(ids(ar), ids(en));
    expect(ar.courses.map((entry) => entry.course.id), [
      'anatomy',
      'physiology',
      'pharmacology',
    ]);
    expect(ar.courses.first.lessonCount, 5);
    expect(ar.courses.first.course.sections, hasLength(2));
    expect(ar.courses.last.course.hasLessons, isFalse);
  });

  test('every lesson video is bundled except the sample missing one', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final bundled = manifest.listAssets().toSet();
    final ar = await library('ar');

    for (final entry in ar.courses) {
      for (final lesson in entry.lessons) {
        expect(
          bundled.contains(lesson.video),
          lesson.id != 'physiology-2',
          reason: lesson.video,
        );
      }
    }
  });

  test('saved progress comes back, unlocks the next lesson and is announced',
      () async {
    final repo = repository();
    final announced = expectLater(repo.progressChanges, emits('anatomy-1'));

    final saved = await repo.saveProgress(
      'anatomy-1',
      LessonProgress(
        position: const Duration(seconds: 90),
        completed: true,
        updatedAt: DateTime(2026, 9, 1),
      ),
    );
    await announced;
    final course = (await repo.getCourse('anatomy'))
        .fold((failure) => fail('$failure'), (value) => value);

    expect(saved.isRight(), isTrue);
    expect(course.completedCount, 1);
    expect(course.statusOf(course.lessons[1]), LessonStatus.available);
  });

  test('an unknown course is a failure, not an empty course', () async {
    final result = await repository().getCourse('astronomy');

    result.fold(
      (failure) {
        expect(failure, isA<CacheFailure>());
        expect(failure.code, 'not_found');
      },
      (_) => fail('found a course that does not exist'),
    );
  });

  test('an unknown lesson in a real course is a failure', () async {
    final result = await repository().getLesson('anatomy', 'anatomy-9');

    expect(result.isLeft(), isTrue);
  });

  test('stored progress that no longer parses is an unexpected failure',
      () async {
    await prefs.setString(CourseRepositoryImpl.progressKey, 'not json');

    final result = await repository().getLibrary();

    result.fold(
      (failure) => expect(failure, isA<UnexpectedFailure>()),
      (_) => fail('parsed corrupt progress'),
    );
  });
}
