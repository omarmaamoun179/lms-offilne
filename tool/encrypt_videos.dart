import 'dart:io';

import 'package:lms_offline/core/security/video_cipher.dart';
import 'package:lms_offline/core/security/video_key.dart';

void main() {
  final source = Directory('media/videos');
  if (!source.existsSync()) {
    stderr.writeln('Run from the repository root: media/videos is missing.');
    exitCode = 1;
    return;
  }

  final key = videoKey();
  final videos = source
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.mp4'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final video in videos) {
    final relative = video.path.substring(source.path.length + 1);
    final target = File(
      'assets/videos/${relative.substring(0, relative.length - 4)}.enc',
    );
    target.parent.createSync(recursive: true);
    target.writeAsBytesSync(VideoCipher.encrypt(video.readAsBytesSync(), key));
    stdout.writeln('${video.path} -> ${target.path}');
  }
}
