import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/guarded_storage.dart';
import '../../../core/domain/failure.dart';
import '../models/lesson_note.dart';

abstract class LessonNotesRepository {
  Future<Either<Failure, List<LessonNote>>> getNotes(String lessonId);

  Future<Either<Failure, LessonNote>> addNote(
    String lessonId, {
    required Duration position,
    required String text,
  });
}

class LessonNotesRepositoryImpl implements LessonNotesRepository {
  static String keyFor(String lessonId) => 'lesson_notes.$lessonId';
  static const Duration loadingDelay = Duration(milliseconds: 800);

  final SharedPreferences _prefs;
  final Duration delay;

  LessonNotesRepositoryImpl(this._prefs, {this.delay = loadingDelay});

  @override
  Future<Either<Failure, List<LessonNote>>> getNotes(String lessonId) =>
      guardedStorage(
        'LessonNotesRepository.getNotes',
        () async {
          await Future<void>.delayed(delay);
          return _read(lessonId);
        },
        fallbackMessage: 'notes_load_failed',
      );

  @override
  Future<Either<Failure, LessonNote>> addNote(
    String lessonId, {
    required Duration position,
    required String text,
  }) =>
      guardedStorage(
        'LessonNotesRepository.addNote',
        () async {
          final now = DateTime.now();
          final note = LessonNote(
            id: now.microsecondsSinceEpoch.toString(),
            position: position,
            text: text.trim(),
            createdAt: now,
          );
          final notes = [note, ..._read(lessonId)];
          final saved = await _prefs.setString(
            keyFor(lessonId),
            jsonEncode([for (final entry in notes) entry.toJson()]),
          );
          if (!saved) throw StateError('${keyFor(lessonId)} was not written');
          return note;
        },
        fallbackMessage: 'note_save_failed',
      );

  List<LessonNote> _read(String lessonId) {
    final raw = _prefs.getString(keyFor(lessonId));
    if (raw == null) return [];

    final notes = [
      for (final entry in jsonDecode(raw) as List<dynamic>)
        LessonNote.fromJson(entry as Map<String, dynamic>),
    ];
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }
}
