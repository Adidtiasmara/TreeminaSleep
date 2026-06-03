class SleepSchedule {
  final String targetSleepTime; // Format "HH:mm"
  final String targetWakeTime; // Format "HH:mm"

  SleepSchedule({required this.targetSleepTime, required this.targetWakeTime});

  Map<String, dynamic> toMap() => {
    'targetSleepTime': targetSleepTime,
    'targetWakeTime': targetWakeTime,
  };

  factory SleepSchedule.fromMap(Map<String, dynamic> map) => SleepSchedule(
    targetSleepTime: map['targetSleepTime'] ?? '22:00',
    targetWakeTime: map['targetWakeTime'] ?? '05:30',
  );

  SleepSchedule copyWith({String? targetSleepTime, String? targetWakeTime}) {
    return SleepSchedule(
      targetSleepTime: targetSleepTime ?? this.targetSleepTime,
      targetWakeTime: targetWakeTime ?? this.targetWakeTime,
    );
  }
}
