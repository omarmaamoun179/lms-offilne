import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const errorMessageKeys = [
  'unexpected_error',
  'cache_error',
  'courses_load_failed',
  'course_not_found',
  'lesson_not_found',
  'video_unavailable',
  'progress_save_failed',
  'notes_load_failed',
  'note_save_failed',
  'speed_save_failed',
];

Map<String, dynamic> _load(String code) =>
    jsonDecode(File('assets/translations/$code.json').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> json, [String prefix = '']) => {
      for (final entry in json.entries)
        if (entry.value is Map<String, dynamic>)
          ..._keys(entry.value as Map<String, dynamic>, '$prefix${entry.key}.')
        else
          '$prefix${entry.key}',
    };

Set<String> _keysUsedInLib() {
  final patterns = [
    RegExp(r"'([a-z][a-z0-9_]*)'\s*\.\s*(?:tr|plural)\("),
    RegExp(r"\?\s*'([a-z][a-z0-9_]*)'\s*:\s*'([a-z][a-z0-9_]*)'\)\s*\.tr\("),
    RegExp(r"=>\s*'(greeting_[a-z]+)'"),
  ];
  final used = <String>{};
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (final file in sources) {
    final source = file.readAsStringSync();
    for (final pattern in patterns) {
      for (final match in pattern.allMatches(source)) {
        for (var group = 1; group <= match.groupCount; group++) {
          final key = match.group(group);
          if (key != null) used.add(key);
        }
      }
    }
  }
  return used;
}

void main() {
  final ar = _load('ar');
  final en = _load('en');

  test('both languages hold the same key set', () {
    expect(_keys(ar), _keys(en));
  });

  test('every error message sentinel is translated in both languages', () {
    for (final key in errorMessageKeys) {
      expect(ar[key], isA<String>(), reason: 'ar is missing $key');
      expect(en[key], isA<String>(), reason: 'en is missing $key');
    }
  });

  test('every key the app reads exists', () {
    final keys = {
      for (final entry in ar.entries) entry.key,
    };

    final missing = _keysUsedInLib().difference(keys);

    expect(missing, isEmpty);
  });

  test('no translation is blank', () {
    for (final json in [ar, en]) {
      for (final key in _keys(json)) {
        final value = key.split('.').fold<Object?>(
              json,
              (node, part) => (node as Map<String, dynamic>)[part],
            );
        expect((value as String).trim(), isNotEmpty, reason: key);
      }
    }
  });
}
