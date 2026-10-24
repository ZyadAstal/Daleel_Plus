import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';
import '../widgets/status_action_buttons.dart';
import '../widgets/status_illustration.dart';
import '../widgets/status_page_layout.dart';
import '../widgets/status_suggestion_item.dart';

class NotFoundScreen extends GetView<AppStatusController> {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusPageLayout(
      illustration: const StatusIllustration(
        assetPath: 'assets/images/not_found.png',
        mainIcon: Icons.school_rounded,
        centerText: '404',
        iconColor: AppColors.primary,
        circleBgColor: AppColors.surfaceSubdued,
        badgeIcon: Icons.auto_awesome,
        badgeBgColor: AppColors.secondary,
      ),
      title: 'عذراً، هذه الصفحة غير متوفرة',
      description: 'يبدو أن الرابط الذي تبحث عنه قد تم نقله، أو أن الدورة التدريبية أو المنحة الدراسية قد انتهت صلاحيتها واكتمل عدد مقاعدها.',
      middleCard: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.explore_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'قد يهمك استكشاف بدائل مشابهة:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'مقترح لك',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const StatusSuggestionItem(
              icon: Icons.school_outlined,
              iconBgColor: AppColors.surfaceSubdued,
              iconColor: AppColors.primary,
              title: 'أحدث الدورات والمعسكرات المتاحة للتسجيل...',
              subtitle: 'برمجة، تصميم، لغات، وإدارة أعمال',
            ),
            const SizedBox(height: 10),
            const StatusSuggestionItem(
              icon: Icons.workspace_premium_outlined,
              iconBgColor: Color(0xFFE0F2FE),
              iconColor: Color(0xFF0284C7),
              title: 'فرص التدريب والمنح الشاغرة هذا الأسبوع...',
              subtitle: 'فرص ممولة بالكامل وتدريب تحفيزي للطلاب',
            ),
            const SizedBox(height: 10),
            const StatusSuggestionItem(
              icon: Icons.print_outlined,
              iconBgColor: Color(0xFFFEF3C7),
              iconColor: Color(0xFFD97706),
              title: 'خدمات طباعة الأبحاث ومشاريع التخرج...',
              subtitle: 'مكتبات معتمدة مع تسليم مباشر للجامعة',
            ),
          ],
        ),
      ),
      actionButtons: StatusActionButtons(
        primaryLabel: 'الذهاب إلى الشاشة الرئيسية',
        primaryIcon: Icons.home_rounded,
        onPrimaryPressed: controller.goToHome,
        secondaryLabel: 'البحث في أقسام التطبيق',
        secondaryIcon: Icons.search_rounded,
        onSecondaryPressed: controller.goToSearch,
      ),
    );
  }
}
