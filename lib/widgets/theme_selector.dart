import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ThemeSelector extends StatelessWidget {
  final String selected; // 'light', 'dark', 'system'
  final ValueChanged<String> onChanged;
  final bool isDark;

  const ThemeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeOption(
          label: 'Light',
          icon: Icons.wb_sunny_outlined,
          value: 'light',
          selected: selected,
          onTap: () => onChanged('light'),
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _ThemeOption(
          label: 'Dark',
          icon: Icons.nightlight_outlined,
          value: 'dark',
          selected: selected,
          onTap: () => onChanged('dark'),
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _ThemeOption(
          label: 'System',
          icon: Icons.phone_android,
          value: 'system',
          selected: selected,
          onTap: () => onChanged('system'),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : textColor,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
