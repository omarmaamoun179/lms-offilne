import 'package:equatable/equatable.dart';

import '../models/course_progress.dart';

enum CourseDetailsStatus { initial, loading, loaded, error }

class CourseDetailsState extends Equatable {
  final CourseDetailsStatus status;
  final CourseProgress? course;
  final String? errorMessage;

  const CourseDetailsState({
    this.status = CourseDetailsStatus.initial,
    this.course,
    this.errorMessage,
  });

  CourseDetailsState copyWith({
    CourseDetailsStatus? status,
    CourseProgress? course,
    String? errorMessage,
  }) {
    return CourseDetailsState(
      status: status ?? this.status,
      course: course ?? this.course,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, course, errorMessage];
}
