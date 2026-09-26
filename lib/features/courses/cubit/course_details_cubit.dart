import 'dart:async';

import '../../../core/abstract/base_cubit.dart';
import '../repositories/course_repository.dart';
import 'course_details_state.dart';

class CourseDetailsCubit extends BaseCubit<CourseDetailsState> {
  final CourseRepository _repository;
  late final StreamSubscription<String> _progressChanges;
  String? _courseId;

  CourseDetailsCubit(this._repository)
      : super(const CourseDetailsState()) {
    _progressChanges = _repository.progressChanges.listen((_) => _fetch());
  }

  Future<void> load(String courseId) async {
    _courseId = courseId;
    emit(state.copyWith(status: CourseDetailsStatus.loading));
    await _fetch();
  }

  Future<void> _fetch() async {
    final courseId = _courseId;
    if (courseId == null) return;

    final result = await _repository.getCourse(courseId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: state.course == null ? CourseDetailsStatus.error : null,
        errorMessage: failure.message,
      )),
      (course) => emit(state.copyWith(
        status: CourseDetailsStatus.loaded,
        course: course,
      )),
    );
  }

  @override
  Future<void> close() async {
    await _progressChanges.cancel();
    return super.close();
  }
}
