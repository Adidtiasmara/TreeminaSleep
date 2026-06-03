class SleepCalculator {
  /// Hitung durasi tidur dalam menit
  /// Mendukung tidur yang melewati tengah malam
  static int calculateDurationMinutes(DateTime start, DateTime end) {
    Duration diff = end.difference(start);
    // Jika negatif (misal: bangun keesokan harinya tapi end < start)
    if (diff.isNegative) {
      diff = end.add(const Duration(days: 1)).difference(start);
    }
    return diff.inMinutes;
  }

  /// Format durasi dari menit ke string "X jam Y menit"
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins menit';
    if (mins == 0) return '$hours jam';
    return '$hours jam $mins menit';
  }

  /// Format durasi dalam bentuk desimal jam (misal 7.5)
  static double durationInHours(int minutes) {
    return minutes / 60.0;
  }

  /// Tentukan status tidur berdasarkan durasi
  static String getSleepStatus(int durationMinutes) {
    final hours = durationMinutes / 60.0;
    if (hours < 7) return 'Bad Sleep';
    if (hours <= 8) return 'Excellent Sleep';
    return 'Over Sleep';
  }

  /// Pesan status tidur
  static String getSleepMessage(String status) {
    switch (status) {
      case 'Excellent Sleep':
        return 'Tidurmu cukup nyenyak! Pertahankan pola tidur yang baik.';
      case 'Bad Sleep':
        return 'Kamu kurang tidur hari ini. Cobalah tidur lebih awal malam ini.';
      case 'Over Sleep':
        return 'Kamu tidur lebih lama dari kebutuhan normal.';
      default:
        return '';
    }
  }
}
