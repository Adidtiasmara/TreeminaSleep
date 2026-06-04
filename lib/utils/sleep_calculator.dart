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

  static SleepRecommendation getRecommendationForAge(int age) {
    if (age < 1) {
      return const SleepRecommendation(
        label: 'Newborn 0-3 bulan: 14-17 jam; Infant 4-11 bulan: 12-15 jam',
        minHours: 14,
        maxHours: 17,
        source: 'NSF 2015',
      );
    }
    if (age <= 2) {
      return const SleepRecommendation(
        label: 'Toddler 1-2 tahun',
        minHours: 11,
        maxHours: 14,
        source: 'NSF 2015',
      );
    }
    if (age <= 5) {
      return const SleepRecommendation(
        label: 'Preschool 3-5 tahun',
        minHours: 10,
        maxHours: 13,
        source: 'NSF 2015',
      );
    }
    if (age <= 13) {
      return const SleepRecommendation(
        label: 'School-age 6-13 tahun',
        minHours: 9,
        maxHours: 11,
        source: 'NSF 2015',
      );
    }
    if (age <= 17) {
      return const SleepRecommendation(
        label: 'Teenager 14-17 tahun',
        minHours: 8,
        maxHours: 10,
        source: 'NSF 2015',
      );
    }
    if (age <= 25) {
      return const SleepRecommendation(
        label: 'Young adult 18-25 tahun',
        minHours: 7,
        maxHours: 9,
        source: 'NSF 2015',
      );
    }
    if (age <= 64) {
      return const SleepRecommendation(
        label: 'Adult 26-64 tahun',
        minHours: 7,
        maxHours: 9,
        source: 'NSF 2015',
      );
    }
    return const SleepRecommendation(
      label: 'Older adult 65+ tahun',
      minHours: 7,
      maxHours: 8,
      source: 'NSF 2015',
    );
  }
}

class SleepRecommendation {
  final String label;
  final int minHours;
  final int maxHours;
  final String source;

  const SleepRecommendation({
    required this.label,
    required this.minHours,
    required this.maxHours,
    required this.source,
  });

  String get rangeText => '$minHours-$maxHours jam';
}
