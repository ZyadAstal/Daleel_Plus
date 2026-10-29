import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/private_tutors_controller.dart';

class PrivateTutorsScreen extends StatelessWidget {
  const PrivateTutorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrivateTutorsController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            'المدرسون الخصوصيون والمدربون',
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
                      onPressed: controller.loadTutors,
                    ),
                  ],
                ),
              ),
            );
          }

          final list = controller.filteredTutors;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space24,
              vertical: AppSizes.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Search Bar with Mic & Filter Button
                _buildSearchBar(controller),
                const SizedBox(height: AppSizes.space16),

                // 2. Horizontal Category Filter Chips
                _buildCategoryFilters(controller),
                const SizedBox(height: AppSizes.space16),

                // 3. Accredited Tutors Banner ("مدرسون جامعيون معتمدون")
                _buildAccreditedTutorsBanner(),
                const SizedBox(height: 20),

                // 4. Tutors List or Empty State
                if (list.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space24),
                    alignment: Alignment.center,
                    child: const Text(
                      'لا يوجد مدرسون مطبقون لشروط البحث حالياً',
                      style: AppTextStyles.body,
                    ),
                  )
                else
                  Column(
                    children: list
                        .map((tutor) => _buildTutorCard(controller, tutor))
                        .toList(),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar(PrivateTutorsController controller) {
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
                hintText: 'ابحث باسم المدرس، المساق، التخصص...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () {
              Get.snackbar('البحث الصوتي', 'انطق اسم المدرس أو المساق للبحث');
            },
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
              onPressed: () {
                Get.snackbar('تصفية المدرسين', 'تصفية حسب الجامعة، السعر، والتخصص');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(PrivateTutorsController controller) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.categoryFilters.length,
        itemBuilder: (context, index) {
          final filter = controller.categoryFilters[index];

          return Obx(() {
            final bool isSel = controller.selectedCategory.value == filter.title;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => controller.selectCategory(filter.title),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.icon,
                        size: 16,
                        color: isSel ? Colors.white : (filter.iconColor ?? AppColors.primary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter.title,
                        style: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildAccreditedTutorsBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مدرسون جامعيون معتمدون',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'ضمان جودة الشرح ومراجعة شاملة للامتحانات النصفية والنهائية',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF006A48),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'معتمد 100%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(PrivateTutorsController controller, Map<String, dynamic> tutor) {
    final name = tutor['name'] ?? 'د. إبراهيم النجار';
    final university = tutor['university'] ?? 'الجامعة الإسلامية & الأزهر';
    final expYears = tutor['experienceYears'] ?? 8;
    final rating = (tutor['rating'] ?? 4.9).toDouble();
    final reviewsCount = tutor['reviewsCount'] ?? 142;
    final hourlyRate = tutor['hourlyRate'] ?? 40;
    final avatarUrl = tutor['avatarUrl'] ?? '';
    final List subjects = tutor['subjects'] ?? ['تفاضل وتكامل 1 & 2', 'جبر خطي', 'رياضيات منفصلة'];
    final attendanceMode = tutor['attendanceMode'] ?? 'وجاهي وعن بعد';

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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.surfaceSubdued,
                                child: const Icon(Icons.person, size: 30, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF15803D),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 12, color: Color(0xFF15803D)),
                                    SizedBox(width: 3),
                                    Text(
                                      'موثق معتمد',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'دكتورة في الرياضيات وتطبيقها\nالحاسوب • خبرة $expYears سنوات',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            university,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceSubdued,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bookmark_border_rounded, size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 2),
                            Text(
                              '$rating',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '($reviewsCount تقييم\nطلابي)',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...subjects.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.domain_outlined, size: 14, color: Color(0xFF15803D)),
                          const SizedBox(width: 4),
                          Text(
                            attendanceMode,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
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
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$hourlyRate ₪',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/ ساعة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => controller.openTutorProfile(tutor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض الملف والحجز',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_back, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
