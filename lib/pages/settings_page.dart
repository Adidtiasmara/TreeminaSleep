import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/music_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/theme_selector.dart';
import '../widgets/sleep_visuals.dart';
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
  bool _isPlayingCustom = false;

  @override
  void initState() {
    super.initState();
    _notificationEnabled = StorageService.isNotificationEnabled();
    _selectedMusic = StorageService.getSelectedMusic();
    _customMusicPath = StorageService.getCustomMusicPath();
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() => _notificationEnabled = value);
    await StorageService.setNotificationEnabled(value);
    if (value) {
      await NotificationService.requestPermission();
    }
  }

  Future<void> _playBuiltIn(String trackId) async {
    await MusicService.playBuiltIn(trackId);
    setState(() {
      _selectedMusic = trackId;
      _isPlayingCustom = false;
    });
    await StorageService.setSelectedMusic(trackId);
  }

  Future<void> _uploadLagu() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() {
        _customMusicPath = path;
        _isPlayingCustom = false;
      });
      await StorageService.setCustomMusicPath(path);
    }
  }

  Future<void> _toggleCustomMusic() async {
    if (_customMusicPath.isEmpty) return;
    if (_isPlayingCustom) {
      await MusicService.pause();
      setState(() => _isPlayingCustom = false);
    } else {
      await MusicService.playCustom(_customMusicPath);
      setState(() {
        _isPlayingCustom = true;
        _selectedMusic = '';
      });
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
      await StorageService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
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
                      'Unggah lagu dari perangkatmu\nuntuk diputar saat tidur.',
                      style: TextStyle(color: secondaryColor, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    if (_customMusicPath.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.music_note_outlined,
                              color: primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _customMusicPath.split('/').last,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: _toggleCustomMusic,
                            icon: Icon(
                              _isPlayingCustom
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: primaryColor,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _uploadLagu,
                        icon: Icon(
                          Icons.upload_file_outlined,
                          color: primaryColor,
                        ),
                        label: Text(
                          'Upload Lagu',
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
                '${track['icon']} ${track['name']}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
