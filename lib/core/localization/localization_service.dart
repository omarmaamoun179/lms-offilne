import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../di/di_exports.dart';

class LocalizationService {
  LocalizationService._();

  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');
  static const List<Locale> supportedLocales = [arabic, english];
  static const String translationsPath = 'assets/translations';

  static Widget wrap(Widget child) {
    return EasyLocalization(
      supportedLocales: supportedLocales,
      path: translationsPath,
      fallbackLocale: arabic,
      startLocale: arabic,
      saveLocale: true,
      useFallbackTranslations: true,
      ignorePluralRules: false,
      child: child,
    );
  }

  static Locale other(Locale current) =>
      current.languageCode == arabic.languageCode ? english : arabic;

  static Future<void> change(BuildContext context, Locale locale) async {
    sl<ContentLanguage>().update(locale);
    await context.setLocale(locale);
  }
}
