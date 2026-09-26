import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/exceptions/app_exceptions.dart';
import 'package:lms_offline/core/security/video_cipher.dart';
import 'package:lms_offline/core/security/video_key.dart';

Uint8List _bytes(int length, int seed) {
  final random = Random(seed);
  return Uint8List.fromList([for (var i = 0; i < length; i++) random.nextInt(256)]);
}

void main() {
  final key = videoKey();
  final plain = _bytes(10000, 1);
  final sealed = VideoCipher.encrypt(plain, key, chunkSize: 1024);

  test('the key is 256 bits', () {
    expect(key, hasLength(32));
  });

  test('the encrypted file shares nothing readable with the video', () {
    expect(sealed.sublist(0, 4), VideoCipher.magic);
    expect(sealed.length, greaterThan(plain.length));
    expect(
      sealed.sublist(VideoCipher.headerLength, VideoCipher.headerLength + 64),
      isNot(plain.sublist(0, 64)),
    );
  });

  test('any byte range decrypts to exactly the same bytes', () {
    final video = EncryptedVideo.open(sealed, key);

    expect(video.length, plain.length);
    expect(video.read(0, plain.length), plain);
    for (final (start, end) in [(0, 1), (1000, 1100), (1023, 1025), (9990, 10000)]) {
      expect(video.read(start, end), plain.sublist(start, end), reason: '$start-$end');
    }
  });

  test('encrypting twice gives different files', () {
    expect(VideoCipher.encrypt(plain, key, chunkSize: 1024), isNot(sealed));
  });

  test('a changed byte is rejected when its chunk is read', () {
    final tampered = Uint8List.fromList(sealed)
      ..[VideoCipher.headerLength + 3 * (1024 + VideoCipher.tagLength) + 5] ^= 1;
    final video = EncryptedVideo.open(tampered, key);

    expect(() => video.read(3000, 3100), throwsA(isA<MediaException>()));
  });

  test('a wrong key, a cut file or a plain video cannot be opened', () {
    final wrongKey = Uint8List.fromList(key)..[0] ^= 1;

    expect(() => EncryptedVideo.open(sealed, wrongKey), throwsA(isA<MediaException>()));
    expect(
      () => EncryptedVideo.open(Uint8List.sublistView(sealed, 0, sealed.length - 10), key),
      throwsA(isA<MediaException>()),
    );
    expect(() => EncryptedVideo.open(plain, key), throwsA(isA<MediaException>()));
  });
}
