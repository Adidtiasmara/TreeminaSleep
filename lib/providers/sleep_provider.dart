import 'package:flutter/material.dart';
import '../models/sleep_record_model.dart';
import '../models/sleep_schedule_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../utils/sleep_calculator.dart';

class SleepProvider extends ChangeNotifier {
  List<SleepRecord> _records = [];
  SleepSchedule _schedule = SleepSchedule(
    targetSleepTime: '22:00',
    targetWakeTime: '05:30',
  );
  bool _isSleeping = false;
  DateTime? _sleepStart;
  SleepRecord? _lastRecord;

  List<SleepRecord> get records => _records;
  SleepSchedule get schedule => _schedule;
  bool get isSleeping => _isSleeping;
  DateTime? get sleepStart => _sleepStart;
  SleepRecord? get lastRecord => _lastRecord;

  SleepProvider() {
    _load();
  }

  Future<void> _load() async {
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      _records = await SupabaseService.getSleepRecords();
      _schedule = await SupabaseService.getSleepSchedule();
      _sleepStart = await SupabaseService.getSleepStart();
      _isSleeping = _sleepStart != null;
    } else {
      _records = StorageService.getSleepRecords();
      _schedule = StorageService.getSleepSchedule();
      _isSleeping = StorageService.isSleeping();
      _sleepStart = StorageService.getSleepStart();
    }
    if (_records.isNotEmpty) _lastRecord = _records.first;
    notifyListeners();
  }

  Future<void> updateSchedule(SleepSchedule schedule) async {
    _schedule = schedule;
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.saveSleepSchedule(schedule);
    } else {
      await StorageService.saveSleepSchedule(schedule);
    }
    notifyListeners();
  }

  Future<void> startSleep() async {
    final now = DateTime.now();
    _sleepStart = now;
    _isSleeping = true;
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.setSleepStart(now);
    } else {
      await StorageService.setSleepStart(now);
    }
    notifyListeners();
  }

  Future<SleepRecord?> wakeUp() async {
    if (_sleepStart == null) return null;
    final now = DateTime.now();
    final duration = SleepCalculator.calculateDurationMinutes(
      _sleepStart!,
      now,
    );
    final status = SleepCalculator.getSleepStatus(duration);

    final record = SleepRecord(
      id: now.millisecondsSinceEpoch.toString(),
      date: now,
      sleepStart: _sleepStart!,
      wakeUp: now,
      durationMinutes: duration,
      status: status,
    );

    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.addSleepRecord(record);
    } else {
      await StorageService.addSleepRecord(record);
    }
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.clearSleepSession();
    } else {
      await StorageService.clearSleepSession();
    }

    _records = SupabaseService.isConfigured && SupabaseService.isLoggedIn
        ? await SupabaseService.getSleepRecords()
        : StorageService.getSleepRecords();
    _lastRecord = record;
    _isSleeping = false;
    _sleepStart = null;

    notifyListeners();
    return record;
  }

  Future<void> refreshRecords() async {
    _records = SupabaseService.isConfigured && SupabaseService.isLoggedIn
        ? await SupabaseService.getSleepRecords()
        : StorageService.getSleepRecords();
    if (_records.isNotEmpty) _lastRecord = _records.first;
    notifyListeners();
  }

  /// Ambil data 7 hari terakhir untuk grafik
  List<SleepRecord> getWeeklyRecords() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _records.where((r) => r.date.isAfter(weekAgo)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
