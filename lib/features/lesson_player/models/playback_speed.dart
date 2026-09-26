class PlaybackSpeed {
  PlaybackSpeed._();

  static const double normal = 1;
  static const List<double> options = [1, 1.25, 1.5, 2];

  static String label(double speed) {
    final whole = speed == speed.roundToDouble();
    return '${whole ? speed.toInt() : speed}x';
  }

  static double after(double speed) {
    final index = options.indexOf(speed);
    return options[(index + 1) % options.length];
  }
}
