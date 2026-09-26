import '../../../core/abstract/base_cubit.dart';
import '../../../core/domain/failure.dart';
import '../repositories/lesson_notes_repository.dart';
import 'lesson_notes_state.dart';

class LessonNotesCubit extends BaseCubit<LessonNotesState> {
  final LessonNotesRepository _repository;
  String? _lessonId;

  LessonNotesCubit(this._repository) : super(const LessonNotesState());

  Future<void> load(String lessonId) async {
    _lessonId = lessonId;
    emit(state.copyWith(status: NotesStatus.loading));

    final result = await _repository.getNotes(lessonId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: NotesStatus.error,
        errorMessage: failure.message,
      )),
      (notes) => emit(state.copyWith(status: NotesStatus.loaded, notes: notes)),
    );
  }

  Future<Failure?> add(Duration position, String text) async {
    final lessonId = _lessonId;
    if (lessonId == null || text.trim().isEmpty) return null;

    final result = await _repository.addNote(
      lessonId,
      position: position,
      text: text,
    );

    return result.fold(
      (failure) => failure,
      (note) {
        emit(state.copyWith(
          status: NotesStatus.loaded,
          notes: [note, ...state.notes],
        ));
        return null;
      },
    );
  }
}
