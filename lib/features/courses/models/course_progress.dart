import 'package:equatable/equatable.dart';

import 'course.dart';
import 'lesson_progress.dart';

enum LessonStatus { completed, inProgress, available, locked }

class CourseProgress extends Equatable {
  static const double completionThreshold = .9;

  final Course course;
  final Map<String, LessonProgress> progress;

  const CourseProgress(this.course, this.progress);

  List<Lesson> get lessons => course.lessons;

  int get lessonCount => lessons.length;

  int get completedCount => lessons.where(isCompleted).length;

  double get fraction => lessonCount == 0 ? 0 : completedCount / lessonCount;

  int get percent => (fraction * 100).round();

  LessonProgress? progressOf(Lesson lesson) => progress[lesson.id];

  bool isCompleted(Lesson lesson) => progressOf(lesson)?.completed ?? false;

  Lesson? get current {
    for (final lesson in lessons) {
      if (!isCompleted(lesson)) return lesson;
    }
    return null;
  }

  LessonStatus statusOf(Lesson lesson) {
    if (isCompleted(lesson)) return LessonStatus.completed;
    if (current?.id != lesson.id) return LessonStatus.locked;

    final position = progressOf(lesson)?.position ?? Duration.zero;
    return position > Duration.zero
        ? LessonStatus.inProgress
        : LessonStatus.available;
  }

  double watchedFraction(Lesson lesson) {
    final position = progressOf(lesson)?.position ?? Duration.zero;
    if (lesson.duration <= Duration.zero) return 0;
    return (position.inMilliseconds / lesson.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Lesson? lessonById(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  int numberOf(Lesson lesson) =>
      lessons.indexWhere((candidate) => candidate.id == lesson.id) + 1;

  Lesson? lessonAfter(Lesson lesson) {
    final index = numberOf(lesson);
    return index > 0 && index < lessons.length ? lessons[index] : null;
  }

  CourseSection? sectionOf(Lesson lesson) {
    for (final section in course.sections) {
      if (section.lessons.any((candidate) => candidate.id == lesson.id)) {
        return section;
      }
    }
    return null;
  }

  CourseProgress withProgress(String lessonId, LessonProgress update) =>
      CourseProgress(course, {...progress, lessonId: update});

  @override
  List<Object?> get props => [course, progress];
}

class CourseLesson extends Equatable {
  final CourseProgress course;
  final Lesson lesson;

  const CourseLesson(this.course, this.lesson);

  LessonProgress? get progress => course.progressOf(lesson);

  @override
  List<Object?> get props => [course, lesson];
}

class CourseLibrary extends Equatable {
  final String studentName;
  final List<CourseProgress> courses;

  const CourseLibrary({required this.studentName, required this.courses});

  CourseLesson? get continueWatching {
    CourseLesson? latest;
    for (final course in courses) {
      final lesson = course.current;
      if (lesson == null) continue;
      if (course.statusOf(lesson) != LessonStatus.inProgress) continue;

      final candidate = CourseLesson(course, lesson);
      final previous = latest?.progress?.updatedAt;
      if (previous == null ||
          candidate.progress!.updatedAt.isAfter(previous)) {
        latest = candidate;
      }
    }
    return latest;
  }

  @override
  List<Object?> get props => [studentName, courses];
}
