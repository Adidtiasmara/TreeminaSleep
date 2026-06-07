import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record_model.dart';
import '../providers/sleep_provider.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../utils/sleep_calculator.dart';
import '../widgets/custom_button.dart';
import '../widgets/schedule_card.dart';
import '../widgets/sleep_status_card.dart';
import '../widgets/sleep_visuals.dart';
import 'notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  Timer? _funFactTimer;
  Timer? _clockTimer;
  Duration _elapsed = Duration.zero;
  String _userName = '';
  DateTime _now = DateTime.now();
  late int _funFactIndex;

  static const List<_FunFactData> _funFacts = [
    _FunFactData(
      icon: Icons.health_and_safety_outlined,
      titlePrefix: 'Tidur:',
      title: 'Kunci Kesehatan Otak',
      leftTitle: 'Mode Performa',
      leftSubtitle: 'Aktif & Produktif',
      rightTitle: 'Mode Pemeliharaan',
      rightSubtitle: 'Pemulihan & Perbaikan',
      highlight: 'Otak tidak berhenti bekerja saat kamu tidur.',
      description:
          'Saat tidur, tubuh beralih dari aktivitas harian menuju proses perbaikan yang membantu otak dan tubuh pulih.',
      bullets: [
        'Tidur nyenyak mendukung proses pemulihan otak.',
        'Kurang tidur dapat menurunkan fokus dan stabilitas emosi.',
      ],
    ),
    _FunFactData(
      icon: Icons.water_drop_outlined,
      titlePrefix: 'Glimfatik:',
      title: 'Sistem Pembersihan Otak',
      leftTitle: 'Sisa Metabolik',
      leftSubtitle: 'Menumpuk saat aktif',
      rightTitle: 'Jalur Bersih',
      rightSubtitle: 'Aktif saat tidur',
      highlight: 'Tidur nyenyak membantu otak melakukan proses bersih-bersih.',
      description:
          'Ketika tidur nyenyak, otak lebih aktif membuang limbah metabolik sehingga terasa lebih segar saat bangun.',
      bullets: [
        'Tidur cukup membantu otak melakukan perawatan alami.',
        'Jadwal tidur teratur mendukung ritme biologis tubuh.',
      ],
    ),
    _FunFactData(
      icon: Icons.nights_stay_rounded,
      titlePrefix: 'REM:',
      title: 'Fase Mimpi dan Emosi',
      leftTitle: 'Memori',
      leftSubtitle: 'Diproses ulang',
      rightTitle: 'Emosi',
      rightSubtitle: 'Lebih stabil',
      highlight: 'Fase mimpi ikut membantu otak menata pengalaman harian.',
      description:
          'Fase REM berperan dalam pemrosesan memori, emosi, dan mimpi yang biasanya muncul menjelang akhir siklus tidur.',
      bullets: [
        'Kualitas tidur memengaruhi mood setelah bangun.',
        'Tidur terpotong dapat mengganggu siklus REM.',
      ],
    ),
    _FunFactData(
      icon: Icons.wb_twilight_rounded,
      titlePrefix: 'Ritme:',
      title: 'Jam Biologis Tubuh',
      leftTitle: 'Malam',
      leftSubtitle: 'Tubuh melambat',
      rightTitle: 'Pagi',
      rightSubtitle: 'Energi naik',
      highlight:
          'Jam tidur yang konsisten membuat tubuh lebih mudah siap istirahat.',
      description:
          'Tidur dan bangun di jam yang konsisten membantu tubuh mengenali kapan harus istirahat dan kapan siap aktif.',
      bullets: [
        'Konsistensi jadwal sering lebih penting daripada tidur sangat larut.',
        'Cahaya pagi membantu tubuh mengatur ritme harian.',
      ],
    ),
    _FunFactData(
      icon: Icons.light_mode_outlined,
      titlePrefix: 'Cahaya:',
      title: 'Sinyal untuk Tubuh',
      leftTitle: 'Terang',
      leftSubtitle: 'Lebih waspada',
      rightTitle: 'Redup',
      rightSubtitle: 'Lebih mengantuk',
      highlight:
          'Cahaya kuat di malam hari bisa membuat tubuh merasa belum waktunya tidur.',
      description:
          'Paparan cahaya membantu tubuh mengatur melatonin, hormon yang memberi sinyal kapan waktunya beristirahat.',
      bullets: [
        'Redupkan layar dan lampu mendekati jam tidur.',
        'Cahaya pagi membantu tubuh lebih cepat masuk mode aktif.',
      ],
    ),
    _FunFactData(
      icon: Icons.thermostat_rounded,
      titlePrefix: 'Suhu:',
      title: 'Tubuh Suka Sejuk',
      leftTitle: 'Terlalu Panas',
      leftSubtitle: 'Sering gelisah',
      rightTitle: 'Lebih Sejuk',
      rightSubtitle: 'Tidur lebih nyaman',
      highlight:
          'Lingkungan yang sejuk sering membantu tidur terasa lebih dalam.',
      description:
          'Menjelang tidur, suhu tubuh alami cenderung turun. Kamar yang terlalu panas bisa membuat tidur mudah terputus.',
      bullets: [
        'Gunakan pakaian tidur yang nyaman dan tidak gerah.',
        'Atur kamar agar terasa sejuk, tenang, dan minim cahaya.',
      ],
    ),
    _FunFactData(
      icon: Icons.restaurant_rounded,
      titlePrefix: 'Makan:',
      title: 'Jeda Sebelum Tidur',
      leftTitle: 'Perut Penuh',
      leftSubtitle: 'Tubuh sibuk cerna',
      rightTitle: 'Jeda Cukup',
      rightSubtitle: 'Istirahat lebih tenang',
      highlight:
          'Makan berat terlalu dekat dengan jam tidur bisa mengganggu kenyamanan.',
      description:
          'Tubuh tetap bekerja mencerna makanan. Memberi jeda sebelum tidur membantu istirahat terasa lebih ringan.',
      bullets: [
        'Pilih camilan ringan jika lapar menjelang tidur.',
        'Batasi kafein sore atau malam jika tidur mudah terganggu.',
      ],
    ),
    _FunFactData(
      icon: Icons.self_improvement_rounded,
      titlePrefix: 'Tenang:',
      title: 'Ritual Sebelum Tidur',
      leftTitle: 'Pikiran Ramai',
      leftSubtitle: 'Sulit rileks',
      rightTitle: 'Ritual Ringan',
      rightSubtitle: 'Tubuh siap tidur',
      highlight:
          'Rutinitas kecil bisa menjadi sinyal lembut bahwa hari sudah selesai.',
      description:
          'Aktivitas sederhana seperti mandi hangat, membaca, atau musik relaksasi dapat membantu transisi menuju tidur.',
      bullets: [
        'Lakukan rutinitas yang sama selama beberapa malam.',
        'Hindari aktivitas yang terlalu menegangkan tepat sebelum tidur.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _funFactIndex = Random().nextInt(_funFacts.length);
    _funFactTimer = Timer.periodic(const Duration(seconds: 14), (_) {
      if (!mounted) return;
      setState(() => _funFactIndex = (_funFactIndex + 1) % _funFacts.length);
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
    final provider = context.read<SleepProvider>();
    if (provider.isSleeping && provider.sleepStart != null) {
      _startTimer(provider.sleepStart!);
    }
  }

  Future<void> _loadUserName() async {
    final user = SupabaseService.isConfigured && SupabaseService.isLoggedIn
        ? await SupabaseService.getCurrentUser()
        : StorageService.getUser();
    if (!mounted) return;
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
    _funFactTimer?.cancel();
    _clockTimer?.cancel();
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
                          _LiveClockPill(
                            now: _now,
                            isDark: isDark,
                            textColor: textColor,
                            secondaryColor: secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: textColor,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _HeroImageCard(
                        isDark: isDark,
                        awake: !isSleeping && lastRecord != null,
                      ),
                      const SizedBox(height: 10),

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
                          now: _now,
                          isDark: isDark,
                          onStartSleep: () => _onStartSleep(provider),
                        ),
                      const SizedBox(height: 14),

                      _FunFactHighlight(
                        fact: _funFacts[_funFactIndex],
                        isDark: isDark,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
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

class _LiveClockPill extends StatelessWidget {
  final DateTime now;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  const _LiveClockPill({
    required this.now,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withOpacity(.82)
            : AppColors.cardLight.withOpacity(.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat('HH:mm').format(now),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            DateFormat('d MMM').format(now),
            style: TextStyle(
              color: secondaryColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartSleepCard extends StatelessWidget {
  final String targetSleepTime;
  final DateTime now;
  final bool isDark;
  final VoidCallback onStartSleep;

  const _StartSleepCard({
    required this.targetSleepTime,
    required this.now,
    required this.isDark,
    required this.onStartSleep,
  });

  Duration _timeUntilTarget() {
    final parts = targetSleepTime.split(':');
    final hour = int.tryParse(parts.first) ?? 22;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }

  String _countdownText(Duration duration) {
    final totalMinutes = duration.inMinutes;
    if (totalMinutes <= 0) return 'Sekarang waktunya tidur.';
    if (totalMinutes < 60) {
      return '$totalMinutes menit lagi harus tidur.';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) return '$hours jam lagi harus tidur.';
    return '$hours jam $minutes menit lagi harus tidur.';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final remaining = _timeUntilTarget();
    final isNearBedtime = remaining.inMinutes <= 30;
    final alertColor =
        isDark ? AppColors.badSleepDark : AppColors.badSleepLight;
    final countdownColor = isNearBedtime ? alertColor : primaryColor;

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
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: countdownColor.withOpacity(isNearBedtime ? .16 : .10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: countdownColor.withOpacity(.32)),
            ),
            child: Row(
              children: [
                Icon(
                  isNearBedtime
                      ? Icons.notifications_active_outlined
                      : Icons.timer_outlined,
                  color: countdownColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _countdownText(remaining),
                    style: TextStyle(
                      color: countdownColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
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

class _FunFactData {
  final IconData icon;
  final String titlePrefix;
  final String title;
  final String leftTitle;
  final String leftSubtitle;
  final String rightTitle;
  final String rightSubtitle;
  final String highlight;
  final String description;
  final List<String> bullets;

  const _FunFactData({
    required this.icon,
    required this.titlePrefix,
    required this.title,
    required this.leftTitle,
    required this.leftSubtitle,
    required this.rightTitle,
    required this.rightSubtitle,
    required this.highlight,
    required this.description,
    required this.bullets,
  });
}

class _FunFactHighlight extends StatelessWidget {
  final _FunFactData fact;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;

  const _FunFactHighlight({
    required this.fact,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final blue = isDark ? const Color(0xFF8DB7FF) : const Color(0xFF075B9D);
    final accentSoft = primaryColor.withOpacity(isDark ? .16 : .11);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: Container(
        key: ValueKey(fact.title),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(isDark ? .92 : 1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .22 : .05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(fact.icon, color: primaryColor, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fun Fact',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Insight tidur harian',
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.14,
                ),
                children: [
                  TextSpan(
                    text: '${fact.titlePrefix} ',
                    style: TextStyle(color: blue),
                  ),
                  TextSpan(text: fact.title),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FunFactVariant(
              fact: fact,
              isDark: isDark,
              primaryColor: primaryColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _FunFactVariant extends StatelessWidget {
  final _FunFactData fact;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;

  const _FunFactVariant({
    required this.fact,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (fact.titlePrefix) {
      case 'Glimfatik:':
        return _diagramLayout();
      case 'REM:':
        return _timelineLayout();
      case 'Ritme:':
      case 'Suhu:':
        return _meterLayout();
      case 'Cahaya:':
        return _switchLayout();
      case 'Makan:':
        return _checklistLayout();
      case 'Tenang:':
        return _spotlightLayout();
      default:
        return _flowLayout();
    }
  }

  Widget _flowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HighlightNote(
          text: fact.highlight,
          icon: Icons.bolt_rounded,
          primaryColor: primaryColor,
          textColor: textColor,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ModePill(
                title: fact.leftTitle,
                subtitle: fact.leftSubtitle,
                color:
                    isDark ? const Color(0xFF5D6BA8) : const Color(0xFFEEC0D7),
                textColor: textColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: secondaryColor,
                size: 18,
              ),
            ),
            Expanded(
              child: _ModePill(
                title: fact.rightTitle,
                subtitle: fact.rightSubtitle,
                color:
                    isDark ? const Color(0xFF356D82) : const Color(0xFFC9EEF0),
                textColor: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FactText(text: fact.description, color: textColor),
      ],
    );
  }

  Widget _diagramLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _DiagramNode(label: fact.leftTitle, color: secondaryColor),
              Container(
                width: 3,
                height: 26,
                margin: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(.55),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              _DiagramNode(label: fact.rightTitle, color: primaryColor),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _HighlightNote(
          text: fact.highlight,
          icon: Icons.cleaning_services_outlined,
          primaryColor: primaryColor,
          textColor: textColor,
        ),
        const SizedBox(height: 10),
        _FactText(text: fact.description, color: textColor),
      ],
    );
  }

  Widget _timelineLayout() {
    final items = [fact.leftTitle, fact.highlight, fact.rightTitle];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          _TimelineStep(
            text: items[i],
            last: i == items.length - 1,
            primaryColor: primaryColor,
            textColor: i == 1 ? textColor : secondaryColor,
          ),
        const SizedBox(height: 8),
        _FactText(text: fact.description, color: textColor),
      ],
    );
  }

  Widget _meterLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HighlightNote(
          text: fact.highlight,
          icon: Icons.speed_rounded,
          primaryColor: primaryColor,
          textColor: textColor,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              fact.leftTitle,
              style: TextStyle(color: secondaryColor, fontSize: 11.5),
            ),
            Expanded(
              child: Container(
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFC857).withOpacity(.95),
                      primaryColor,
                      const Color(0xFF8DB7FF).withOpacity(.9),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              fact.rightTitle,
              style: TextStyle(color: secondaryColor, fontSize: 11.5),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FactText(text: fact.description, color: textColor),
      ],
    );
  }

  Widget _switchLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniInfoTile(
                icon: Icons.light_mode_outlined,
                title: fact.leftTitle,
                subtitle: fact.leftSubtitle,
                color: const Color(0xFFFFC857),
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniInfoTile(
                icon: Icons.dark_mode_outlined,
                title: fact.rightTitle,
                subtitle: fact.rightSubtitle,
                color: primaryColor,
                textColor: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _HighlightNote(
          text: fact.highlight,
          icon: Icons.tips_and_updates_outlined,
          primaryColor: primaryColor,
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _checklistLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HighlightNote(
          text: fact.highlight,
          icon: Icons.restaurant_menu_rounded,
          primaryColor: primaryColor,
          textColor: textColor,
        ),
        const SizedBox(height: 10),
        for (final bullet in fact.bullets)
          _FactBullet(
            text: bullet,
            color: primaryColor,
            textColor: secondaryColor,
          ),
      ],
    );
  }

  Widget _spotlightLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(.04)
            : primaryColor.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.self_improvement_rounded, color: primaryColor, size: 30),
          const SizedBox(height: 10),
          Text(
            fact.highlight,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _FactText(text: fact.description, color: secondaryColor),
        ],
      ),
    );
  }
}

class _HighlightNote extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color primaryColor;
  final Color textColor;

  const _HighlightNote({
    required this.text,
    required this.icon,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(.11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withOpacity(.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12.7,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramNode extends StatelessWidget {
  final String label;
  final Color color;

  const _DiagramNode({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String text;
  final bool last;
  final Color primaryColor;
  final Color textColor;

  const _TimelineStep({
    required this.text,
    required this.last,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!last)
              Container(
                width: 2,
                height: 30,
                color: primaryColor.withOpacity(.35),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 12.8,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  const _MiniInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 98),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.13),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(.68),
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactText extends StatelessWidget {
  final String text;
  final Color color;

  const _FactText({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color.withOpacity(.88),
        fontSize: 13.2,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  const _ModePill({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: color.withOpacity(.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 12.4,
              height: 1.14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(.72),
              fontSize: 10.8,
              height: 1.16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactBullet extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _FactBullet({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 12.4, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _HeroImageCard extends StatelessWidget {
  final bool isDark;
  final bool awake;

  const _HeroImageCard({required this.isDark, required this.awake});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDark ? 180 : 132,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .28 : .06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            awake
                ? 'assets/images/wake-hero-tight.png'
                : 'assets/images/sleep-hero-tight.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                SleepHeroArt(isDark: isDark, awake: awake),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.transparent,
                        AppColors.backgroundDark.withOpacity(.12),
                      ]
                    : [
                        Colors.white.withOpacity(.10),
                        Colors.white.withOpacity(.20),
                      ],
              ),
            ),
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
