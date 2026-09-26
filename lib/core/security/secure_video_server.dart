import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../utils/app_logger.dart';
import 'video_cipher.dart';

class SecureVideoServer {
  static const int _kept = 2;
  static const int _slice = 64 * 1024;

  final String _token = List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final Map<String, EncryptedVideo> _videos = {};
  Future<HttpServer>? _server;

  Future<Uri> register(String id, EncryptedVideo video) async {
    final server = await (_server ??= _start());
    _videos.remove(id);
    _videos[id] = video;
    while (_videos.length > _kept) {
      _videos.remove(_videos.keys.first);
    }
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: server.port,
      pathSegments: [_token, '$id.mp4'],
    );
  }

  Future<void> close() async {
    final server = _server;
    _server = null;
    _videos.clear();
    if (server != null) await (await server).close(force: true);
  }

  Future<HttpServer> _start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
    return server;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      final video = _videoFor(request.uri);
      if (video == null) {
        response.statusCode = HttpStatus.notFound;
        return;
      }
      if (request.method != 'GET' && request.method != 'HEAD') {
        response.statusCode = HttpStatus.methodNotAllowed;
        return;
      }

      final length = video.length;
      final range = _range(request.headers.value(HttpHeaders.rangeHeader), length);
      response.headers
        ..contentType = ContentType('video', 'mp4')
        ..set(HttpHeaders.acceptRangesHeader, 'bytes')
        ..set(HttpHeaders.cacheControlHeader, 'no-store');

      if (range == null) {
        response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        response.headers.set(HttpHeaders.contentRangeHeader, 'bytes */$length');
        return;
      }

      final (start, end) = range;
      final partial = request.headers.value(HttpHeaders.rangeHeader) != null;
      response.statusCode = partial ? HttpStatus.partialContent : HttpStatus.ok;
      response.contentLength = end - start;
      if (partial) {
        response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-${end - 1}/$length',
        );
      }
      if (request.method == 'HEAD') return;

      for (var position = start; position < end; position += _slice) {
        response.add(video.read(position, min(position + _slice, end)));
        await response.flush();
      }
    } catch (e, s) {
      logError(e, s, reason: 'SecureVideoServer.handle');
    } finally {
      await response.close().catchError((_) {});
    }
  }

  EncryptedVideo? _videoFor(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length != 2 || segments.first != _token) return null;
    final name = segments.last;
    if (!name.endsWith('.mp4')) return null;
    return _videos[name.substring(0, name.length - 4)];
  }

  static (int, int)? _range(String? header, int length) {
    if (header == null) return (0, length);

    final match = RegExp(r'^bytes=(\d*)-(\d*)').firstMatch(header.trim());
    if (match == null) return null;
    final first = match.group(1)!;
    final last = match.group(2)!;

    if (first.isEmpty) {
      final suffix = int.tryParse(last);
      if (suffix == null || suffix == 0) return null;
      return (max(0, length - suffix), length);
    }

    final start = int.parse(first);
    final end = last.isEmpty ? length - 1 : min(int.parse(last), length - 1);
    if (start >= length || start > end) return null;
    return (start, end + 1);
  }
}
