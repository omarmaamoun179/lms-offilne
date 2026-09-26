import 'package:easy_localization/easy_localization.dart';

import '../exceptions/app_exceptions.dart';
import 'failure.dart';

Failure mapExceptionToFailure(
  Object error, {
  String fallbackMessage = 'cache_error',
  String? fallbackCode,
}) {
  if (error is Failure) return error;

  return switch (error) {
    AppException(:final message, :final code) => CacheFailure(
        message: _display(message, fallbackMessage),
        code: code ?? fallbackCode,
      ),
    FormatException() || TypeError() => UnexpectedFailure(
        message: 'unexpected_error'.tr(),
        code: fallbackCode,
      ),
    _ => CacheFailure(message: fallbackMessage.tr(), code: fallbackCode),
  };
}

String _display(String message, String fallbackKey) =>
    message.trim().isEmpty ? fallbackKey.tr() : message.tr();
