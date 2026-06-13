import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ScheduleCard extends StatelessWidget {
  final String sleepTime;
  final String wakeTime;
  final bool isDark;

  const ScheduleCard({
    super.key,
    required this.sleepTime,
    required this.wakeTime,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            'Jadwal Tidur Kamu',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: Icons.nightlight_round,
            iconColor: const Color(0xFF7986CB),
            label: 'Jam Target Tidur',
            value: sleepTime,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 10),
          Divider(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          const SizedBox(height: 10),
          _buildRow(
            icon: Icons.wb_sunny_outlined,
            iconColor: const Color(0xFFFFB74D),
            label: 'Jam Target Bangun',
            value: wakeTime,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: secondaryColor, fontSize: 13.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
