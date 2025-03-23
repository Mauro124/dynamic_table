extension DoubleExtension on double {
  String get timeMmSs {
    final int minutes = (this / 60000).truncate();
    final int seconds = ((this % 60000) / 1000).round();
    return '$minutes:${seconds < 10 ? '0' : ''}$seconds';
  }
}
