import 'dart:async';

import 'package:video_player/video_player.dart';

import '../../../core/abstract/base_cubit.dart';
import '../../courses/models/course_progress.dart';
import '../../courses/models/lesson_progress.dart';
import '../../courses/repositories/course_repository.dart';
import '../models/playback_speed.dart';
import '../repositories/lesson_media_repository.dart';
import 'lesson_player_state.dart';

class LessonPlayerCubit extends BaseCubit<LessonPlayerState> {
  static const Duration skipStep = Duration(seconds: 10);
  static const Duration saveEvery = Duration(seconds: 5);
  static const Duration controlsTimeout = Duration(seconds: 3);
  static const double restartFrom = .95;

  final CourseRepository _courses;
  final LessonMediaRepository _media;

  VideoPlayerController? _controller;
  Timer? _hideTimer;
  Duration _savedPosition = Duration.zero;

  LessonPlayerCubit(this._courses, this._media)
      : super(const LessonPlayerState());

  VideoPlayerController? get controller => _controller;

  Future<void> load({
    required String courseId,
    required String lessonId,
  }) async {
    final speed = await _media.getSpeed();
    final result = await _courses.getLesson(courseId, lessonId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PlayerStatus.unavailable,
        failure: failure,
      )),
      (entry) => emit(state.copyWith(
        status: entry.course.statusOf(entry.lesson) == LessonStatus.locked
            ? PlayerStatus.locked
            : PlayerStatus.loading,
        course: entry.course,
        lesson: entry.lesson,
        duration: entry.lesson.duration,
        speed: speed.fold((_) => PlaybackSpeed.normal, (value) => value),
      )),
    );

    if (state.status == PlayerStatus.loading) await _open();
  }

  Future<void> retry() => _open();

  Future<void> _open() async {
    final lesson = state.lesson!;
    final saved = state.course!.progressOf(lesson);
    final resumable = saved != null &&
        saved.position < lesson.duration * restartFrom;
    final startAt = resumable ? saved.position : Duration.zero;

    emit(state.copyWith(status: PlayerStatus.loading, clearFailure: true));

    final result = await _media.openVideo(
      lesson,
      startAt: startAt,
      speed: state.speed,
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: PlayerStatus.failed,
        failure: failure,
        playing: false,
      )),
      (controller) => _attach(controller, startAt),
    );
  }

  Future<void> _attach(VideoPlayerController controller, Duration at) async {
    if (isClosed) {
      await controller.dispose();
      return;
    }

    _controller = controller;
    _savedPosition = at;
    controller.addListener(_onTick);
    emit(state.copyWith(
      status: PlayerStatus.ready,
      position: at,
      duration: controller.value.duration,
      controlsVisible: true,
    ));

    await controller.play();
    _scheduleHide();
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;
    if (value.hasError) {
      controller.removeListener(_onTick);
      emit(state.copyWith(
        status: PlayerStatus.failed,
        failure: _media.playbackFailure(),
        playing: false,
      ));
      return;
    }

    final position =
        value.position > value.duration ? value.duration : value.position;
    final reachedEnd =
        LessonProgress.reachesCompletion(position, value.duration);

    if ((reachedEnd && !state.completed) ||
        (position - _savedPosition).abs() >= saveEvery ||
        (state.playing && !value.isPlaying)) {
      _save(position, value.duration);
    }

    final moved = position.inMilliseconds ~/ 250 !=
        state.position.inMilliseconds ~/ 250;
    if (!moved && value.isPlaying == state.playing) return;

    emit(state.copyWith(
      position: position,
      duration: value.duration,
      playing: value.isPlaying,
      controlsVisible: value.isPlaying ? null : true,
    ));
  }

  Future<void> _save(Duration position, Duration duration) async {
    final lesson = state.lesson!;
    final progress = _progressAt(position, duration);
    _savedPosition = position;
    if (progress.completed && !state.completed) {
      emit(state.copyWith(
        course: state.course!.withProgress(lesson.id, progress),
        justCompleted: true,
      ));
    }

    final result = await _courses.saveProgress(lesson.id, progress);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        course: state.course!.withProgress(lesson.id, progress),
      )),
    );
  }

  Future<void> togglePlay() async {
    final controller = _controller;
    if (controller == null) return;

    if (controller.value.isPlaying) {
      _hideTimer?.cancel();
      emit(state.copyWith(controlsVisible: true));
      await controller.pause();
      return;
    }

    if (controller.value.position >= controller.value.duration) {
      await controller.seekTo(Duration.zero);
    }
    await controller.play();
    _scheduleHide();
  }

  Future<Duration> pause() async {
    final controller = _controller;
    if (controller == null) return state.position;

    _hideTimer?.cancel();
    await controller.pause();
    emit(state.copyWith(controlsVisible: true));
    return controller.value.position;
  }

  Future<void> seekBy(Duration delta) => seekTo(state.position + delta);

  Future<void> seekTo(Duration target) async {
    final controller = _controller;
    if (controller == null) return;

    final end = controller.value.duration;
    final clamped = target < Duration.zero
        ? Duration.zero
        : target > end
            ? end
            : target;

    emit(state.copyWith(position: clamped, controlsVisible: true));
    await controller.seekTo(clamped);
    _scheduleHide();
  }

  Future<void> setSpeed(double speed) async {
    emit(state.copyWith(speed: speed));
    await _controller?.setPlaybackSpeed(speed);

    final result = await _media.saveSpeed(speed);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(speed: speed)),
    );
  }

  void cycleSpeed() => setSpeed(PlaybackSpeed.after(state.speed));

  void toggleControls() {
    if (state.controlsVisible && state.playing) {
      _hideTimer?.cancel();
      emit(state.copyWith(controlsVisible: false));
      return;
    }
    emit(state.copyWith(controlsVisible: true));
    _scheduleHide();
  }

  void toggleFullscreen() {
    emit(state.copyWith(fullscreen: !state.fullscreen, controlsVisible: true));
    _scheduleHide();
  }

  void exitFullscreen() {
    if (state.fullscreen) toggleFullscreen();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(controlsTimeout, () {
      if (_controller?.value.isPlaying ?? false) {
        emit(state.copyWith(controlsVisible: false));
      }
    });
  }

  @override
  Future<void> close() async {
    _hideTimer?.cancel();
    final controller = _controller;
    _controller = null;

    if (controller != null) {
      controller.removeListener(_onTick);
      final position = controller.value.position;
      if (position != _savedPosition) {
        await _courses.saveProgress(
          state.lesson!.id,
          _progressAt(position, controller.value.duration),
        );
      }
      await controller.dispose();
    }
    return super.close();
  }

  LessonProgress _progressAt(Duration position, Duration duration) =>
      LessonProgress.watched(
        previous: state.course!.progressOf(state.lesson!),
        position: position,
        duration: duration,
        at: DateTime.now(),
      );
}
