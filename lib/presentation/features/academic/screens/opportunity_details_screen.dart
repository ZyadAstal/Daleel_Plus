import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/opportunity_details_controller.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  final String? opportunityId;

  const OpportunityDetailsScreen({super.key, this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      OpportunityDetailsController(opportunityId: opportunityId),
      tag: opportunityId ?? 'default',
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'تفاصيل الفرصة',
            style: AppTextStyles.heading2,
          ),
          actions: [
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.primary,
                ),
                onPressed: controller.toggleBookmark,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppSizes.space8),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: AppSizes.space16),
                    Text(
                      controller.errorMessage.value,
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.space16),
                    AppPrimaryButton(
                      text: 'إعادة المحاولة',
                      onPressed: controller.loadOpportunityDetails,
                    ),
                  ],
                ),
              ),
            );
          }

          final opp = controller.opportunity;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space24,
                  vertical: AppSizes.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Company & Title Card
                    _buildHeaderCard(opp),
                    const SizedBox(height: AppSizes.space16),

                    // 2. Summary Stats Grid
                    _buildStatsGrid(opp),
                    const SizedBox(height: AppSizes.space24),

                    // 3. About Opportunity Section
                    _buildAboutSection(opp),
                    const SizedBox(height: AppSizes.space24),

                    // 4. Requirements Section
                    _buildRequirementsSection(opp),
                    const SizedBox(height: AppSizes.space24),

                    // 5. Perks Section
                    _buildPerksSection(opp),
                    const SizedBox(height: AppSizes.space24),

                    // 6. Detailed Location
                    _buildLocationSection(opp),
                    const SizedBox(height: 110), // Space for bottom action bar
                  ],
                ),
              ),

              // Sticky Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(controller),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> opp) {
    final company = opp['company'] ?? 'شركة تكنوبلاس للحلول الرقمية';
    final companySub = opp['companySub'] ?? 'TechnoPlus Digital Solutions';
    final title = opp['title'] ?? 'تدريب عملي مدفوع: مصمم تجربة وواجهات المستخدم (UI/UX Intern)';
    final location = opp['location'] ?? 'غزة / الرمال - برج الشروق (الطابق الرابع)';
    final statusText = opp['statusText'] ?? 'نشطة ومتاحة';
    final List tags = opp['tags'] ?? [];

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.webhook_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  company,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: AppColors.success),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            companySub,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> opp) {
    final allowance = opp['allowance'] ?? '600 ₪ / شهر';
    final duration = opp['duration'] ?? '3 أشهر تدريبية';
    final deadline = opp['deadline'] ?? 'متبقي 4 أيام (20 أكتوبر)';
    final seats = opp['seats'] ?? '3 متدربين فقط';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.payments_outlined,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF15803D),
                label: 'المكافأة الشهرية',
                value: allowance,
                valueColor: const Color(0xFF15803D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today_rounded,
                iconBg: AppColors.surfaceSubdued,
                iconColor: AppColors.primary,
                label: 'مدة البرنامج',
                value: duration,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.hourglass_top_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFB45309),
                label: 'انتهاء التقديم',
                value: deadline,
                valueColor: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.group_outlined,
                iconBg: AppColors.surfaceSubdued,
                iconColor: AppColors.primary,
                label: 'عدد المقاعد',
                value: seats,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> opp) {
    final about = opp['about'] ?? '';
    final highlight = opp['projectHighlight'] as Map?;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderTitle('نبذة عن فرصة التدريب', AppColors.primary),
          const SizedBox(height: 12),
          Text(about, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textPrimary)),
          if (highlight != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          highlight['title'] ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          highlight['subtitle'] ?? '',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.laptop_chromebook_rounded, color: AppColors.primary, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(Map<String, dynamic> opp) {
    final List reqs = opp['requirements'] ?? [];

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderTitle('الشروط والمتطلبات الأكاديمية', AppColors.primary),
          const SizedBox(height: 16),
          ...reqs.map((r) {
            final IconData icon = r['icon'] ?? Icons.check_circle_outline;
            final title = r['title'] ?? '';
            final subtitle = r['subtitle'] ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPerksSection(Map<String, dynamic> opp) {
    final List perks = opp['perks'] ?? [];

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderTitle('المزايا والحوافز المقدمة للطلاب', const Color(0xFF006A48)),
          const SizedBox(height: 16),
          ...perks.map((p) {
            final IconData icon = p['icon'] ?? Icons.star_rounded;
            final title = p['title'] ?? '';
            final subtitle = p['subtitle'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006A48),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Map<String, dynamic> opp) {
    final location = opp['detailedLocation'] ?? opp['location'] ?? '';

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('موقع الأكاديمية التفصيلي', style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderTitle(String title, Color barColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.heading2),
      ],
    );
  }

  Widget _buildBottomActionBar(OpportunityDetailsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.primary,
                  ),
                  onPressed: controller.toggleBookmark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.applyForOpportunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.unarchive_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'التقديم السريع الآن (إرفاق CV)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
