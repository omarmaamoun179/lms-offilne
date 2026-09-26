import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../../core/data/guarded_storage.dart';
import '../../../core/domain/failure.dart';
import '../../../core/domain/failure_mapper.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/security/secure_video_server.dart';
import '../../../core/security/video_cipher.dart';
import '../../courses/models/course.dart';
import '../models/playback_speed.dart';

typedef VideoControllerFactory = VideoPlayerController Function(Uri source);

abstract class LessonMediaRepository {
  Future<Either<Failure, VideoPlayerController>> openVideo(
    Lesson lesson, {
    required Duration startAt,
    required double speed,
  });

  Failure playbackFailure();

  Future<Either<Failure, double>> getSpeed();

  Future<Either<Failure, Unit>> saveSpeed(double speed);
}

class LessonMediaRepositoryImpl implements LessonMediaRepository {
  static const String speedKey = 'playback_speed';
  static const Duration loadingDelay = Duration(milliseconds: 800);

  final AssetBundle _assets;
  final SharedPreferences _prefs;
  final SecureVideoServer _server;
  final Uint8List _key;
  final VideoControllerFactory _createController;
  final Duration delay;

  LessonMediaRepositoryImpl(
    this._assets,
    this._prefs,
    this._server,
    this._key, {
    VideoControllerFactory? createController,
    this.delay = loadingDelay,
  }) : _createController = createController ?? VideoPlayerController.networkUrl;

  @override
  Future<Either<Failure, VideoPlayerController>> openVideo(
    Lesson lesson, {
    required Duration startAt,
    required double speed,
  }) =>
      guardedStorage(
        'LessonMediaRepository.openVideo',
        () async {
          await Future<void>.delayed(delay);
          if (!(await _bundledAssets()).contains(lesson.video)) {
            throw const MediaException();
          }

          final data = await _assets.load(lesson.video);
          final video = EncryptedVideo.open(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            _key,
          );
          final source = await _server.register(lesson.id, video);

          final controller = _createController(source);
          try {
            await controller.initialize();
            if (controller.value.hasError) throw const MediaException();
            await controller.setPlaybackSpeed(speed);
            if (startAt > Duration.zero) await controller.seekTo(startAt);
          } catch (_) {
            await controller.dispose();
            rethrow;
          }
          return controller;
        },
        fallbackMessage: 'video_unavailable',
        fallbackCode: MediaException.sourceError,
      );

  Future<Set<String>> _bundledAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(_assets);
    return manifest.listAssets().toSet();
  }

  @override
  Failure playbackFailure() => mapExceptionToFailure(const MediaException());

  @override
  Future<Either<Failure, double>> getSpeed() => guardedStorage(
        'LessonMediaRepository.getSpeed',
        () async {
          final saved = _prefs.getDouble(speedKey);
          return PlaybackSpeed.options.contains(saved)
              ? saved!
              : PlaybackSpeed.normal;
        },
      );

  @override
  Future<Either<Failure, Unit>> saveSpeed(double speed) => guardedStorage(
        'LessonMediaRepository.saveSpeed',
        () async {
          final saved = await _prefs.setDouble(speedKey, speed);
          if (!saved) throw StateError('$speedKey was not written');
          return unit;
        },
        fallbackMessage: 'speed_save_failed',
      );
}
