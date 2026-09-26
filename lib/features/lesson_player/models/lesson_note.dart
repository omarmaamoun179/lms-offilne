import 'package:equatable/equatable.dart';

class LessonNote extends Equatable {
  final String id;
  final Duration position;
  final String text;
  final DateTime createdAt;

  const LessonNote({
    required this.id,
    required this.position,
    required this.text,
    required this.createdAt,
  });

  factory LessonNote.fromJson(Map<String, dynamic> json) => LessonNote(
        id: json['id'] as String,
        position: Duration(milliseconds: (json['position_ms'] as num).toInt()),
        text: json['text'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'position_ms': position.inMilliseconds,
        'text': text,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, position, text, createdAt];
}
