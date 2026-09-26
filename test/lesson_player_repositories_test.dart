import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/domain/failure.dart';
import 'package:lms_offline/features/courses/models/course.dart';
import 'package:lms_offline/features/lesson_player/repositories/lesson_media_repository.dart';
import 'package:lms_offline/features/lesson_player/repositories/lesson_notes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('LessonMediaRepository', () {
    test('a lesson whose video is not bundled fails with video_source_error',
        () async {
      var created = false;
      final repository = LessonMediaRepositoryImpl(
        rootBundle,
        prefs,
        createController: (asset) {
          created = true;
          return VideoPlayerController.asset(asset);
        },
      );
      const lesson = Lesson(
        id: 'physiology-2',
        title: 'Pulmonary Circulation',
        duration: Duration(seconds: 160),
        video: 'assets/videos/physiology/lesson2.mp4',
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

    test('playback speed starts at 1x and remembers the last choice',
        () async {
      final repository = LessonMediaRepositoryImpl(rootBundle, prefs);

      final initial = await repository.getSpeed();
      await repository.saveSpeed(1.25);
      final remembered = await repository.getSpeed();

      expect(initial.getOrElse(() => 0), 1);
      expect(remembered.getOrElse(() => 0), 1.25);
    });

    test('a stored speed the player does not offer falls back to 1x',
        () async {
      await prefs.setDouble(LessonMediaRepositoryImpl.speedKey, 3);
      final repository = LessonMediaRepositoryImpl(rootBundle, prefs);

      final speed = await repository.getSpeed();

      expect(speed.getOrElse(() => 0), 1);
    });
  });

  group('LessonNotesRepository', () {
    test('a lesson with no notes has an empty list', () async {
      final repository = LessonNotesRepositoryImpl(prefs);

      final notes = await repository.getNotes('anatomy-3');

      expect(notes.getOrElse(() => fail('failed')), isEmpty);
    });

    test('notes are kept per lesson, trimmed, newest first', () async {
      final repository = LessonNotesRepositoryImpl(prefs);

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
