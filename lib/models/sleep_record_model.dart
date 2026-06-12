class SleepRecord {
  final String id;
  final DateTime date;
  final DateTime sleepStart;
  final DateTime wakeUp;
  final int durationMinutes;
  final String status; // 'Bad Sleep', 'Excellent Sleep', 'Over Sleep'

  SleepRecord({
    required this.id,
    required this.date,
    required this.sleepStart,
    required this.wakeUp,
    required this.durationMinutes,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'sleepStart': sleepStart.toIso8601String(),
        'wakeUp': wakeUp.toIso8601String(),
        'durationMinutes': durationMinutes,
        'status': status,
      };

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value.toLocal();
    return DateTime.parse(value.toString()).toLocal();
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) => SleepRecord(
        id: map['id'] ?? '',
        date: _parseDateTime(map['date']),
        sleepStart: _parseDateTime(map['sleepStart']),
        wakeUp: _parseDateTime(map['wakeUp']),
        durationMinutes: map['durationMinutes'] ?? 0,
        status: map['status'] ?? 'Bad Sleep',
      );
}
