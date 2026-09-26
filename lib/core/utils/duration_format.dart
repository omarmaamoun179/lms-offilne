extension DurationClock on Duration {
  String get clock {
    final minutes = inMinutes.remainder(60).toString();
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (inHours == 0) return '$minutes:$seconds';
    return '$inHours:${minutes.padLeft(2, '0')}:$seconds';
  }
}
