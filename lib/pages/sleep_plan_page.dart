import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sleep_schedule_model.dart';
import '../providers/sleep_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/sleep_visuals.dart';

class SleepPlanPage extends StatefulWidget {
  const SleepPlanPage({super.key});

  @override
  State<SleepPlanPage> createState() => _SleepPlanPageState();
}

class _SleepPlanPageState extends State<SleepPlanPage> {
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 5, minute: 30);
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadFromProvider();
  }

  void _loadFromProvider() {
    final provider = context.read<SleepProvider>();
    final parts = provider.schedule.targetSleepTime.split(':');
    final wakeParts = provider.schedule.targetWakeTime.split(':');
    _sleepTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    _wakeTime = TimeOfDay(
      hour: int.parse(wakeParts[0]),
      minute: int.parse(wakeParts[1]),
    );
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickSleepTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _sleepTime,
      builder: (ctx, child) => _buildTimePickerTheme(ctx, child),
    );
    if (picked != null)
      setState(() {
        _sleepTime = picked;
        _saved = false;
      });
  }

  Future<void> _pickWakeTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
      builder: (ctx, child) => _buildTimePickerTheme(ctx, child),
    );
    if (picked != null)
      setState(() {
        _wakeTime = picked;
        _saved = false;
      });
  }

  Widget _buildTimePickerTheme(BuildContext ctx, Widget? child) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    return Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: isDark
            ? ColorScheme.dark(primary: primary, onSurface: AppColors.textDark)
            : ColorScheme.light(
                primary: primary,
                onSurface: AppColors.textLight,
              ),
      ),
      child: child!,
    );
  }

  Future<void> _saveSchedule() async {
    final provider = context.read<SleepProvider>();
    await provider.updateSchedule(
      SleepSchedule(
        targetSleepTime: _formatTime(_sleepTime),
        targetWakeTime: _formatTime(_wakeTime),
      ),
    );
    setState(() => _saved = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Jadwal berhasil disimpan!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor, size: 20),
          onPressed: () {},
        ),
        title: Text(
          'Atur Jadwal Tidur',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
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
              Text(
                'Atur jam target tidur dan bangun\nsesuai rutinitasmu.',
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              _WheelTimeCard(
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF7986CB),
                label: 'Jam Target Tidur',
                time: _sleepTime,
                isDark: isDark,
                onTap: _pickSleepTime,
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),
              const SizedBox(height: 16),
              _WheelTimeCard(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFFFB74D),
                label: 'Jam Target Bangun',
                time: _wakeTime,
                isDark: isDark,
                onTap: _pickWakeTime,
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Simpan Jadwal',
                onPressed: _saveSchedule,
                icon: _saved ? Icons.check_rounded : Icons.save_outlined,
              ),
              const SizedBox(height: 20),
              if (_saved)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Jadwal tidur disimpan:\n'
                          'Tidur ${_formatTime(_sleepTime)} • Bangun ${_formatTime(_wakeTime)}',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelTimeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final TimeOfDay time;
  final bool isDark;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;

  const _WheelTimeCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.time,
    required this.isDark,
    required this.onTap,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final hour = time.hour;
    final minute = time.minute;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 116,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(.03)
                    : AppColors.surfaceLight.withOpacity(.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NumberWheel(
                    value: hour,
                    min: 0,
                    max: 23,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _NumberWheel(
                    value: minute,
                    min: 0,
                    max: 59,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberWheel extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;

  const _NumberWheel({
    required this.value,
    required this.min,
    required this.max,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
  });

  String _fmt(int v) => v.toString().padLeft(2, '0');

  int _wrap(int v) {
    if (v < min) return max + 1 + v;
    if (v > max) return min + v - max - 1;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    final values = [-2, -1, 0, 1, 2].map((offset) => _wrap(value + offset));

    return SizedBox(
      width: 74,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: values.map((item) {
          final selected = item == value;
          return Container(
            height: selected ? 30 : 20,
            alignment: Alignment.center,
            decoration: selected
                ? BoxDecoration(
                    color: primaryColor.withOpacity(.08),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              _fmt(item),
              style: TextStyle(
                color: selected ? textColor : secondaryColor.withOpacity(.68),
                fontSize: selected ? 22 : 16,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
