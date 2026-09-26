sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => '$runtimeType($code): $message';
}

class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(code: 'not_found');
}

class MediaException extends AppException {
  static const String sourceError = 'video_source_error';

  const MediaException([super.message = 'video_unavailable'])
      : super(code: sourceError);
}
