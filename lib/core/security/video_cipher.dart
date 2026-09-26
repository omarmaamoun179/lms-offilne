import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../exceptions/app_exceptions.dart';

class VideoCipher {
  VideoCipher._();

  static const List<int> magic = [0x54, 0x48, 0x56, 0x31];
  static const int headerLength = 24;
  static const int tagLength = 16;
  static const int defaultChunkSize = 64 * 1024;

  static Uint8List encrypt(
    Uint8List plain,
    Uint8List key, {
    int chunkSize = defaultChunkSize,
    Random? random,
  }) {
    final source = random ?? Random.secure();
    final salt = Uint8List.fromList([
      for (var i = 0; i < 8; i++) source.nextInt(256),
    ]);
    final header = ByteData(headerLength);
    for (var i = 0; i < magic.length; i++) {
      header.setUint8(i, magic[i]);
    }
    header.setUint32(4, chunkSize);
    header.setUint64(8, plain.length);
    final headerBytes = header.buffer.asUint8List();
    headerBytes.setRange(16, 24, salt);

    final out = BytesBuilder(copy: false)..add(headerBytes);
    for (var index = 0, offset = 0;
        offset < plain.length;
        index++, offset += chunkSize) {
      final end = min(offset + chunkSize, plain.length);
      out.add(
        _cipher(true, key, salt, index, headerBytes)
            .process(Uint8List.sublistView(plain, offset, end)),
      );
    }
    return out.takeBytes();
  }

  static GCMBlockCipher _cipher(
    bool forEncryption,
    Uint8List key,
    Uint8List salt,
    int index,
    Uint8List header,
  ) {
    final nonce = Uint8List(12)..setRange(0, 8, salt);
    ByteData.sublistView(nonce).setUint32(8, index);
    return GCMBlockCipher(AESEngine())
      ..init(
        forEncryption,
        AEADParameters(KeyParameter(key), tagLength * 8, nonce, header),
      );
  }
}

class EncryptedVideo {
  final Uint8List _data;
  final Uint8List _key;
  final Uint8List _header;
  final Uint8List _salt;
  final int chunkSize;
  final int length;
  final Map<int, Uint8List> _cache = {};

  EncryptedVideo._(
    this._data,
    this._key,
    this._header,
    this._salt,
    this.chunkSize,
    this.length,
  );

  factory EncryptedVideo.open(Uint8List data, Uint8List key) {
    if (data.length < VideoCipher.headerLength) throw const MediaException();
    for (var i = 0; i < VideoCipher.magic.length; i++) {
      if (data[i] != VideoCipher.magic[i]) throw const MediaException();
    }

    final header = Uint8List.sublistView(data, 0, VideoCipher.headerLength);
    final fields = ByteData.sublistView(header);
    final chunkSize = fields.getUint32(4);
    final length = fields.getUint64(8);
    if (chunkSize == 0) throw const MediaException();

    final chunks = (length + chunkSize - 1) ~/ chunkSize;
    final expected =
        VideoCipher.headerLength + length + chunks * VideoCipher.tagLength;
    if (data.length != expected) throw const MediaException();

    final video = EncryptedVideo._(
      data,
      key,
      header,
      Uint8List.sublistView(header, 16, 24),
      chunkSize,
      length,
    );
    if (chunks > 0) {
      video._chunk(0);
      video._chunk(chunks - 1);
    }
    return video;
  }

  Uint8List read(int start, int end) {
    if (start < 0 || end > length || start > end) {
      throw RangeError.range(start, 0, length);
    }

    final out = BytesBuilder(copy: false);
    var position = start;
    while (position < end) {
      final index = position ~/ chunkSize;
      final chunk = _chunk(index);
      final from = position - index * chunkSize;
      final to = min(chunk.length, end - index * chunkSize);
      out.add(Uint8List.sublistView(chunk, from, to));
      position = index * chunkSize + to;
    }
    return out.takeBytes();
  }

  Uint8List _chunk(int index) {
    final cached = _cache[index];
    if (cached != null) return cached;

    final plainStart = index * chunkSize;
    final plainLength = min(chunkSize, length - plainStart);
    final offset = VideoCipher.headerLength +
        index * (chunkSize + VideoCipher.tagLength);
    final sealed = Uint8List.sublistView(
      _data,
      offset,
      offset + plainLength + VideoCipher.tagLength,
    );

    final Uint8List plain;
    try {
      plain =
          VideoCipher._cipher(false, _key, _salt, index, _header).process(sealed);
    } on InvalidCipherTextException {
      throw const MediaException();
    } on ArgumentError {
      throw const MediaException();
    }

    if (_cache.length >= 4) _cache.remove(_cache.keys.first);
    _cache[index] = plain;
    return plain;
  }
}
