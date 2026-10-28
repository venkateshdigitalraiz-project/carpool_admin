import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SeatCounter extends StatelessWidget {
  final int count;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const SeatCounter({
    super.key,
    required this.count,
    this.min = 1,
    this.max = 8,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircleButton(
            icon: Icons.remove,
            enabled: count > min,
            onTap: () {
              if (count > min) onChanged(count - 1);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$count',
              style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
          ),
          _buildCircleButton(
            icon: Icons.add,
            enabled: count < max,
            onTap: () {
              if (count < max) onChanged(count + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.inputFill : AppColors.borderLight,
          border: Border.all(color: enabled ? AppColors.primary : AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textDisabled,
        ),
      ),
    );
  }
}
