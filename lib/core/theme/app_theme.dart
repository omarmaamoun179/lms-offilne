import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_strings.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static SystemUiOverlayStyle overlayStyle(Brightness brightness) =>
      brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;

  static ThemeData _build(AppPalette p, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.accent,
        onPrimary: p.bg,
        secondary: p.accent700,
        onSecondary: p.bg,
        error: p.accent800,
        onError: p.bg,
        surface: p.bg,
        onSurface: p.text,
        outline: p.border,
        outlineVariant: p.divider,
      ),
      fontFamily: AppStrings.bodyFamily,
      fontFamilyFallback: AppStrings.bodyFallback,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: p.accent100.withValues(alpha: .5),
      extensions: [p],
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: overlayStyle(brightness),
      ),
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: .3),
        selectionHandleColor: p.accent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: p.scrim,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      textTheme: TextTheme(
        headlineMedium: AppStrings.heading(28, 1.4).c(p.text),
        titleLarge: AppStrings.heading(21).c(p.text),
        titleMedium: AppStrings.heading(20).c(p.text),
        bodyLarge: AppStrings.w400(15).c(p.text),
        bodyMedium: AppStrings.w400(14).c(p.text),
        bodySmall: AppStrings.w400(12.5).c(p.neutral700),
        labelLarge: AppStrings.w400(14.5).c(p.text),
      ),
    );
  }
}
