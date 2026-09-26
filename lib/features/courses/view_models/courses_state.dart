import 'package:equatable/equatable.dart';

import '../../../core/utils/text_search.dart';
import '../models/course_progress.dart';

enum CoursesStatus { initial, loading, loaded, error }

class CoursesState extends Equatable {
  final CoursesStatus status;
  final CourseLibrary? library;
  final String query;
  final bool searching;
  final String? errorMessage;

  const CoursesState({
    this.status = CoursesStatus.initial,
    this.library,
    this.query = '',
    this.searching = false,
    this.errorMessage,
  });

  List<CourseProgress> get courses => library?.courses ?? const [];

  bool get hasQuery => query.trim().isNotEmpty;

  List<CourseProgress> get visibleCourses {
    if (!searching || !hasQuery) return courses;
    return courses
        .where(
          (entry) =>
              TextSearch.find(entry.course.title, query) != null ||
              TextSearch.find(entry.course.instructor, query) != null,
        )
        .toList();
  }

  CourseLesson? get continueWatching =>
      searching ? null : library?.continueWatching;

  CoursesState copyWith({
    CoursesStatus? status,
    CourseLibrary? library,
    String? query,
    bool? searching,
    String? errorMessage,
  }) {
    return CoursesState(
      status: status ?? this.status,
      library: library ?? this.library,
      query: query ?? this.query,
      searching: searching ?? this.searching,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, library, query, searching, errorMessage];
}
