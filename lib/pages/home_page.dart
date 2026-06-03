import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record_model.dart';
import '../providers/sleep_provider.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/sleep_calculator.dart';
import '../widgets/custom_button.dart';
import '../widgets/schedule_card.dart';
import '../widgets/sleep_status_card.dart';
import '../widgets/sleep_visuals.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String _userName = '';
  late String _funFact;

  static const List<String> _funFacts = [
    'Tidur cukup dapat membantu meningkatkan fokus dan suasana hati.',
    'Tidur yang berkualitas membantu tubuh melakukan pemulihan sel.',
    'Kurang tidur dapat membuat konsentrasi menurun hingga 30%.',
    'Orang dewasa membutuhkan 7–9 jam tidur setiap malam.',
    'Tidur yang baik membantu mengatur emosi dan mengurangi stres.',
    'Mimpi terjadi selama fase REM, sekitar 2 jam per malam.',
    'Tubuh melepaskan hormon pertumbuhan saat tidur nyenyak.',
    'Tidur teratur membantu menjaga berat badan yang sehat.',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _funFact = _funFacts[Random().nextInt(_funFacts.length)];
    final provider = context.read<SleepProvider>();
    if (provider.isSleeping && provider.sleepStart != null) {
      _startTimer(provider.sleepStart!);
    }
  }

  void _loadUserName() {
    final user = StorageService.getUser();
    setState(() => _userName = user?.name ?? 'Pengguna');
  }

  void _startTimer(DateTime start) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = DateTime.now().difference(start));
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _elapsed = Duration.zero);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onStartSleep(SleepProvider provider) async {
    await provider.startSleep();
    _startTimer(provider.sleepStart!);
  }

  Future<void> _onWakeUp(SleepProvider provider) async {
    _stopTimer();
    final record = await provider.wakeUp();
    if (!mounted) return;

    if (record != null && StorageService.isNotificationEnabled()) {
      await NotificationService.showSleepStatusNotification(record.status);
    }

    if (record != null) {
      _showWakeUpDialog(record);
    }
  }

  void _showWakeUpDialog(SleepRecord record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Selamat Pagi! ☀️',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              label: 'Durasi Tidur',
              value: SleepCalculator.formatDuration(record.durationMinutes),
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Mulai Tidur',
              value: DateFormat('HH:mm').format(record.sleepStart),
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Bangun',
              value: DateFormat('HH:mm').format(record.wakeUp),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            SleepStatusCard(
              status: record.status,
              message: SleepCalculator.getSleepMessage(record.status),
              isDark: isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Consumer<SleepProvider>(
      builder: (context, provider, _) {
        final schedule = provider.schedule;
        final lastRecord = provider.lastRecord;
        final isSleeping = provider.isSleeping;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              if (isDark)
                const Positioned.fill(
                  bottom: null,
                  child: SizedBox(
                    height: 330,
                    child: NightScape(isDark: true),
                  ),
                ),
              SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome to',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Treemina Sleep, $_userName 👋',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: textColor,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (isDark) ...[
                        SleepHeroArt(isDark: isDark, awake: !isSleeping),
                        const SizedBox(height: 10),
                      ],

                      // ── Status Tidur ──────────────────────────────────
                      if (lastRecord != null)
                        SleepStatusCard(
                          status: lastRecord.status,
                          message: SleepCalculator.getSleepMessage(
                            lastRecord.status,
                          ),
                          isDark: isDark,
                        )
                      else
                        SleepStatusCard(
                          status: 'Excellent Sleep',
                          message:
                              'Tidurmu cukup nyenyak!\nPertahankan pola tidur yang baik.',
                          isDark: isDark,
                        ),
                      const SizedBox(height: 14),

                      // ── Jadwal Tidur ──────────────────────────────────
                      ScheduleCard(
                        sleepTime: schedule.targetSleepTime,
                        wakeTime: schedule.targetWakeTime,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),

                      // ── Sedang Tidur / Start Sleep ────────────────────
                      if (isSleeping)
                        _SleepingCard(
                          elapsed: _elapsed,
                          sleepStart: provider.sleepStart!,
                          isDark: isDark,
                          onWakeUp: () => _onWakeUp(provider),
                        )
                      else
                        _StartSleepCard(
                          targetSleepTime: schedule.targetSleepTime,
                          isDark: isDark,
                          onStartSleep: () => _onStartSleep(provider),
                        ),
                      const SizedBox(height: 14),

                      // ── Fun Fact ──────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: primaryColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Fun Fact',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _funFact,
                              style: TextStyle(
                                color: textColor.withOpacity(0.85),
                                fontSize: 13.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _StartSleepCard extends StatelessWidget {
  final String targetSleepTime;
  final bool isDark;
  final VoidCallback onStartSleep;

  const _StartSleepCard({
    required this.targetSleepTime,
    required this.isDark,
    required this.onStartSleep,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.excellentSleepLight.withOpacity(.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Siap tidur?',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jam target tidur $targetSleepTime',
            style: TextStyle(color: secondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Start Sleep',
            onPressed: onStartSleep,
            icon: Icons.bedtime_rounded,
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

class _SleepingCard extends StatelessWidget {
  final Duration elapsed;
  final DateTime sleepStart;
  final bool isDark;
  final VoidCallback onWakeUp;

  const _SleepingCard({
    required this.elapsed,
    required this.sleepStart,
    required this.isDark,
    required this.onWakeUp,
  });

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : const Color(0xFF1B4332);
    final badColor = isDark ? AppColors.badSleepDark : AppColors.badSleepLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : Colors.white70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF49A078),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Sedang Tidur...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tidur yang berkualitas dimulai sekarang.',
            style: TextStyle(color: textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Durasi Tidur',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            _fmt(elapsed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai tidur: ${DateFormat('HH:mm').format(sleepStart)}',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Wake Up',
            onPressed: onWakeUp,
            icon: Icons.wb_sunny_outlined,
            backgroundColor: badColor,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
