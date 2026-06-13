import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sleep_record_model.dart';
import '../utils/app_colors.dart';
import '../utils/sleep_calculator.dart';

class SleepRecordItem extends StatelessWidget {
  final SleepRecord record;
  final bool isDark;

  const SleepRecordItem({
    super.key,
    required this.record,
    required this.isDark,
  });

  Color _getStatusColor() {
    switch (record.status) {
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

  String _getStatusShort() {
    switch (record.status) {
      case 'Excellent Sleep':
        return 'Excellent';
      case 'Bad Sleep':
        return 'Bad';
      case 'Over Sleep':
        return 'Over';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMM', 'id_ID').format(record.date),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  SleepCalculator.formatDuration(record.durationMinutes),
                  style: TextStyle(color: secondaryColor, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusShort(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
