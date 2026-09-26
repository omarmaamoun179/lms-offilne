import 'dart:async';

import '../../../core/abstract/base_cubit.dart';
import '../repositories/course_repository.dart';
import 'courses_state.dart';

class CoursesViewModel extends BaseCubit<CoursesState> {
  final CourseRepository _repository;
  late final StreamSubscription<String> _progressChanges;

  CoursesViewModel(this._repository) : super(const CoursesState()) {
    _progressChanges = _repository.progressChanges.listen((_) => _fetch());
  }

  Future<void> load() async {
    emit(state.copyWith(status: CoursesStatus.loading));
    await _fetch();
  }

  Future<void> _fetch() async {
    final result = await _repository.getLibrary();

    result.fold(
      (failure) => emit(state.copyWith(
        status: state.library == null ? CoursesStatus.error : null,
        errorMessage: failure.message,
      )),
      (library) => emit(state.copyWith(
        status: CoursesStatus.loaded,
        library: library,
      )),
    );
  }

  void startSearch() => emit(state.copyWith(searching: true));

  void search(String query) =>
      emit(state.copyWith(query: query, searching: true));

  void cancelSearch() => emit(state.copyWith(query: '', searching: false));

  @override
  Future<void> close() async {
    await _progressChanges.cancel();
    return super.close();
  }
}
