import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/sleep_record_model.dart';
import '../models/sleep_schedule_model.dart';

class StorageService {
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keySleepSchedule = 'sleep_schedule';
  static const String _keySleepRecords = 'sleep_records';
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySelectedMusic = 'selected_music';
  static const String _keyCustomMusicPath = 'custom_music_path';
  static const String _keyAge = 'user_age';
  static const String _keyCurrentSleepStart = 'current_sleep_start';
  static const String _keyIsSleeping = 'is_sleeping';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // ── User ──────────────────────────────────────────────
  static Future<void> saveUser(UserModel user) async {
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
  }

  static UserModel? getUser() {
    final data = prefs.getString(_keyUser);
    if (data == null) return null;
    return UserModel.fromMap(jsonDecode(data));
  }

  static Future<void> setLoggedIn(bool value) async {
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static bool isLoggedIn() => prefs.getBool(_keyIsLoggedIn) ?? false;

  // ── Sleep Schedule ────────────────────────────────────
  static Future<void> saveSleepSchedule(SleepSchedule schedule) async {
    await prefs.setString(_keySleepSchedule, jsonEncode(schedule.toMap()));
  }

  static SleepSchedule getSleepSchedule() {
    final data = prefs.getString(_keySleepSchedule);
    if (data == null)
      return SleepSchedule(targetSleepTime: '22:00', targetWakeTime: '05:30');
    return SleepSchedule.fromMap(jsonDecode(data));
  }

  // ── Sleep Records ─────────────────────────────────────
  static Future<void> saveSleepRecords(List<SleepRecord> records) async {
    final list = records.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_keySleepRecords, list);
  }

  static List<SleepRecord> getSleepRecords() {
    final list = prefs.getStringList(_keySleepRecords) ?? [];
    return list.map((s) => SleepRecord.fromMap(jsonDecode(s))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addSleepRecord(SleepRecord record) async {
    final records = getSleepRecords();
    records.add(record);
    await saveSleepRecords(records);
  }

  // ── Active Sleep Session ──────────────────────────────
  static Future<void> setSleepStart(DateTime time) async {
    await prefs.setString(_keyCurrentSleepStart, time.toIso8601String());
    await prefs.setBool(_keyIsSleeping, true);
  }

  static DateTime? getSleepStart() {
    final data = prefs.getString(_keyCurrentSleepStart);
    if (data == null) return null;
    return DateTime.parse(data);
  }

  static bool isSleeping() => prefs.getBool(_keyIsSleeping) ?? false;

  static Future<void> clearSleepSession() async {
    await prefs.remove(_keyCurrentSleepStart);
    await prefs.setBool(_keyIsSleeping, false);
  }

  // ── Settings ──────────────────────────────────────────
  static Future<void> setNotificationEnabled(bool value) async {
    await prefs.setBool(_keyNotificationEnabled, value);
  }

  static bool isNotificationEnabled() =>
      prefs.getBool(_keyNotificationEnabled) ?? true;

  static Future<void> setThemeMode(String mode) async {
    await prefs.setString(_keyThemeMode, mode);
  }

  static String getThemeMode() => prefs.getString(_keyThemeMode) ?? 'system';

  static Future<void> setSelectedMusic(String music) async {
    await prefs.setString(_keySelectedMusic, music);
  }

  static String getSelectedMusic() => prefs.getString(_keySelectedMusic) ?? '';

  static Future<void> setCustomMusicPath(String path) async {
    await prefs.setString(_keyCustomMusicPath, path);
  }

  static String getCustomMusicPath() =>
      prefs.getString(_keyCustomMusicPath) ?? '';

  static Future<void> setAge(int age) async {
    await prefs.setInt(_keyAge, age);
  }

  static int? getAge() => prefs.getInt(_keyAge);

  // ── Logout ────────────────────────────────────────────
  static Future<void> logout() async {
    await prefs.setBool(_keyIsLoggedIn, false);
    await clearSleepSession();
  }
}
