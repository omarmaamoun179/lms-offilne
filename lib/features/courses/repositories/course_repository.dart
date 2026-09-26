import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/guarded_storage.dart';
import '../../../core/domain/failure.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/localization/content_language.dart';
import '../models/course.dart';
import '../models/course_progress.dart';
import '../models/lesson_progress.dart';

abstract class CourseRepository {
  Stream<String> get progressChanges;

  Future<Either<Failure, CourseLibrary>> getLibrary();

  Future<Either<Failure, CourseProgress>> getCourse(String courseId);

  Future<Either<Failure, CourseLesson>> getLesson(
    String courseId,
    String lessonId,
  );

  Future<Either<Failure, Unit>> saveProgress(
    String lessonId,
    LessonProgress progress,
  );
}

class CourseRepositoryImpl implements CourseRepository {
  static const String progressKey = 'lesson_progress';

  final AssetBundle _assets;
  final SharedPreferences _prefs;
  final ContentLanguage _language;
  final StreamController<String> _changes = StreamController.broadcast();

  CourseRepositoryImpl(this._assets, this._prefs, this._language);

  @override
  Stream<String> get progressChanges => _changes.stream;

  @override
  Future<Either<Failure, CourseLibrary>> getLibrary() => guardedStorage(
        'CourseRepository.getLibrary',
        () async {
          final catalog = await _loadCatalog();
          final progress = _readProgress();
          return CourseLibrary(
            studentName: catalog.studentName,
            courses: [
              for (final course in catalog.courses)
                CourseProgress(course, progress),
            ],
          );
        },
        fallbackMessage: 'courses_load_failed',
      );

  @override
  Future<Either<Failure, CourseProgress>> getCourse(String courseId) =>
      guardedStorage(
        'CourseRepository.getCourse',
        () => _courseProgress(courseId),
        fallbackMessage: 'courses_load_failed',
      );

  @override
  Future<Either<Failure, CourseLesson>> getLesson(
    String courseId,
    String lessonId,
  ) =>
      guardedStorage(
        'CourseRepository.getLesson',
        () async {
          final course = await _courseProgress(courseId);
          final lesson = course.lessonById(lessonId);
          if (lesson == null) {
            throw const NotFoundException('lesson_not_found');
          }
          return CourseLesson(course, lesson);
        },
        fallbackMessage: 'courses_load_failed',
      );

  @override
  Future<Either<Failure, Unit>> saveProgress(
    String lessonId,
    LessonProgress progress,
  ) =>
      guardedStorage(
        'CourseRepository.saveProgress',
        () async {
          final all = {..._readProgress(), lessonId: progress};
          final saved = await _prefs.setString(
            progressKey,
            jsonEncode({
              for (final entry in all.entries) entry.key: entry.value.toJson(),
            }),
          );
          if (!saved) throw StateError('$progressKey was not written');

          _changes.add(lessonId);
          return unit;
        },
        fallbackMessage: 'progress_save_failed',
      );

  Future<CourseProgress> _courseProgress(String courseId) async {
    final catalog = await _loadCatalog();
    for (final course in catalog.courses) {
      if (course.id == courseId) return CourseProgress(course, _readProgress());
    }
    throw const NotFoundException('course_not_found');
  }

  Future<CourseCatalog> _loadCatalog() async {
    final raw = await _assets.loadString(
      'assets/data/courses.${_language.code}.json',
    );
    return CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Map<String, LessonProgress> _readProgress() {
    final raw = _prefs.getString(progressKey);
    if (raw == null) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries)
        entry.key: LessonProgress.fromJson(entry.value as Map<String, dynamic>),
    };
  }
}
