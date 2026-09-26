import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/domain/failure.dart';
import 'package:lms_offline/core/security/secure_video_server.dart';
import 'package:lms_offline/core/security/video_key.dart';
import 'package:lms_offline/features/courses/models/course.dart';
import 'package:lms_offline/features/lesson_player/repositories/lesson_media_repository.dart';
import 'package:lms_offline/features/lesson_player/repositories/lesson_notes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

Future<Uint8List> _get(Uri uri, {String? range}) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
    final response = await request.close();
    final builder = BytesBuilder(copy: false);
    await response.forEach(builder.add);
    return builder.takeBytes();
  } finally {
    client.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SecureVideoServer server;

  setUp(() async {
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    server = SecureVideoServer();
  });

  tearDown(() => server.close());

  LessonMediaRepositoryImpl media({VideoControllerFactory? createController}) =>
      LessonMediaRepositoryImpl(
        rootBundle,
        prefs,
        server,
        videoKey(),
        createController: createController,
        delay: Duration.zero,
      );

  group('LessonMediaRepository', () {
    test('a lesson whose video is not bundled fails with video_source_error',
        () async {
      var created = false;
      final repository = media(
        createController: (source) {
          created = true;
          return VideoPlayerController.networkUrl(source);
        },
      );
      const lesson = Lesson(
        id: 'physiology-2',
        title: 'Pulmonary Circulation',
        duration: Duration(seconds: 160),
        video: 'assets/videos/physiology/lesson2.enc',
      );

      final result = await repository.openVideo(
        lesson,
        startAt: Duration.zero,
        speed: 1,
      );

      expect(created, isFalse);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.code, 'video_source_error');
        },
        (_) => fail('opened a video that is not bundled'),
      );
    });

    test('a bundled lesson is decrypted and served only on loopback',
        () async {
      Uri? served;
      final repository = media(
        createController: (source) {
          served = source;
          throw StateError('unit tests have no native video player');
        },
      );
      const lesson = Lesson(
        id: 'anatomy-3',
        title: 'Cartilage',
        duration: Duration(seconds: 108),
        video: 'assets/videos/anatomy/lesson3.enc',
      );
      final original = File('media/videos/anatomy/lesson3.mp4').readAsBytesSync();

      await repository.openVideo(lesson, startAt: Duration.zero, speed: 1);

      expect(served?.host, '127.0.0.1');
      expect(await _get(served!), original);
      expect(
        await _get(served!, range: 'bytes=100-199'),
        original.sublist(100, 200),
      );
    });

    test('playback speed starts at 1x and remembers the last choice',
        () async {
      final repository = media();

      final initial = await repository.getSpeed();
      await repository.saveSpeed(1.25);
      final remembered = await repository.getSpeed();

      expect(initial.getOrElse(() => 0), 1);
      expect(remembered.getOrElse(() => 0), 1.25);
    });

    test('a stored speed the player does not offer falls back to 1x',
        () async {
      await prefs.setDouble(LessonMediaRepositoryImpl.speedKey, 3);

      final speed = await media().getSpeed();

      expect(speed.getOrElse(() => 0), 1);
    });
  });

  group('LessonNotesRepository', () {
    test('a lesson with no notes has an empty list', () async {
      final repository = LessonNotesRepositoryImpl(
        prefs,
        delay: Duration.zero,
      );

      final notes = await repository.getNotes('anatomy-3');

      expect(notes.getOrElse(() => fail('failed')), isEmpty);
    });

    test('notes are kept per lesson, trimmed, newest first', () async {
      final repository = LessonNotesRepositoryImpl(
        prefs,
        delay: Duration.zero,
      );

      await repository.addNote(
        'anatomy-3',
        position: const Duration(seconds: 15),
        text: 'لا يحتوي الغضروف على أوعية دموية ',
      );
      await repository.addNote(
        'anatomy-3',
        position: const Duration(seconds: 48),
        text: 'الغضروف الزجاجي يغطي أسطح المفاصل',
      );
      await repository.addNote(
        'anatomy-4',
        position: const Duration(seconds: 5),
        text: 'other lesson',
      );
      final notes = (await repository.getNotes('anatomy-3'))
          .getOrElse(() => fail('failed'));

      expect(notes.map((note) => note.position.inSeconds), [48, 15]);
      expect(notes.last.text, 'لا يحتوي الغضروف على أوعية دموية');
    });
  });
}
