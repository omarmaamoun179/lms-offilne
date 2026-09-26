import 'package:equatable/equatable.dart';

import '../../../core/domain/failure.dart';
import '../../courses/models/course.dart';
import '../../courses/models/course_progress.dart';
import '../models/playback_speed.dart';

enum PlayerStatus { loading, ready, failed, locked, unavailable }

class LessonPlayerState extends Equatable {
  final PlayerStatus status;
  final CourseProgress? course;
  final Lesson? lesson;
  final Failure? failure;
  final Duration position;
  final Duration duration;
  final bool playing;
  final double speed;
  final bool controlsVisible;
  final bool fullscreen;
  final bool justCompleted;
  final String? errorMessage;

  const LessonPlayerState({
    this.status = PlayerStatus.loading,
    this.course,
    this.lesson,
    this.failure,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playing = false,
    this.speed = PlaybackSpeed.normal,
    this.controlsVisible = true,
    this.fullscreen = false,
    this.justCompleted = false,
    this.errorMessage,
  });

  bool get completed =>
      lesson != null && (course?.isCompleted(lesson!) ?? false);

  Lesson? get nextLesson => lesson == null ? null : course?.lessonAfter(lesson!);

  bool get nextUnlocked {
    final next = nextLesson;
    return next != null && course!.statusOf(next) != LessonStatus.locked;
  }

  int get lessonNumber => lesson == null ? 0 : course?.numberOf(lesson!) ?? 0;

  int get lessonCount => course?.lessonCount ?? 0;

  CourseSection? get section =>
      lesson == null ? null : course?.sectionOf(lesson!);

  Duration get totalDuration =>
      duration > Duration.zero ? duration : lesson?.duration ?? Duration.zero;

  double get fraction {
    final total = totalDuration.inMilliseconds;
    if (total <= 0) return 0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  LessonPlayerState copyWith({
    PlayerStatus? status,
    CourseProgress? course,
    Lesson? lesson,
    Failure? failure,
    bool clearFailure = false,
    Duration? position,
    Duration? duration,
    bool? playing,
    double? speed,
    bool? controlsVisible,
    bool? fullscreen,
    bool? justCompleted,
    String? errorMessage,
  }) {
    return LessonPlayerState(
      status: status ?? this.status,
      course: course ?? this.course,
      lesson: lesson ?? this.lesson,
      failure: clearFailure ? null : failure ?? this.failure,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playing: playing ?? this.playing,
      speed: speed ?? this.speed,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      fullscreen: fullscreen ?? this.fullscreen,
      justCompleted: justCompleted ?? this.justCompleted,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        course,
        lesson,
        failure,
        position,
        duration,
        playing,
        speed,
        controlsVisible,
        fullscreen,
        justCompleted,
        errorMessage,
      ];
}
