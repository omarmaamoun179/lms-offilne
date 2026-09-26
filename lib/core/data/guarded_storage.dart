import 'package:dartz/dartz.dart';

import '../domain/failure.dart';
import '../domain/failure_mapper.dart';
import '../utils/app_logger.dart';

Future<Either<Failure, T>> guardedStorage<T>(
  String reason,
  Future<T> Function() call, {
  String fallbackMessage = 'cache_error',
  String? fallbackCode,
}) async {
  try {
    return Right(await call());
  } catch (e, s) {
    logError(e, s, reason: reason);
    return Left(mapExceptionToFailure(
      e,
      fallbackMessage: fallbackMessage,
      fallbackCode: fallbackCode,
    ));
  }
}
