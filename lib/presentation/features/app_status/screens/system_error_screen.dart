import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';
import '../widgets/status_action_buttons.dart';
import '../widgets/status_illustration.dart';
import '../widgets/status_page_layout.dart';

class SystemErrorScreen extends StatelessWidget {
  final String title;
  final String description;
  final String? statusPillText;
  final String? safetyTitle;
  final String? safetySubtitle;
  final bool showSafetyCard;
  final String errorCode;
  final String? errorDetails;
  final String? apiPath;
  final String? timeoutText;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;

  const SystemErrorScreen({
    super.key,
    this.title = 'عذراً، حدث خطأ غير متوقع',
    this.description = 'تعذر إتمام العملية في الوقت الحالي. يرجى المحاولة مرة أخرى.',
    this.statusPillText = 'حالة النظام: انقطاع مؤقت',
    this.safetyTitle = 'رصيدك في أمان تام',
    this.safetySubtitle = 'تم التحقق من الخدمة: لم يسجل أي استقطاع مالي.',
    this.showSafetyCard = true,
    this.errorCode = '#ERR-503-GATEWAY',
    this.errorDetails = 'فشل مؤقت في مزامنة الخادم. خوادمنا تعمل على حل المشكلة فوراً وإعادة توجيه العملية بأمان.',
    this.apiPath = 'api/v2/checkout/confirm',
    this.timeoutText = 'المهلة: 15.4 ثانية',
    this.primaryButtonLabel = 'إعادة المحاولة الآن',
    this.secondaryButtonLabel = 'الرجوع لسجل الطلبات',
    this.onRetry,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AppStatusController>()
        ? Get.find<AppStatusController>()
        : Get.put(AppStatusController());

    return StatusPageLayout(
      topPillWidget: statusPillText != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusPillText!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            )
          : null,
      illustration: const StatusIllustration(
        assetPath: 'assets/images/error.png',
        mainIcon: Icons.warning_amber_rounded,
        iconColor: AppColors.error,
        circleBgColor: AppColors.surfaceSubdued,
        badgeIcon: Icons.sync_problem_rounded,
        badgeBgColor: AppColors.error,
      ),
      title: title,
      description: description,
      middleCard: Column(
        children: [
          // Safety Banner (if enabled and safetyTitle provided)
          if (showSafetyCard && safetyTitle != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          safetyTitle!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                        if (safetySubtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            safetySubtitle!,
                            style: const TextStyle(fontSize: 10, color: AppColors.success),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Technical Error Details Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            errorCode,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.copyErrorCode(errorCode),
                      icon: const Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                      label: const Text('نسخ الرمز', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ],
                ),
                if (errorDetails != null) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'تفاصيل الخادم التقني:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    errorDetails!,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
                if (apiPath != null || timeoutText != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (apiPath != null) _detailChip('المسار: $apiPath'),
                      if (timeoutText != null) _detailChip(timeoutText!),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actionButtons: StatusActionButtons(
        primaryLabel: primaryButtonLabel,
        primaryIcon: Icons.refresh_rounded,
        onPrimaryPressed: () {
          if (onRetry != null) {
            onRetry!();
          } else {
            controller.retryAction();
          }
        },
        secondaryLabel: secondaryButtonLabel,
        secondaryIcon: Icons.receipt_long_rounded,
        onSecondaryPressed: () {
          if (onSecondaryAction != null) {
            onSecondaryAction!();
          } else {
            controller.goToOrders();
          }
        },
      ),
    );
  }

  static Widget _detailChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
    );
  }
}
