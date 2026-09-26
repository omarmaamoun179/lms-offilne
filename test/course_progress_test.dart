import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/utils/duration_format.dart';
import 'package:lms_offline/features/courses/models/course.dart';
import 'package:lms_offline/features/courses/models/course_progress.dart';
import 'package:lms_offline/features/courses/models/lesson_progress.dart';

Lesson _lesson(String id, int seconds) => Lesson(
      id: id,
      title: id,
      duration: Duration(seconds: seconds),
      video: 'assets/videos/$id.mp4',
    );

Course _course([String id = 'anatomy']) => Course(
      id: id,
      title: id,
      instructor: 'instructor',
      sections: [
        CourseSection(
          id: 'skeletal',
          title: 'skeletal',
          lessons: [_lesson('l1', 95), _lesson('l2', 130), _lesson('l3', 108)],
        ),
        CourseSection(
          id: 'muscular',
          title: 'muscular',
          lessons: [_lesson('l4', 140), _lesson('l5', 185)],
        ),
      ],
    );

LessonProgress _done() =>
    LessonProgress(completed: true, updatedAt: DateTime(2026, 9, 1));

LessonProgress _at(int seconds, DateTime updatedAt) =>
    LessonProgress(position: Duration(seconds: seconds), updatedAt: updatedAt);

List<LessonStatus> _statuses(CourseProgress progress) =>
    [for (final lesson in progress.lessons) progress.statusOf(lesson)];

void main() {
  test('a fresh course opens its first lesson and locks the rest', () {
    final progress = CourseProgress(_course(), const {});

    expect(_statuses(progress), [
      LessonStatus.available,
      LessonStatus.locked,
      LessonStatus.locked,
      LessonStatus.locked,
      LessonStatus.locked,
    ]);
    expect(progress.percent, 0);
    expect(progress.current?.id, 'l1');
  });

  test('the design sample: two lessons done and the third at 1:02', () {
    final progress = CourseProgress(_course(), {
      'l1': _done(),
      'l2': _done(),
      'l3': _at(62, DateTime(2026, 9, 2)),
    });
    final cartilage = progress.lessonById('l3')!;

    expect(_statuses(progress), [
      LessonStatus.completed,
      LessonStatus.completed,
      LessonStatus.inProgress,
      LessonStatus.locked,
      LessonStatus.locked,
    ]);
    expect(progress.completedCount, 2);
    expect(progress.percent, 40);
    expect((progress.watchedFraction(cartilage) * 100).round(), 57);
    expect(progress.current, cartilage);
  });

  test('finishing the current lesson opens the next one, across sections', () {
    final progress = CourseProgress(_course(), {
      'l1': _done(),
      'l2': _done(),
    }).withProgress('l3', _done());

    expect(progress.statusOf(progress.lessonById('l4')!), LessonStatus.available);
    expect(progress.statusOf(progress.lessonById('l5')!), LessonStatus.locked);
  });

  test('a finished course has no current lesson and is at 100%', () {
    final progress = CourseProgress(_course(), {
      for (final id in ['l1', 'l2', 'l3', 'l4', 'l5']) id: _done(),
    });

    expect(progress.current, isNull);
    expect(progress.percent, 100);
  });

  test('lessons are numbered and chained across sections', () {
    final progress = CourseProgress(_course(), const {});
    final third = progress.lessonById('l3')!;
    final fourth = progress.lessonById('l4')!;

    expect(progress.numberOf(fourth), 4);
    expect(progress.lessonAfter(third), fourth);
    expect(progress.lessonAfter(progress.lessonById('l5')!), isNull);
    expect(progress.sectionOf(fourth)?.id, 'muscular');
  });

  test('a section lasts as long as its lessons together', () {
    final sections = _course().sections;

    expect(sections.first.duration.clock, '5:33');
    expect(sections.last.duration.clock, '5:25');
  });

  test('continue watching is the most recently watched unfinished lesson', () {
    final library = CourseLibrary(
      studentName: 'Noura',
      courses: [
        CourseProgress(_course('anatomy'), {
          'l1': _at(30, DateTime(2026, 9, 1)),
        }),
        CourseProgress(_course('physiology'), const {}),
      ],
    );
    final later = CourseLibrary(
      studentName: 'Noura',
      courses: [
        library.courses.first,
        CourseProgress(_course('physiology'), {
          'l1': _at(10, DateTime(2026, 9, 3)),
        }),
      ],
    );

    expect(library.continueWatching?.course.course.id, 'anatomy');
    expect(later.continueWatching?.course.course.id, 'physiology');
  });

  test('nothing to continue before any lesson has been started', () {
    final library = CourseLibrary(
      studentName: 'Noura',
      courses: [CourseProgress(_course(), {'l1': _done()})],
    );

    expect(library.continueWatching, isNull);
  });

  group('the 90% completion rule', () {
    const length = Duration(seconds: 108);
    const ninetyPercent = Duration(milliseconds: 97200);
    final now = DateTime(2026, 9, 5);

    test('a lesson completes exactly at 90% of its length', () {
      expect(LessonProgress.reachesCompletion(ninetyPercent, length), isTrue);
      expect(
        LessonProgress.reachesCompletion(const Duration(seconds: 105), length),
        isTrue,
      );
    });

    test('a millisecond before 90% the lesson is still in progress', () {
      const almost = Duration(milliseconds: 97199);

      final progress = LessonProgress.watched(
        position: almost,
        duration: length,
        at: now,
      );

      expect(LessonProgress.reachesCompletion(almost, length), isFalse);
      expect(progress.completed, isFalse);
      expect(progress.position, almost);
    });

    test('watching past 90% records the lesson as completed', () {
      final progress = LessonProgress.watched(
        previous: _at(62, DateTime(2026, 9, 2)),
        position: const Duration(seconds: 100),
        duration: length,
        at: now,
      );

      expect(progress.completed, isTrue);
      expect(progress.position, const Duration(seconds: 100));
      expect(progress.updatedAt, now);
    });

    test('rewinding a completed lesson keeps it completed', () {
      final progress = LessonProgress.watched(
        previous: _done(),
        position: const Duration(seconds: 10),
        duration: length,
        at: now,
      );

      expect(progress.completed, isTrue);
    });

    test('a video whose length is unknown never completes', () {
      expect(
        LessonProgress.reachesCompletion(Duration.zero, Duration.zero),
        isFalse,
      );
    });

    test('reaching 90% of the current lesson unlocks the next one', () {
      final before = CourseProgress(_course(), {
        'l1': _done(),
        'l2': _done(),
        'l3': _at(62, DateTime(2026, 9, 2)),
      });
      final cartilage = before.lessonById('l3')!;
      final muscles = before.lessonById('l4')!;

      final after = before.withProgress(
        'l3',
        LessonProgress.watched(
          previous: before.progressOf(cartilage),
          position: ninetyPercent,
          duration: cartilage.duration,
          at: now,
        ),
      );

      expect(before.statusOf(muscles), LessonStatus.locked);
      expect(after.statusOf(cartilage), LessonStatus.completed);
      expect(after.statusOf(muscles), LessonStatus.available);
      expect(after.percent, 60);
    });
  });
}
