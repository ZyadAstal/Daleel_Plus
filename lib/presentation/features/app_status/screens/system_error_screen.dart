import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';
import '../widgets/status_action_buttons.dart';
import '../widgets/status_illustration.dart';
import '../widgets/status_page_layout.dart';

class SystemErrorScreen extends GetView<AppStatusController> {
  const SystemErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusPageLayout(
      topPillWidget: Container(
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
            const Text(
              'حالة النظام: انقطاع مؤقت',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
      illustration: const StatusIllustration(
        assetPath: 'assets/images/error.png',
        mainIcon: Icons.warning_amber_rounded,
        iconColor: Color(0xFFEA580C),
        circleBgColor: Color(0xFFFFEDD5),
        badgeIcon: Icons.sync_problem_rounded,
        badgeBgColor: Color(0xFFEA580C),
      ),
      title: 'عذراً، حدث خطأ غير متوقع',
      description: 'تعذر إتمام عملية الحجز والدفع الخاصة بك في الوقت الحالي. لا تقلق، لم يتم خصم أي مبالغ من محفظتك أو بطاقتك.',
      middleCard: Column(
        children: [
          // Green Safety Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رصيدك في أمان تام',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'تم التحقق من بوابة الدفع: لم يسجل أي استقطاع مالي.',
                        style: TextStyle(fontSize: 10, color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

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
                      child: const Row(
                        children: [
                          Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
                          SizedBox(width: 4),
                          Text(
                            '#ERR-503-GATEWAY',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Get.snackbar('نسخ الرمز', 'تم نسخ رمز الخطأ التقني بنجاح');
                      },
                      icon: const Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                      label: const Text('نسخ الرمز', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'تفاصيل الخادم التقني:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                const Text(
                  'فشل مؤقت في مزامنة بوابة الدفع الأكاديمية. خوادمنا تعمل على حل المشكلة فوراً وإعادة توجيه العملية بأمان.',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _detailChip('المسار: api/v2/checkout/confirm'),
                    _detailChip('المهلة: 15.4 ثانية'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actionButtons: StatusActionButtons(
        primaryLabel: 'إعادة المحاولة الآن',
        primaryIcon: Icons.refresh_rounded,
        onPrimaryPressed: controller.retryAction,
        secondaryLabel: 'الرجوع لسجل الطلبات',
        secondaryIcon: Icons.receipt_long_rounded,
        onSecondaryPressed: controller.goToOrders,
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
