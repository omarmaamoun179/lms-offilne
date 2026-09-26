import 'package:flutter/widgets.dart';

class TextSearch {
  TextSearch._();

  static const Map<String, String> _folds = {
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ٱ': 'ا',
    'ى': 'ي',
    'ئ': 'ي',
    'ؤ': 'و',
    'ة': 'ه',
  };

  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final unit in input.split('')) {
      final folded = _folds[unit] ?? unit.toLowerCase();
      buffer.write(folded.length == 1 ? folded : unit);
    }
    return buffer.toString();
  }

  static TextRange? find(String text, String query) {
    final needle = normalize(query.trim());
    if (needle.isEmpty) return null;

    final start = normalize(text).indexOf(needle);
    if (start < 0) return null;

    return TextRange(start: start, end: start + needle.length);
  }
}
