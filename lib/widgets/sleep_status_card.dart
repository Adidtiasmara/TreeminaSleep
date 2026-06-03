import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SleepStatusCard extends StatelessWidget {
  final String status;
  final String message;
  final bool isDark;

  const SleepStatusCard({
    super.key,
    required this.status,
    required this.message,
    required this.isDark,
  });

  Color _getColor() {
    switch (status) {
      case 'Excellent Sleep':
        return isDark
            ? AppColors.excellentSleepDark
            : AppColors.excellentSleepLight;
      case 'Bad Sleep':
        return isDark ? AppColors.badSleepDark : AppColors.badSleepLight;
      case 'Over Sleep':
        return isDark ? AppColors.overSleepDark : AppColors.overSleepLight;
      default:
        return Colors.grey;
    }
  }

  String _getEmoji() {
    switch (status) {
      case 'Excellent Sleep':
        return '😊';
      case 'Bad Sleep':
        return '😟';
      case 'Over Sleep':
        return '😴';
      default:
        return '💤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_getEmoji(), style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
