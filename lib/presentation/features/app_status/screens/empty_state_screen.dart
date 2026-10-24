import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../state/app_status_controller.dart';
import '../widgets/status_action_buttons.dart';
import '../widgets/status_illustration.dart';
import '../widgets/status_page_layout.dart';
import '../widgets/status_suggestion_item.dart';

class EmptyStateScreen extends StatefulWidget {
  final String? searchTerm;
  final VoidCallback? onClearSearch;
  final String title;
  final String description;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final VoidCallback? onResetFilters;
  final VoidCallback? onGoHome;
  final Widget? customMiddleCard;

  const EmptyStateScreen({
    super.key,
    this.searchTerm = 'ذكاء اصطناعي - سنة ثانية',
    this.onClearSearch,
    this.title = 'لم نعثر على نتائج مطابقة',
    this.description = 'جرب تعديل كلمات البحث، أو إزالة بعض فلاتر التصفية والتخصص للعثور على دورات وخدمات جامعية أخرى.',
    this.primaryButtonLabel = 'إعادة ضبط الفلاتر والبحث',
    this.secondaryButtonLabel = 'العودة للرئيسية والتصنيفات',
    this.onResetFilters,
    this.onGoHome,
    this.customMiddleCard,
  });

  @override
  State<EmptyStateScreen> createState() => _EmptyStateScreenState();
}

class _EmptyStateScreenState extends State<EmptyStateScreen> {
  late String? _currentSearchTerm;

  @override
  void initState() {
    super.initState();
    _currentSearchTerm = widget.searchTerm;
  }

  @override
  void didUpdateWidget(covariant EmptyStateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchTerm != oldWidget.searchTerm) {
      _currentSearchTerm = widget.searchTerm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AppStatusController>()
        ? Get.find<AppStatusController>()
        : Get.put(AppStatusController());

    return StatusPageLayout(
      topPillWidget: (_currentSearchTerm != null && _currentSearchTerm!.isNotEmpty)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'بحث عن: "$_currentSearchTerm"',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentSearchTerm = null;
                      });
                      if (widget.onClearSearch != null) {
                        widget.onClearSearch!();
                      } else {
                        controller.clearSearch();
                      }
                    },
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                  ),
                ],
              ),
            )
          : null,
      illustration: const StatusIllustration(
        assetPath: 'assets/images/empty.png',
        mainIcon: Icons.manage_search_rounded,
        iconColor: AppColors.primary,
        circleBgColor: AppColors.surfaceSubdued,
        badgeIcon: Icons.school_rounded,
        badgeBgColor: AppColors.success,
      ),
      title: widget.title,
      description: widget.description,
      middleCard: widget.customMiddleCard ?? _defaultMiddleCard(),
      actionButtons: StatusActionButtons(
        primaryLabel: widget.primaryButtonLabel,
        primaryIcon: Icons.tune_rounded,
        onPrimaryPressed: () {
          if (widget.onResetFilters != null) {
            widget.onResetFilters!();
          } else {
            controller.resetFilters();
          }
        },
        secondaryLabel: widget.secondaryButtonLabel,
        secondaryIcon: Icons.home_rounded,
        onSecondaryPressed: () {
          if (widget.onGoHome != null) {
            widget.onGoHome!();
          } else {
            controller.goToHome();
          }
        },
      ),
    );
  }

  Widget _defaultMiddleCard() {
    return Column(
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
                iconBgColor: AppColors.surfaceSubdued,
                iconColor: AppColors.secondary,
                title: 'استكشاف الأقسام الأربعة الموصى بها لهذا الشهر',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2x2 Search Chips Grid (Matching Figma Design)
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
                    dotColor: AppColors.primary,
                    textColor: AppColors.primary,
                    bgColor: AppColors.surfaceSubdued,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSearchChip(
                    label: 'سكن طالبات قريب',
                    dotColor: AppColors.secondary,
                    textColor: AppColors.textPrimary,
                    bgColor: AppColors.surfaceSubdued,
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
                    dotColor: AppColors.success,
                    textColor: AppColors.textPrimary,
                    bgColor: AppColors.surfaceSubdued,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSearchChip(
                    label: 'تدريب صيفي',
                    dotColor: AppColors.primary,
                    textColor: AppColors.textPrimary,
                    bgColor: AppColors.surfaceSubdued,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildSearchChip({
    required String label,
    required Color dotColor,
    Color textColor = AppColors.textPrimary,
    Color bgColor = AppColors.surfaceSubdued,
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
