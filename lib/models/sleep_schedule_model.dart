class SleepSchedule {
  final String? id;
  final String name;
  final String targetSleepTime; // Format "HH:mm"
  final String targetWakeTime; // Format "HH:mm"
  final DateTime? createdAt;

  SleepSchedule({
    this.id,
    this.name = 'Jadwal Tidur',
    required this.targetSleepTime,
    required this.targetWakeTime,
    this.createdAt,
  });

  factory SleepSchedule.fromDeviceClock() {
    final now = DateTime.now();
    final wake = now.add(const Duration(hours: 7, minutes: 30));
    return SleepSchedule(
      name: 'Jadwal Device',
      targetSleepTime: _formatDateTime(now),
      targetWakeTime: _formatDateTime(wake),
    );
  }

  static String _formatDateTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool get isFactoryDefault =>
      targetSleepTime == '22:00' && targetWakeTime == '05:30';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'targetSleepTime': targetSleepTime,
        'targetWakeTime': targetWakeTime,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory SleepSchedule.fromMap(Map<String, dynamic> map) => SleepSchedule(
        id: map['id']?.toString(),
        name: map['name']?.toString() ?? 'Jadwal Tidur',
        targetSleepTime: map['targetSleepTime'] ?? '22:00',
        targetWakeTime: map['targetWakeTime'] ?? '05:30',
        createdAt: map['createdAt'] == null
            ? null
            : DateTime.tryParse(map['createdAt'].toString()),
      );

  SleepSchedule copyWith({
    String? id,
    String? name,
    String? targetSleepTime,
    String? targetWakeTime,
    DateTime? createdAt,
  }) {
    return SleepSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      targetSleepTime: targetSleepTime ?? this.targetSleepTime,
      targetWakeTime: targetWakeTime ?? this.targetWakeTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
