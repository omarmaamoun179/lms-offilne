import 'package:equatable/equatable.dart';

class LessonProgress extends Equatable {
  final Duration position;
  final bool completed;
  final DateTime updatedAt;

  const LessonProgress({
    this.position = Duration.zero,
    this.completed = false,
    required this.updatedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
        position: Duration(milliseconds: (json['position_ms'] as num).toInt()),
        completed: json['completed'] as bool,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'position_ms': position.inMilliseconds,
        'completed': completed,
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [position, completed, updatedAt];
}
