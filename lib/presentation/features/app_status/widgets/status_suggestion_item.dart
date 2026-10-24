import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';

class StatusSuggestionItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const StatusSuggestionItem({
    super.key,
    required this.icon,
    this.iconBgColor = AppColors.surfaceSubdued,
    this.iconColor = AppColors.primary,
    required this.title,
    this.subtitle,
    this.trailingIcon = Icons.arrow_back_rounded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AppStatusController>()
        ? Get.find<AppStatusController>()
        : Get.put(AppStatusController());

    final callback = onTap ?? () => controller.openSuggestion(title);

    return Material(
      color: AppColors.scaffoldBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: callback,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(trailingIcon, size: 18, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
