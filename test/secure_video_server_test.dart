import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/security/secure_video_server.dart';
import 'package:lms_offline/core/security/video_cipher.dart';
import 'package:lms_offline/core/security/video_key.dart';

Future<(int, Map<String, String>, Uint8List)> _request(
  Uri uri, {
  String method = 'GET',
  String? range,
}) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(method, uri);
    if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
    final response = await request.close();
    final builder = BytesBuilder(copy: false);
    await response.forEach(builder.add);
    final headers = <String, String>{};
    response.headers.forEach((name, values) => headers[name] = values.join(','));
    return (response.statusCode, headers, builder.takeBytes());
  } finally {
    client.close(force: true);
  }
}

void main() {
  final random = Random(7);
  final plain = Uint8List.fromList([for (var i = 0; i < 5000; i++) random.nextInt(256)]);
  late SecureVideoServer server;
  late Uri uri;

  setUp(() async {
    server = SecureVideoServer();
    final sealed = VideoCipher.encrypt(plain, videoKey(), chunkSize: 1024);
    uri = await server.register('lesson', EncryptedVideo.open(sealed, videoKey()));
  });

  tearDown(() => server.close());

  test('listens on loopback only, behind a random token', () {
    expect(uri.host, '127.0.0.1');
    expect(uri.pathSegments.first, hasLength(32));
    expect(uri.path, endsWith('/lesson.mp4'));
  });

  test('serves the whole decrypted video', () async {
    final (status, headers, body) = await _request(uri);

    expect(status, 200);
    expect(headers['content-type'], 'video/mp4');
    expect(headers['accept-ranges'], 'bytes');
    expect(body, plain);
  });

  test('answers byte ranges the way video players ask for them', () async {
    final (first, firstHeaders, firstBody) = await _request(uri, range: 'bytes=0-1');
    final (_, _, tail) = await _request(uri, range: 'bytes=4990-');
    final (_, _, suffix) = await _request(uri, range: 'bytes=-10');

    expect(first, 206);
    expect(firstHeaders['content-range'], 'bytes 0-1/5000');
    expect(firstBody, plain.sublist(0, 2));
    expect(tail, plain.sublist(4990));
    expect(suffix, plain.sublist(4990));
  });

  test('a HEAD request reports the size without the video', () async {
    final (status, headers, body) = await _request(uri, method: 'HEAD');

    expect(status, 200);
    expect(headers['content-length'], '5000');
    expect(body, isEmpty);
  });

  test('refuses other paths and impossible ranges', () async {
    final wrongToken = uri.replace(pathSegments: ['0' * 32, 'lesson.mp4']);
    final (missing, _, _) = await _request(wrongToken);
    final (outside, headers, _) = await _request(uri, range: 'bytes=9000-9100');

    expect(missing, 404);
    expect(outside, 416);
    expect(headers['content-range'], 'bytes */5000');
  });
}
