import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();

  static const String bodyFamily = 'Lora';
  static const List<String> bodyFallback = ['NotoNaskhArabic'];
  static const String headingFamily = 'CormorantGaramond';
  static const List<String> headingFallback = ['Amiri'];
  static const String monoFamily = 'Menlo';
  static const List<String> monoFallback = ['Courier', 'monospace'];

  static const double defaultHeight = 1.55;

  static TextStyle w400(double size, [double height = defaultHeight]) =>
      _style(bodyFamily, bodyFallback, size, FontWeight.w400, height);

  static TextStyle w600(double size, [double height = defaultHeight]) =>
      _style(bodyFamily, bodyFallback, size, FontWeight.w600, height);

  static TextStyle heading(double size, [double height = defaultHeight]) =>
      _style(headingFamily, headingFallback, size, FontWeight.w400, height);

  static TextStyle mono(double size, [double height = defaultHeight]) =>
      _style(monoFamily, monoFallback, size, FontWeight.w400, height);

  static TextStyle _style(
    String family,
    List<String> fallback,
    double size,
    FontWeight weight,
    double height,
  ) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        leadingDistribution: TextLeadingDistribution.even,
      );
}

extension TextStyleTokens on TextStyle {
  TextStyle c(Color color) => copyWith(color: color);

  TextStyle spaced(double letterSpacing) =>
      copyWith(letterSpacing: letterSpacing);

  TextStyle get tabular =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
