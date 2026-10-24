import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';
import '../widgets/status_action_buttons.dart';
import '../widgets/status_illustration.dart';
import '../widgets/status_page_layout.dart';
import '../widgets/status_suggestion_item.dart';

class NotFoundScreen extends StatelessWidget {
  final String title;
  final String description;
  final String errorCodeText;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final VoidCallback? onGoHome;
  final VoidCallback? onGoSearch;
  final Widget? customMiddleCard;

  const NotFoundScreen({
    super.key,
    this.title = 'عذراً، هذه الصفحة غير متوفرة',
    this.description = 'يبدو أن الرابط الذي تبحث عنه قد تم نقله، أو أن الدورة التدريبية أو المنحة الدراسية قد انتهت صلاحيتها واكتمل عدد مقاعدها.',
    this.errorCodeText = '404',
    this.primaryButtonLabel = 'الذهاب إلى الشاشة الرئيسية',
    this.secondaryButtonLabel = 'البحث في أقسام التطبيق',
    this.onGoHome,
    this.onGoSearch,
    this.customMiddleCard,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AppStatusController>()
        ? Get.find<AppStatusController>()
        : Get.put(AppStatusController());

    return StatusPageLayout(
      illustration: StatusIllustration(
        assetPath: 'assets/images/not_found.png',
        mainIcon: Icons.school_rounded,
        centerText: errorCodeText,
        iconColor: AppColors.primary,
        circleBgColor: AppColors.surfaceSubdued,
        badgeIcon: Icons.auto_awesome,
        badgeBgColor: AppColors.secondary,
      ),
      title: title,
      description: description,
      middleCard: customMiddleCard ?? _defaultMiddleCard(),
      actionButtons: StatusActionButtons(
        primaryLabel: primaryButtonLabel,
        primaryIcon: Icons.home_rounded,
        onPrimaryPressed: () {
          if (onGoHome != null) {
            onGoHome!();
          } else {
            controller.goToHome();
          }
        },
        secondaryLabel: secondaryButtonLabel,
        secondaryIcon: Icons.search_rounded,
        onSecondaryPressed: () {
          if (onGoSearch != null) {
            onGoSearch!();
          } else {
            controller.goToSearch();
          }
        },
      ),
    );
  }

  Widget _defaultMiddleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.02),
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
            iconBgColor: AppColors.surfaceSubdued,
            iconColor: AppColors.primary,
            title: 'فرص التدريب والمنح الشاغرة هذا الأسبوع...',
            subtitle: 'فرص ممولة بالكامل وتدريب تحفيزي للطلاب',
          ),
          const SizedBox(height: 10),
          const StatusSuggestionItem(
            icon: Icons.print_outlined,
            iconBgColor: AppColors.surfaceSubdued,
            iconColor: AppColors.secondary,
            title: 'خدمات طباعة الأبحاث ومشاريع التخرج...',
            subtitle: 'مكتبات معتمدة مع تسليم مباشر للجامعة',
          ),
        ],
      ),
    );
  }
}
