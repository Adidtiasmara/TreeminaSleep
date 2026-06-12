import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record_model.dart';
import '../providers/sleep_provider.dart';
import '../utils/app_colors.dart';
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
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
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
        final weeklyRecords = _weeklyRecords(allRecords, _selectedDate);
        final monthlyRecords = _yearlyRecords(allRecords);
        final selectedTab = _tabController.index;
        final visibleRecords = switch (selectedTab) {
          1 => monthlyRecords,
          _ => weeklyRecords,
        };
        final chartPoints = switch (selectedTab) {
          1 => _monthlyAverageChartPoints(allRecords),
          _ => _weeklyChartPoints(allRecords, _selectedDate),
        };
        final rangeLabel = switch (selectedTab) {
          1 => 'Rata-rata ${_selectedDate.year}',
          _ => _weekRangeLabel(_selectedDate),
        };

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
                onPressed: _pickReportDate,
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
                          rangeLabel,
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (chartPoints.isEmpty)
                          _EmptyReportState(
                            isDark: isDark,
                            textColor: textColor,
                            secondaryColor: secondaryColor,
                          )
                        else
                          SizedBox(
                            height: 180,
                            child: SleepChart(
                              points: chartPoints,
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
                  if (visibleRecords.isEmpty)
                    _EmptyHistoryCard(
                      isDark: isDark,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                    )
                  else
                    ...visibleRecords.take(10).map(
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

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('id', 'ID'),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    _tabController.animateTo(0);
  }

  List<SleepRecord> _weeklyRecords(List<SleepRecord> records, DateTime date) {
    final end = DateTime(date.year, date.month, date.day);
    final weekAgo = DateTime(
      end.year,
      end.month,
      end.day,
    ).subtract(const Duration(days: 6));
    return records.where((record) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      return !date.isBefore(weekAgo) && !date.isAfter(end);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<SleepRecord> _yearlyRecords(List<SleepRecord> records) {
    return records.where((record) {
      return record.date.year == _selectedDate.year;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<SleepChartPoint> _weeklyChartPoints(
    List<SleepRecord> records,
    DateTime date,
  ) {
    final selected = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      selected.year,
      selected.month,
      selected.day,
    ).subtract(const Duration(days: 6));
    final points = <SleepChartPoint>[];
    var hasRecords = false;

    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final dayRecords = _recordsOnDate(records, day);
      hasRecords = hasRecords || dayRecords.isNotEmpty;
      points.add(
        SleepChartPoint(
          label: DateFormat('E', 'id_ID').format(day),
          durationMinutes: _averageDuration(dayRecords),
        ),
      );
    }

    return hasRecords ? points : const [];
  }

  List<SleepChartPoint> _monthlyAverageChartPoints(List<SleepRecord> records) {
    final yearRecords = _yearlyRecords(records);
    if (yearRecords.isEmpty) return const [];

    return List.generate(12, (index) {
      final month = index + 1;
      final monthRecords = yearRecords.where((record) {
        return record.date.month == month;
      }).toList();

      return SleepChartPoint(
        label: DateFormat('MMM', 'id_ID')
            .format(DateTime(_selectedDate.year, month)),
        durationMinutes: _averageDuration(monthRecords),
      );
    });
  }

  int _averageDuration(List<SleepRecord> records) {
    if (records.isEmpty) return 0;
    final total = records.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );
    return (total / records.length).round();
  }

  List<SleepRecord> _recordsOnDate(List<SleepRecord> records, DateTime date) {
    return records.where((record) => _isSameDay(record.date, date)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekRangeLabel(DateTime date) {
    final end = DateTime(date.year, date.month, date.day);
    final start = end.subtract(const Duration(days: 6));
    return '${_fmtDate(start)} – ${_fmtDate(end)}';
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

class _EmptyReportState extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  const _EmptyReportState({
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      width: double.infinity,
      height: 180,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, color: primaryColor, size: 34),
          const SizedBox(height: 10),
          Text(
            'Tidak ada data tidur',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Belum ada riwayat tidur pada periode ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryColor, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  const _EmptyHistoryCard({
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(isDark ? .9 : 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Tidak ada riwayat tidur',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih periode lain atau mulai sesi tidur baru.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryColor, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
