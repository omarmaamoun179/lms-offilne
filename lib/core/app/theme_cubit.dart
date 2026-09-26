import 'package:flutter/material.dart';

import '../abstract/base_cubit.dart';
import '../data/theme_store.dart';

class ThemeCubit extends BaseCubit<ThemeMode> {
  final ThemeStore _store;

  ThemeCubit(this._store) : super(ThemeMode.system);

  void restore() => emit(_store.read());

  Future<void> toggle({required bool isDark}) async {
    final mode = isDark ? ThemeMode.light : ThemeMode.dark;
    emit(mode);
    await _store.save(mode);
  }
}
