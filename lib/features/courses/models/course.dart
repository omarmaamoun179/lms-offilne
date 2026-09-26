import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final Duration duration;
  final String video;

  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.video,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        duration: Duration(seconds: (json['duration_seconds'] as num).toInt()),
        video: json['video'] as String,
      );

  String get videoFileName => video.split('/').last;

  @override
  List<Object?> get props => [id, title, duration, video];
}

class CourseSection extends Equatable {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const CourseSection({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) => CourseSection(
        id: json['id'] as String,
        title: json['title'] as String,
        lessons: [
          for (final lesson in json['lessons'] as List<dynamic>)
            Lesson.fromJson(lesson as Map<String, dynamic>),
        ],
      );

  Duration get duration => lessons.fold(
        Duration.zero,
        (total, lesson) => total + lesson.duration,
      );

  @override
  List<Object?> get props => [id, title, lessons];
}

class Course extends Equatable {
  final String id;
  final String title;
  final String instructor;
  final String? thumbnail;
  final List<CourseSection> sections;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    this.thumbnail,
    required this.sections,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        title: json['title'] as String,
        instructor: json['instructor'] as String,
        thumbnail: json['thumbnail'] as String?,
        sections: [
          for (final section in json['sections'] as List<dynamic>)
            CourseSection.fromJson(section as Map<String, dynamic>),
        ],
      );

  late final List<Lesson> lessons = [
    for (final section in sections) ...section.lessons,
  ];

  bool get hasLessons => lessons.isNotEmpty;

  @override
  List<Object?> get props => [id, title, instructor, thumbnail, sections];
}

class CourseCatalog extends Equatable {
  final String studentName;
  final List<Course> courses;

  const CourseCatalog({required this.studentName, required this.courses});

  factory CourseCatalog.fromJson(Map<String, dynamic> json) => CourseCatalog(
        studentName: (json['student'] as Map<String, dynamic>)['name'] as String,
        courses: [
          for (final course in json['courses'] as List<dynamic>)
            Course.fromJson(course as Map<String, dynamic>),
        ],
      );

  @override
  List<Object?> get props => [studentName, courses];
}
