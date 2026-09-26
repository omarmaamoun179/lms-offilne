import 'package:equatable/equatable.dart';

class LessonProgress extends Equatable {
  static const double completionThreshold = .9;

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

  factory LessonProgress.watched({
    LessonProgress? previous,
    required Duration position,
    required Duration duration,
    required DateTime at,
  }) =>
      LessonProgress(
        position: position,
        completed: (previous?.completed ?? false) ||
            reachesCompletion(position, duration),
        updatedAt: at,
      );

  static bool reachesCompletion(Duration position, Duration duration) =>
      duration > Duration.zero && position >= duration * completionThreshold;

  Map<String, dynamic> toJson() => {
        'position_ms': position.inMilliseconds,
        'completed': completed,
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [position, completed, updatedAt];
}
