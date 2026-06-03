import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sleep_schedule_model.dart';
import '../providers/sleep_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

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
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atur jam target tidur dan bangun\nsesuai rutinitas kamu.',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Jam Target Tidur
            _TimePickerCard(
              icon: Icons.nightlight_round,
              iconColor: const Color(0xFF7986CB),
              label: 'Jam Target Tidur',
              time: _formatTime(_sleepTime),
              isDark: isDark,
              onTap: _pickSleepTime,
              primaryColor: primaryColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: 16),

            // Jam Target Bangun
            _TimePickerCard(
              icon: Icons.wb_sunny_outlined,
              iconColor: const Color(0xFFFFB74D),
              label: 'Jam Target Bangun',
              time: _formatTime(_wakeTime),
              isDark: isDark,
              onTap: _pickWakeTime,
              primaryColor: primaryColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: 32),

            // Simpan
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
                  borderRadius: BorderRadius.circular(12),
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
          ],
        ),
      ),
    );
  }
}

class _TimePickerCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String time;
  final bool isDark;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;

  const _TimePickerCard({
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: secondaryColor, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: secondaryColor),
          ],
        ),
      ),
    );
  }
}
