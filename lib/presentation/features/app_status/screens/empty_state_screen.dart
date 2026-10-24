import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';
import '../widgets/status_action_buttons.dart';
import '../widgets/status_illustration.dart';
import '../widgets/status_page_layout.dart';
import '../widgets/status_suggestion_item.dart';

class EmptyStateScreen extends GetView<AppStatusController> {
  const EmptyStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusPageLayout(
      topPillWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 14, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              'بحث عن: "ذكاء اصطناعي - سنة ثانية"',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
          ],
        ),
      ),
      illustration: const StatusIllustration(
        assetPath: 'assets/images/empty.png',
        mainIcon: Icons.manage_search_rounded,
        iconColor: AppColors.primary,
        circleBgColor: AppColors.surfaceSubdued,
        badgeIcon: Icons.school_rounded,
        badgeBgColor: AppColors.success,
      ),
      title: 'لم نعثر على نتائج مطابقة',
      description: 'جرب تعديل كلمات البحث، أو إزالة بعض فلاتر التصفية والتخصص للعثور على دورات وخدمات جامعية أخرى.',
      middleCard: Column(
        children: [
          // Suggestions Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'اقترحات مفيدة للوصول لطلبك',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                StatusSuggestionItem(
                  icon: Icons.explore_outlined,
                  iconBgColor: AppColors.surfaceSubdued,
                  iconColor: AppColors.primary,
                  title: 'توسيع النطاق الجغرافي ليشمل كافة الجامعات',
                ),
                SizedBox(height: 10),
                StatusSuggestionItem(
                  icon: Icons.grid_view_rounded,
                  iconBgColor: Color(0xFFFEF3C7),
                  iconColor: Color(0xFFD97706),
                  title: 'استكشاف الأقسام الأربعة الموصى بها لهذا الشهر',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2x2 Search Chips Grid (Matching Figma Design Exactly)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'جرب البحث في المجالات الأكثر طلباً:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    'تحديث مستمر',
                    style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSearchChip(
                      label: 'ملخصات هندسية',
                      dotColor: const Color(0xFF5E42E2),
                      textColor: const Color(0xFF5E42E2),
                      bgColor: const Color(0xFFEDE9FE),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSearchChip(
                      label: 'سكن طالبات قريب',
                      dotColor: const Color(0xFFB45309),
                      textColor: AppColors.textPrimary,
                      bgColor: const Color(0xFFE0E7FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSearchChip(
                      label: 'مدرس خصوصي إحصاء',
                      dotColor: const Color(0xFF047857),
                      textColor: AppColors.textPrimary,
                      bgColor: const Color(0xFFE0E7FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSearchChip(
                      label: 'تدريب صيفي',
                      dotColor: const Color(0xFF5E42E2),
                      textColor: AppColors.textPrimary,
                      bgColor: const Color(0xFFE0E7FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actionButtons: StatusActionButtons(
        primaryLabel: 'إعادة ضبط الفلاتر والبحث',
        primaryIcon: Icons.tune_rounded,
        onPrimaryPressed: controller.resetFilters,
        secondaryLabel: 'العودة للرئيسية والتصنيفات',
        secondaryIcon: Icons.home_rounded,
        onSecondaryPressed: controller.goToHome,
      ),
    );
  }

  static Widget _buildSearchChip({
    required String label,
    required Color dotColor,
    Color textColor = AppColors.textPrimary,
    Color bgColor = const Color(0xFFE0E7FF),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
