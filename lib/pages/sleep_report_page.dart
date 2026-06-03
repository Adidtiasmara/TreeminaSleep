import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record_model.dart';
import '../providers/sleep_provider.dart';
import '../utils/app_colors.dart';
import '../utils/sleep_calculator.dart';
import '../widgets/sleep_chart.dart';
import '../widgets/sleep_record_item.dart';
import '../widgets/sleep_visuals.dart';

class SleepReportPage extends StatefulWidget {
  const SleepReportPage({super.key});

  @override
  State<SleepReportPage> createState() => _SleepReportPageState();
}

class _SleepReportPageState extends State<SleepReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Consumer<SleepProvider>(
      builder: (context, provider, _) {
        final allRecords = provider.records;
        final weeklyRecords = provider.getWeeklyRecords();
        final chartRecords =
            weeklyRecords.isEmpty ? _previewRecords() : weeklyRecords;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            title: Text(
              'Laporan Tidur',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.calendar_month_outlined,
                  color: textColor,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: PageBackdrop(
            isDark: isDark,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tab Toggle ─────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isDark ? 0.15 : 0.05,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: secondaryColor,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Mingguan'),
                        Tab(text: 'Bulanan'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Grafik ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(isDark ? .9 : 1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isDark ? 0.15 : 0.05,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durasi Tidur',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weeklyRecords.isEmpty
                              ? '27 Mei - 2 Juni 2024'
                              : _getDateRange(weeklyRecords),
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: SleepChart(
                            records: chartRecords,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Legend ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(isDark ? .9 : 1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        _LegendItem(
                          color: isDark
                              ? AppColors.excellentSleepDark
                              : AppColors.excellentSleepLight,
                          label: 'Excellent Sleep (7-8 jam)',
                          isDark: isDark,
                          textColor: textColor,
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: isDark
                              ? AppColors.badSleepDark
                              : AppColors.badSleepLight,
                          label: 'Bad Sleep (< 7 jam)',
                          isDark: isDark,
                          textColor: textColor,
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: isDark
                              ? AppColors.overSleepDark
                              : AppColors.overSleepLight,
                          label: 'Over Sleep (> 8 jam)',
                          isDark: isDark,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Riwayat ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (allRecords.length > 5)
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (allRecords.isEmpty)
                    ...chartRecords.reversed.take(4).map(
                          (record) => SleepRecordItem(
                            record: record,
                            isDark: isDark,
                          ),
                        )
                  else
                    ...allRecords.take(10).map(
                          (record) => SleepRecordItem(
                            record: record,
                            isDark: isDark,
                          ),
                        ),
                  if (allRecords.isEmpty) SleepyBottomArt(isDark: isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<SleepRecord> _previewRecords() {
    final base = DateTime(2024, 6, 1, 22);
    final durations = [420, 390, 510, 535, 370, 490, 460];
    return List.generate(durations.length, (index) {
      final start = base.add(Duration(days: index - durations.length + 1));
      final duration = durations[index];
      final status = SleepCalculator.getSleepStatus(duration);
      return SleepRecord(
        id: 'preview-$index',
        date: start,
        sleepStart: start,
        wakeUp: start.add(Duration(minutes: duration)),
        durationMinutes: duration,
        status: status,
      );
    });
  }

  String _getDateRange(List records) {
    if (records.isEmpty) return '';
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return '${_fmtDate(weekAgo)} – ${_fmtDate(now)}';
  }

  String _fmtDate(DateTime d) => '${d.day} ${_monthName(d.month)}';
  String _monthName(int m) => [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ][m - 1];
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;
  final Color textColor;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: textColor, fontSize: 13)),
      ],
    );
  }
}
