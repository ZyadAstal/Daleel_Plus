import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/opportunities_controller.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OpportunitiesController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            'الفرص والتدريب العملي',
            style: AppTextStyles.heading2,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: AppColors.primary),
              onPressed: () {},
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
                      onPressed: controller.loadOpportunities,
                    ),
                  ],
                ),
              ),
            );
          }

          final list = controller.filteredOpportunities;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space24,
              vertical: AppSizes.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Applied Applications Banner ("طلباتي المُقدمة")
                _buildSubmittedApplicationsBanner(),
                const SizedBox(height: AppSizes.space16),

                // 2. Search & Filter Bar
                _buildSearchBar(controller),
                const SizedBox(height: AppSizes.space16),

                // 3. Section Header: "أحدث الفرص المعلنة" + "محدث اليوم"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'أحدث الفرص المعلنة',
                      style: AppTextStyles.heading2,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'محدث اليوم',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space16),

                // 4. Header & Category Filters
                _buildHeaderFilters(controller),
                const SizedBox(height: AppSizes.space16),

                // 5. Opportunities List or Empty State
                if (list.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space24),
                    alignment: Alignment.center,
                    child: const Text(
                      'لا توجد فرص تدريبية متاحة حالياً تطابق بحثك',
                      style: AppTextStyles.body,
                    ),
                  )
                else
                  Column(
                    children: list
                        .map((opp) => _buildOpportunityCard(controller, opp))
                        .toList(),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubmittedApplicationsBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'طلباتي المُقدمة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '2 قيد المراجعة',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  'مؤسسة الحلول المتقدمة + برنامج إراسموس+',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(OpportunitiesController controller) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: const InputDecoration(
                hintText: 'ابحث عن وظيفة، تدريب، أو تط...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 2),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderFilters(OpportunitiesController controller) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.filters.length,
        itemBuilder: (context, index) {
          final filter = controller.filters[index];
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => controller.selectedFilter.value = filter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildOpportunityCard(OpportunitiesController controller, Map<String, dynamic> opp) {
    final company = opp['company'] ?? 'شركة الحلول المتقدمة للحلول الرقمية';
    final title = opp['title'] ?? 'متدرب هندسة برمجيات Front-End (React)';
    final allowance = opp['allowance'] ?? 'مكافأة 800 ₪';
    final workMode = opp['workMode'] ?? 'دوام هجين';
    final deadline = opp['deadline'] ?? 'متبقي 5 أيام';
    final requirementHint = opp['requirementHint'] ?? 'يتطلب معرفة بـ React و Tailwind';
    final logoUrl = opp['logoUrl'] ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=200&q=80';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_rounded, color: AppColors.primary, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_border_rounded, size: 18, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.payments_outlined, size: 14, color: Color(0xFF15803D)),
                          const SizedBox(width: 4),
                          Text(
                            allowance,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.work_outline_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            workMode,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            deadline,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFE),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(top: BorderSide(color: Color(0xFFF1F1F8))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        requirementHint,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF15803D)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => controller.openOpportunityDetails(opp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: const Text(
                    'قدم الآن',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                )


              ],
            ),
          ),
        ],
      ),
    );
  }
}
