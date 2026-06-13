import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/sleep_provider.dart';
import '../providers/theme_provider.dart';
import '../services/music_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../utils/sleep_calculator.dart';
import '../widgets/theme_selector.dart';
import '../widgets/sleep_visuals.dart';
import 'about_app_page.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = true;
  String _selectedMusic = '';
  String _customMusicPath = '';
  String _customMusicName = '';
  List<UploadedMusic> _customMusics = const [];
  String _playingCustomMusicId = '';
  bool _isPlayingCustom = false;
  bool _isUploadingMusic = false;

  @override
  void initState() {
    super.initState();
    _notificationEnabled = StorageService.isNotificationEnabled();
    _selectedMusic = StorageService.getSelectedMusic();
    _customMusicPath = StorageService.getCustomMusicPath();
    _customMusicName =
        _customMusicPath.isEmpty ? '' : _customMusicPath.split('/').last;
    _loadCustomMusic();
  }

  Future<void> _loadCustomMusic() async {
    if (!SupabaseService.isConfigured || !SupabaseService.isLoggedIn) return;
    final musics = await SupabaseService.getCustomMusicTracks();
    if (!mounted) return;
    setState(() {
      _customMusics = musics;
      _customMusicPath = '';
    });
  }

  Future<void> _editAge() async {
    final profileProvider = context.read<ProfileProvider>();
    final controller = TextEditingController(
      text: profileProvider.age?.toString() ?? '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final age = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Usia Pengguna',
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Masukkan usia',
            suffixText: 'tahun',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < 0 || value > 120) return;
              Navigator.of(ctx).pop(value);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (age == null) return;
    await profileProvider.updateAge(age);
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() => _notificationEnabled = value);
    await StorageService.setNotificationEnabled(value);
    if (value) {
      await NotificationService.requestPermission();
      if (!mounted) return;
      await NotificationService.scheduleSleepPlanReminder(
        context.read<SleepProvider>().schedule.targetSleepTime,
        context.read<SleepProvider>().schedule.targetWakeTime,
      );
    } else {
      await NotificationService.cancelSleepPlanReminder();
    }
  }

  Future<void> _playBuiltIn(String trackId) async {
    await MusicService.playBuiltIn(trackId);
    setState(() {
      _selectedMusic = MusicService.isPlaying ? trackId : '';
      _isPlayingCustom = false;
      _playingCustomMusicId = '';
    });
    await StorageService.setSelectedMusic(_selectedMusic);
  }

  Future<void> _uploadLagu() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
      withData: true,
    );
    if (result != null) {
      final file = result.files.single;
      final path = file.path;
      setState(() => _isUploadingMusic = true);
      if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
        try {
          if (file.bytes == null && path == null) {
            throw Exception('File lagu tidak bisa dibaca dari perangkat ini.');
          }
          final uploaded = file.bytes != null
              ? await SupabaseService.uploadCustomMusicBytes(
                  bytes: file.bytes!,
                  fileName: file.name,
                )
              : await SupabaseService.uploadCustomMusic(path!);
          if (!mounted) return;
          setState(() {
            _customMusics = [uploaded, ..._customMusics];
            _customMusicPath = '';
            _customMusicName = '';
            _isPlayingCustom = false;
            _playingCustomMusicId = '';
            _selectedMusic = '';
            _isUploadingMusic = false;
          });
          await StorageService.setSelectedMusic('');
          return;
        } catch (e) {
          if (!mounted) return;
          setState(() => _isUploadingMusic = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Upload lagu gagal: ${e.toString()}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
          return;
        }
      }
      if (path == null) {
        if (!mounted) return;
        setState(() => _isUploadingMusic = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File lagu tidak bisa dibaca dari perangkat ini.'),
          ),
        );
        return;
      }
      setState(() {
        _customMusicPath = path;
        _customMusicName = path.split('/').last;
        _isPlayingCustom = false;
        _playingCustomMusicId = '';
        _isUploadingMusic = false;
      });
      await StorageService.setCustomMusicPath(path);
    }
  }

  Future<void> _toggleUploadedMusic(UploadedMusic music) async {
    if (_isPlayingCustom && _playingCustomMusicId == music.id) {
      await MusicService.pause();
      setState(() {
        _isPlayingCustom = false;
        _playingCustomMusicId = '';
      });
    } else {
      await MusicService.playCustomUrl(music.url);
      setState(() {
        _isPlayingCustom = true;
        _playingCustomMusicId = music.id;
        _selectedMusic = '';
      });
    }
  }

  Future<void> _toggleLocalCustomMusic() async {
    if (_customMusicPath.isEmpty) return;
    if (_isPlayingCustom && _playingCustomMusicId == 'local') {
      await MusicService.pause();
      setState(() {
        _isPlayingCustom = false;
        _playingCustomMusicId = '';
      });
    } else {
      await MusicService.playCustom(_customMusicPath);
      setState(() {
        _isPlayingCustom = true;
        _playingCustomMusicId = 'local';
        _selectedMusic = '';
      });
    }
  }

  Future<void> _deleteUploadedMusic(UploadedMusic music) async {
    try {
      final wasPlaying = _playingCustomMusicId == music.id;
      await SupabaseService.deleteCustomMusic(music);
      if (!mounted) return;
      setState(() {
        _customMusics =
            _customMusics.where((item) => item.id != music.id).toList();
        if (wasPlaying) {
          _isPlayingCustom = false;
          _playingCustomMusicId = '';
        }
      });
      if (wasPlaying) {
        await MusicService.stop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hapus lagu gagal: ${e.toString()}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Logout',
              style: TextStyle(
                color:
                    isDark ? AppColors.badSleepDark : AppColors.badSleepLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await MusicService.stop();
      if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
        await SupabaseService.logout();
      } else {
        await StorageService.logout();
      }
      if (!mounted) return;
      context.read<ProfileProvider>().clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  Future<void> _resetSleepData() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Reset Data Tidur',
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Semua riwayat tidur dan sesi tidur aktif akan dihapus.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Reset',
              style: TextStyle(
                color:
                    isDark ? AppColors.badSleepDark : AppColors.badSleepLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await MusicService.stop();
    await context.read<SleepProvider>().resetSleepData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data tidur berhasil direset.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final themeProvider = context.watch<ThemeProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final age = profileProvider.age;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Pengaturan',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: PageBackdrop(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Notifikasi ─────────────────────────────────────────
              _SettingsCard(
                isDark: isDark,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            age == null
                                ? 'Usia belum diisi'
                                : 'Usia $age tahun',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            age == null
                                ? 'Isi usia untuk melihat rekomendasi tidur.'
                                : 'Rekomendasi tidur ${SleepCalculator.getRecommendationForAge(age).rangeText}.',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _editAge,
                      child: Text(age == null ? 'Isi' : 'Ubah'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Notifikasi ─────────────────────────────────────────
              _SectionHeader(label: 'Notifikasi', textColor: textColor),
              const SizedBox(height: 10),
              _SettingsCard(
                isDark: isDark,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tampilkan Notifikasi',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Aktifkan untuk menerima notifikasi\nkualitas tidur setiap hari.',
                            style:
                                TextStyle(color: secondaryColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationEnabled,
                      onChanged: _toggleNotification,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Tema ───────────────────────────────────────────────
              _SectionHeader(label: 'Tema Aplikasi', textColor: textColor),
              const SizedBox(height: 10),
              ThemeSelector(
                selected: themeProvider.themeModeString,
                onChanged: (mode) => themeProvider.setThemeMode(mode),
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // ── Music ──────────────────────────────────────────────
              _SettingsCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(label: 'Music', textColor: textColor),
                    const SizedBox(height: 12),
                    Text(
                      'Sound Relaxing',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih sound untuk menemanimu tidur.',
                      style: TextStyle(color: secondaryColor, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ...MusicService.builtInTracks.map(
                      (track) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MusicTrackTile(
                          track: track,
                          isPlaying: _selectedMusic == track['id'],
                          isDark: isDark,
                          textColor: textColor,
                          primaryColor: primaryColor,
                          cardColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          onPlay: () => _playBuiltIn(track['id']!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Upload Lagu ────────────────────────────────────────
              _SettingsCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      label: 'Upload Lagu Sendiri',
                      textColor: textColor,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unggah beberapa lagu dari perangkatmu\nuntuk diputar saat tidur.',
                      style: TextStyle(color: secondaryColor, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    if (_customMusics.isNotEmpty) ...[
                      ..._customMusics.map(
                        (music) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _UploadedMusicTile(
                            music: music,
                            isPlaying: _isPlayingCustom &&
                                _playingCustomMusicId == music.id,
                            isDark: isDark,
                            textColor: textColor,
                            primaryColor: primaryColor,
                            onPlay: () => _toggleUploadedMusic(music),
                            onDelete: () => _deleteUploadedMusic(music),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (_customMusicName.isNotEmpty) ...[
                      _LocalMusicTile(
                        fileName: _customMusicName,
                        isPlaying: _isPlayingCustom &&
                            _playingCustomMusicId == 'local',
                        isDark: isDark,
                        textColor: textColor,
                        primaryColor: primaryColor,
                        onPlay: _toggleLocalCustomMusic,
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isUploadingMusic ? null : _uploadLagu,
                        icon: _isUploadingMusic
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.upload_file_outlined,
                                color: primaryColor,
                              ),
                        label: Text(
                          _isUploadingMusic ? 'Mengupload...' : 'Upload Lagu',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                          ),
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(.05)
                              : AppColors.surfaceLight.withOpacity(.55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── About Aplikasi ─────────────────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutAppPage()),
                  );
                },
                child: _SettingsCard(
                  isDark: isDark,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tentang TreeminaSleep',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: secondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Reset Data ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetSleepData,
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    color: isDark
                        ? AppColors.badSleepDark
                        : AppColors.badSleepLight,
                  ),
                  label: Text(
                    'Reset Data Tidur',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.badSleepDark
                          : AppColors.badSleepLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.badSleepDark
                          : AppColors.badSleepLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Logout ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.badSleepDark
                        : AppColors.badSleepLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textColor;
  const _SectionHeader({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(isDark ? .9 : 1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UploadedMusicTile extends StatelessWidget {
  final UploadedMusic music;
  final bool isPlaying;
  final bool isDark;
  final Color textColor;
  final Color primaryColor;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _UploadedMusicTile({
    required this.music,
    required this.isPlaying,
    required this.isDark,
    required this.textColor,
    required this.primaryColor,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlaying
              ? primaryColor
              : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          width: isPlaying ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onPlay,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:
                    isPlaying ? primaryColor : primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isPlaying ? Colors.white : primaryColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              music.fileName,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalMusicTile extends StatelessWidget {
  final String fileName;
  final bool isPlaying;
  final bool isDark;
  final Color textColor;
  final Color primaryColor;
  final VoidCallback onPlay;

  const _LocalMusicTile({
    required this.fileName,
    required this.isPlaying,
    required this.isDark,
    required this.textColor,
    required this.primaryColor,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlaying
              ? primaryColor
              : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          width: isPlaying ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onPlay,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:
                    isPlaying ? primaryColor : primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isPlaying ? Colors.white : primaryColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicTrackTile extends StatelessWidget {
  final Map<String, String> track;
  final bool isPlaying;
  final bool isDark;
  final Color textColor;
  final Color primaryColor;
  final Color cardColor;
  final VoidCallback onPlay;

  const _MusicTrackTile({
    required this.track,
    required this.isPlaying,
    required this.isDark,
    required this.textColor,
    required this.primaryColor,
    required this.cardColor,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying
                ? primaryColor
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isPlaying ? 1.5 : 1,
          ),
          boxShadow: const [],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isPlaying ? primaryColor : primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isPlaying ? Colors.white : primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                track['name'] ?? '',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_arrow_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
