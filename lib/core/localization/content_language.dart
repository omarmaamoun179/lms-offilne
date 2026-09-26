import 'package:flutter/widgets.dart';

class ContentLanguage {
  String _code;

  ContentLanguage([this._code = 'ar']);

  String get code => _code;

  void update(Locale locale) => _code = locale.languageCode;
}
