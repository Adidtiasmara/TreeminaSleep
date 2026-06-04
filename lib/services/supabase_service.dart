import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sleep_record_model.dart';
import '../models/sleep_schedule_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentAuthUser => client.auth.currentUser;
  static bool get isLoggedIn => currentAuthUser != null;

  static Future<void> init() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: url, anonKey: publishableKey);
  }

  static Future<UserModel?> getCurrentUser() async {
    final user = currentAuthUser;
    if (user == null) return null;

    final profile = await client
        .from('profiles')
        .select('name, email, age')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      return UserModel(
        name: user.userMetadata?['name']?.toString() ?? 'Pengguna',
        email: user.email ?? '',
        age: null,
      );
    }

    return UserModel.fromMap(profile);
  }

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Registrasi gagal. Silakan coba lagi.');
    }

    if (response.session != null) {
      await client.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'email': email,
        'age': null,
      });

      await client.from('sleep_schedules').upsert({
        'user_id': user.id,
        'target_sleep_time': '22:00',
        'target_wake_time': '05:30',
      });
    }

    return response.session != null;
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> logout() async {
    await client.auth.signOut();
  }

  static Future<void> updateAge(int age) async {
    final userId = _requireUserId();
    await client.from('profiles').update({'age': age}).eq('id', userId);
  }

  static Future<int?> getAge() async {
    return (await getCurrentUser())?.age;
  }

  static Future<SleepSchedule> getSleepSchedule() async {
    final userId = _requireUserId();
    final row = await client
        .from('sleep_schedules')
        .select('target_sleep_time, target_wake_time')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) {
      final schedule = SleepSchedule(
        targetSleepTime: '22:00',
        targetWakeTime: '05:30',
      );
      await saveSleepSchedule(schedule);
      return schedule;
    }

    return SleepSchedule.fromMap({
      'targetSleepTime': row['target_sleep_time'],
      'targetWakeTime': row['target_wake_time'],
    });
  }

  static Future<void> saveSleepSchedule(SleepSchedule schedule) async {
    final userId = _requireUserId();
    await client.from('sleep_schedules').upsert({
      'user_id': userId,
      'target_sleep_time': schedule.targetSleepTime,
      'target_wake_time': schedule.targetWakeTime,
    });
  }

  static Future<List<SleepRecord>> getSleepRecords() async {
    final userId = _requireUserId();
    final rows = await client
        .from('sleep_records')
        .select(
          'id, record_date, sleep_start, wake_up, duration_minutes, status',
        )
        .eq('user_id', userId)
        .order('record_date', ascending: false);

    return rows
        .map(
          (row) => SleepRecord.fromMap({
            'id': row['id'],
            'date': row['record_date'],
            'sleepStart': row['sleep_start'],
            'wakeUp': row['wake_up'],
            'durationMinutes': row['duration_minutes'],
            'status': row['status'],
          }),
        )
        .toList();
  }

  static Future<void> addSleepRecord(SleepRecord record) async {
    final userId = _requireUserId();
    await client.from('sleep_records').insert({
      'id': record.id,
      'user_id': userId,
      'record_date': record.date.toIso8601String(),
      'sleep_start': record.sleepStart.toIso8601String(),
      'wake_up': record.wakeUp.toIso8601String(),
      'duration_minutes': record.durationMinutes,
      'status': record.status,
    });
  }

  static Future<DateTime?> getSleepStart() async {
    final userId = _requireUserId();
    final row = await client
        .from('active_sleep_sessions')
        .select('sleep_start')
        .eq('user_id', userId)
        .maybeSingle();

    final sleepStart = row?['sleep_start'];
    if (sleepStart == null) return null;
    return DateTime.parse(sleepStart.toString());
  }

  static Future<void> setSleepStart(DateTime time) async {
    final userId = _requireUserId();
    await client.from('active_sleep_sessions').upsert({
      'user_id': userId,
      'sleep_start': time.toIso8601String(),
    });
  }

  static Future<void> clearSleepSession() async {
    final userId = _requireUserId();
    await client.from('active_sleep_sessions').delete().eq('user_id', userId);
  }

  static Future<UploadedMusic?> getCustomMusic() async {
    final userId = _requireUserId();
    final row = await client
        .from('user_music_tracks')
        .select('file_name, public_url')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return null;
    return UploadedMusic(
      fileName: row['file_name']?.toString() ?? 'Lagu sendiri',
      url: row['public_url']?.toString() ?? '',
    );
  }

  static Future<UploadedMusic> uploadCustomMusic(String filePath) async {
    final userId = _requireUserId();
    final file = File(filePath);
    final fileName = file.path.split('/').last;
    final extension = fileName.contains('.') ? fileName.split('.').last : 'mp3';
    final storagePath =
        '$userId/custom_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final bytes = await file.readAsBytes();

    await client.storage.from('sleep-music').uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _audioContentType(extension),
          ),
        );

    final publicUrl =
        client.storage.from('sleep-music').getPublicUrl(storagePath);

    await client.from('user_music_tracks').upsert({
      'user_id': userId,
      'file_name': fileName,
      'storage_path': storagePath,
      'public_url': publicUrl,
    });

    return UploadedMusic(fileName: fileName, url: publicUrl);
  }

  static String _audioContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'm4a':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'aac':
        return 'audio/aac';
      default:
        return 'audio/mpeg';
    }
  }

  static String _requireUserId() {
    final userId = currentAuthUser?.id;
    if (userId == null) {
      throw const AuthException('User belum login.');
    }
    return userId;
  }
}

class UploadedMusic {
  final String fileName;
  final String url;

  const UploadedMusic({required this.fileName, required this.url});
}
