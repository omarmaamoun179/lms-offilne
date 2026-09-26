import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:lms_offline/core/domain/failure.dart';
import 'package:lms_offline/features/courses/models/course.dart';
import 'package:lms_offline/features/courses/models/course_progress.dart';
import 'package:lms_offline/features/courses/models/lesson_progress.dart';
import 'package:lms_offline/features/courses/repositories/course_repository.dart';
import 'package:lms_offline/features/lesson_player/models/lesson_note.dart';
import 'package:lms_offline/features/lesson_player/repositories/lesson_media_repository.dart';
import 'package:lms_offline/features/lesson_player/repositories/lesson_notes_repository.dart';
import 'package:video_player/video_player.dart';

Lesson sampleLesson(String id, String title, int seconds) => Lesson(
      id: id,
      title: title,
      duration: Duration(seconds: seconds),
      video: 'assets/videos/$id.mp4',
    );

Course anatomyCourse() => Course(
      id: 'anatomy',
      title: 'مقدمة في التشريح',
      instructor: 'د. سارة العتيبي',
      sections: [
        CourseSection(
          id: 'skeletal',
          title: 'الجهاز الهيكلي',
          lessons: [
            sampleLesson('anatomy-1', 'العظام', 95),
            sampleLesson('anatomy-2', 'المفاصل', 130),
            sampleLesson('anatomy-3', 'الغضاريف', 108),
          ],
        ),
        CourseSection(
          id: 'muscular',
          title: 'الجهاز العضلي',
          lessons: [
            sampleLesson('anatomy-4', 'أنواع العضلات', 140),
            sampleLesson('anatomy-5', 'الانقباض العضلي', 185),
          ],
        ),
      ],
    );

Course physiologyCourse() => Course(
      id: 'physiology',
      title: 'أساسيات علم وظائف الأعضاء',
      instructor: 'د. خالد المنصور',
      sections: [
        CourseSection(
          id: 'heart',
          title: 'القلب',
          lessons: [
            sampleLesson('physiology-1', 'بنية القلب', 125),
            Lesson(
              id: 'physiology-2',
              title: 'الدورة الدموية الصغرى',
              duration: const Duration(seconds: 160),
              video: 'assets/videos/physiology/lesson2.mp4',
            ),
          ],
        ),
      ],
    );

Course emptyCourse() => Course(
      id: 'pharmacology',
      title: 'مبادئ علم الأدوية',
      instructor: 'د. ريم الحربي',
      sections: const [],
    );

LessonProgress done() =>
    LessonProgress(completed: true, updatedAt: DateTime(2026, 9, 1));

Map<String, LessonProgress> designSampleProgress() => {
      'anatomy-1': done(),
      'anatomy-2': done(),
      'anatomy-3': LessonProgress(
        position: const Duration(seconds: 62),
        updatedAt: DateTime(2026, 9, 2),
      ),
    };

class FakeCourseRepository implements CourseRepository {
  Either<Failure, CourseLibrary>? library;
  Either<Failure, CourseProgress>? course;
  Either<Failure, CourseLesson>? lesson;
  final StreamController<String> changes = StreamController.broadcast();

  @override
  Stream<String> get progressChanges => changes.stream;

  @override
  Future<Either<Failure, CourseLibrary>> getLibrary() async => library!;

  @override
  Future<Either<Failure, CourseProgress>> getCourse(String courseId) async =>
      course!;

  @override
  Future<Either<Failure, CourseLesson>> getLesson(
    String courseId,
    String lessonId,
  ) async =>
      lesson!;

  @override
  Future<Either<Failure, Unit>> saveProgress(
    String lessonId,
    LessonProgress progress,
  ) async =>
      const Right(unit);
}

class FakeLessonMediaRepository implements LessonMediaRepository {
  int opened = 0;

  static const Failure missing = CacheFailure(
    message: 'ملف الفيديو مفقود أو تالف.',
    code: 'video_source_error',
  );

  @override
  Future<Either<Failure, VideoPlayerController>> openVideo(
    Lesson lesson, {
    required Duration startAt,
    required double speed,
  }) async {
    opened++;
    return const Left(missing);
  }

  @override
  Failure playbackFailure() => missing;

  @override
  Future<Either<Failure, double>> getSpeed() async => const Right(1);

  @override
  Future<Either<Failure, Unit>> saveSpeed(double speed) async =>
      const Right(unit);
}

class FakeLessonNotesRepository implements LessonNotesRepository {
  @override
  Future<Either<Failure, List<LessonNote>>> getNotes(String lessonId) async =>
      const Right([]);

  @override
  Future<Either<Failure, LessonNote>> addNote(
    String lessonId, {
    required Duration position,
    required String text,
  }) =>
      throw UnimplementedError();
}
