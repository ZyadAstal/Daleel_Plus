import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';
import '../widgets/status_action_buttons.dart';
import '../widgets/status_illustration.dart';
import '../widgets/status_page_layout.dart';
import '../widgets/status_suggestion_item.dart';

class OfflineStateScreen extends GetView<AppStatusController> {
  const OfflineStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusPageLayout(
      topPillWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone_android_rounded, size: 12, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'محفوظ محلياً',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                SizedBox(width: 6),
                Text(
                  'جاري محاولة إعادة الاتصال تلقائياً...',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      illustration: const StatusIllustration(
        assetPath: 'assets/images/offline.png',
        mainIcon: Icons.wifi_off_rounded,
        iconColor: AppColors.primary,
        circleBgColor: AppColors.surfaceSubdued,
        badgeIcon: Icons.refresh_rounded,
        badgeBgColor: AppColors.error,
      ),
      title: 'أنت غير متصل بالإنترنت حالياً',
      description: 'يرجى التحقق من اتصال شبكة Wi-Fi أو بيانات الهاتف المحمول. يمكنك تصفح ملخصاتك والطلبات المحفوظة مسبقاً في وضع عدم الاتصال.',
      middleCard: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'ميزات متاحة بدون إنترنت',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'مزامنة سابقة',
                    style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const StatusSuggestionItem(
              icon: Icons.badge_outlined,
              iconBgColor: AppColors.surfaceSubdued,
              iconColor: AppColors.primary,
              title: 'عرض بطاقة دليل+ الطلابية ...',
              subtitle: 'جاهزة للاستخدام في المراكز المعتمدة بدون شبكة',
              trailingIcon: Icons.chevron_left_rounded,
            ),
            const SizedBox(height: 10),
            const StatusSuggestionItem(
              icon: Icons.calendar_month_outlined,
              iconBgColor: AppColors.surfaceSubdued,
              iconColor: AppColors.primary,
              title: 'استعراض مواعيد جلسات التدريس...',
              subtitle: 'جدولك الأكاديمي وملخصات الـ PDF المخزنة',
              trailingIcon: Icons.chevron_left_rounded,
            ),
            const SizedBox(height: 10),
            const StatusSuggestionItem(
              icon: Icons.contact_phone_outlined,
              iconBgColor: AppColors.surfaceSubdued,
              iconColor: AppColors.primary,
              title: 'أرقام هواتف وعناوين مراكز الخدمة...',
              subtitle: 'دليل نقاط شحن الطاقة، خدمات الطباعة، والدعم الطارئ',
              trailingIcon: Icons.chevron_left_rounded,
            ),
          ],
        ),
      ),
      actionButtons: StatusActionButtons(
        primaryLabel: 'إعادة فحص الاتصال',
        primaryIcon: Icons.sync_rounded,
        onPrimaryPressed: controller.checkConnection,
        secondaryLabel: 'تصفح المحتوى المحفوظ أوفلاين',
        secondaryIcon: Icons.folder_zip_outlined,
        onSecondaryPressed: controller.openOfflineContent,
      ),
    );
  }
}
