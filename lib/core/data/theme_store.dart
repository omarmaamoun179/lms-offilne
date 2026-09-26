import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/failure.dart';
import 'guarded_storage.dart';

class ThemeStore {
  static const String themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  ThemeStore(this._prefs);

  ThemeMode read() => switch (_prefs.getString(themeModeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<Either<Failure, Unit>> save(ThemeMode mode) => guardedStorage(
        'ThemeStore.save',
        () async {
          await _prefs.setString(themeModeKey, mode.name);
          return unit;
        },
      );
}
