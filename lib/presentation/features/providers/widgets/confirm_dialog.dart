import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';

void showConfirmDialog({
  required String title,
  required String message,
  required String confirmText,
  required IconData icon,
  required VoidCallback onConfirm,
}) {
  Get.dialog(
    _ConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      icon: icon,
      onConfirm: onConfirm,
    ),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final IconData icon;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.icon,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              child: Icon(icon, color: AppColors.error, size: 28),
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: AppSizes.space24),
            Row(
              children: [
                Expanded(
                  child: _button(
                    text: 'إلغاء',
                    background: AppColors.surfaceSubdued,
                    foreground: AppColors.textPrimary,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _button(
                    text: confirmText,
                    background: AppColors.error,
                    foreground: AppColors.white,
                    onPressed: () {
                      Get.back();
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _button({
    required String text,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}