import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double unitSize;
  final Color? unitColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color valueColor;
  final String note;
  final Color noteColor;
  final IconData? noteIcon;
  final double noteIconSize;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = '',
    this.unitSize = 16,
    this.unitColor,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.surfaceSubdued,
    this.valueColor = AppColors.textPrimary,
    required this.note,
    this.noteColor = AppColors.textSecondary,
    this.noteIcon,
    this.noteIconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: iconBackground,
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: valueColor),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: unitSize,
                    fontWeight: FontWeight.w700,
                    color: unitColor ?? valueColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.space8),
          Row(
            children: [
              if (noteIcon != null) ...[
                Icon(noteIcon, size: noteIconSize, color: AppColors.success),
                const SizedBox(width: AppSizes.space4),
              ],
              Expanded(
                child: Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: noteColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}