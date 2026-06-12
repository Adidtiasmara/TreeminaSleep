import 'package:flutter/material.dart';
import '../models/sleep_record_model.dart';
import '../models/sleep_schedule_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../utils/sleep_calculator.dart';

class SleepProvider extends ChangeNotifier {
  List<SleepRecord> _records = [];
  List<SleepSchedule> _savedSchedules = [];
  SleepSchedule _schedule = SleepSchedule.fromDeviceClock();
  bool _isSleeping = false;
  DateTime? _sleepStart;
  SleepRecord? _lastRecord;

  List<SleepRecord> get records => _records;
  List<SleepSchedule> get savedSchedules => _savedSchedules;
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
      _savedSchedules = await SupabaseService.getSavedSleepSchedules();
      _sleepStart = await SupabaseService.getSleepStart();
      _isSleeping = _sleepStart != null;
    } else {
      _records = StorageService.getSleepRecords();
      _schedule = StorageService.getSleepSchedule();
      _savedSchedules = StorageService.getSavedSleepSchedules();
      _isSleeping = StorageService.isSleeping();
      _sleepStart = StorageService.getSleepStart();
    }
    if (_isSleeping &&
        _sleepStart != null &&
        StorageService.isNotificationEnabled()) {
      await NotificationService.showSleepSessionNotification(_sleepStart!);
    }
    await _useDeviceClockForFirstSchedule();
    if (_records.isNotEmpty) _lastRecord = _records.first;
    notifyListeners();
  }

  Future<void> _useDeviceClockForFirstSchedule() async {
    if (_records.isNotEmpty || !_schedule.isFactoryDefault) return;
    _schedule = SleepSchedule.fromDeviceClock();
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.saveSleepSchedule(_schedule);
    } else {
      await StorageService.saveSleepSchedule(_schedule);
    }
  }

  Future<void> updateSchedule(SleepSchedule schedule) async {
    _schedule = schedule;
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.saveSleepSchedule(schedule);
    } else {
      await StorageService.saveSleepSchedule(schedule);
    }
    if (StorageService.isNotificationEnabled()) {
      try {
        await NotificationService.scheduleSleepPlanReminder(
          schedule.targetSleepTime,
          schedule.targetWakeTime,
        );
      } catch (_) {
        // Jadwal utama tetap tersimpan meskipun izin/cache notifikasi bermasalah.
      }
    } else {
      await NotificationService.cancelSleepPlanReminder();
    }
    notifyListeners();
  }

  Future<void> saveScheduleToList(SleepSchedule schedule) async {
    final saved = SupabaseService.isConfigured && SupabaseService.isLoggedIn
        ? await SupabaseService.addSavedSleepSchedule(schedule)
        : await StorageService.addSavedSleepSchedule(schedule);
    _savedSchedules = [saved, ..._savedSchedules]
      ..removeWhere((item) => item.id == saved.id && item != saved);
    notifyListeners();
  }

  Future<void> useSavedSchedule(SleepSchedule schedule) async {
    await updateSchedule(schedule);
  }

  Future<void> deleteSavedSchedule(SleepSchedule schedule) async {
    final id = schedule.id;
    if (id == null) return;
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.deleteSavedSleepSchedule(id);
    } else {
      await StorageService.deleteSavedSleepSchedule(id);
    }
    _savedSchedules = _savedSchedules.where((item) => item.id != id).toList();
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
    if (StorageService.isNotificationEnabled()) {
      await NotificationService.requestPermission();
      await NotificationService.showSleepSessionNotification(now);
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
    await NotificationService.cancelSleepSessionNotification();

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

  Future<void> resetSleepData() async {
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.clearSleepRecords();
      await SupabaseService.clearSleepSession();
    }
    await StorageService.clearSleepRecords();
    await StorageService.clearSleepSession();
    await NotificationService.cancelSleepSessionNotification();

    _records = [];
    _lastRecord = null;
    _isSleeping = false;
    _sleepStart = null;

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
