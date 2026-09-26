import 'package:equatable/equatable.dart';

import '../models/lesson_note.dart';

enum NotesStatus { loading, loaded, error }

class LessonNotesState extends Equatable {
  final NotesStatus status;
  final List<LessonNote> notes;
  final String? errorMessage;

  const LessonNotesState({
    this.status = NotesStatus.loading,
    this.notes = const [],
    this.errorMessage,
  });

  LessonNotesState copyWith({
    NotesStatus? status,
    List<LessonNote>? notes,
    String? errorMessage,
  }) {
    return LessonNotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
