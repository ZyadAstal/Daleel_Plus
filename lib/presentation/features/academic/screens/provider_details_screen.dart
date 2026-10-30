import 'package:daleel_plus/presentation/features/academic/screens/tutor_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/provider_details_controller.dart';
import '../../providers/state/provider_helpers.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final String? providerId;

  const ProviderDetailsScreen({super.key, this.providerId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderDetailsController(providerId: providerId));

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
          title: Obx(
            () => Text(
              controller.provider['name'] ?? 'تفاصيل المزود',
              style: AppTextStyles.heading2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: [
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isBookmarked.value
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: AppColors.primary,
                ),
                onPressed: controller.toggleBookmark,
                tooltip: 'حفظ المزود',
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
                tooltip: 'الملف الشخصي',
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
                      onPressed: controller.loadProviderData,
                    ),
                  ],
                ),
              ),
            );
          }

          final p = controller.provider;
          final isVerified = p['verificationStatus'] == 'verified';
          final isAccepting = p['isAcceptingOrders'] ?? true;
          final admissionText = p['admissionStatusText'] ?? 'القبول والتسجيل مفتوح';
          final description = p['description'] ?? 'لا تتوفر نبذة تعريفية حالياً.';
          final city = p['city'] ?? 'غزة';
          final address = p['addressDetails'] ?? '';
          final locationStr = address.isEmpty ? city : '$city - $address';
          final rating = (p['averageRating'] ?? 4.9).toDouble();
          final reviewsCount = p['reviewsCount'] ?? 154;
          final providerType = p['providerType'] ?? 'مزود تعليمي وتدريبي مرخص';
          final name = p['name'] ?? 'أكاديمية الإبداع التكنولوجي';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space24,
              vertical: AppSizes.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderHeaderSection(
                  controller: controller,
                  p: p,
                  isVerified: isVerified,
                  isAccepting: isAccepting,
                  admissionText: admissionText,
                  providerType: providerType,
                  description: description,
                  locationStr: locationStr,
                  rating: rating,
                  reviewsCount: reviewsCount,
                  name: name,
                ),
                const SizedBox(height: AppSizes.space24),
                _buildCoursesSection(controller),
                const SizedBox(height: AppSizes.space24),
                _buildInstructorsSection(controller),
                const SizedBox(height: AppSizes.space24),
                _buildReviewsSection(controller),
                const SizedBox(height: AppSizes.bottomNavGap * 2),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProviderHeaderSection({
    required ProviderDetailsController controller,
    required Map<String, dynamic> p,
    required bool isVerified,
    required bool isAccepting,
    required String admissionText,
    required String providerType,
    required String description,
    required String locationStr,
    required double rating,
    required int reviewsCount,
    required String name,
  }) {
    final imageUrl = controller.coverImageUrl;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cover Image at the top inside the same container
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAccepting ? const Color.fromRGBO(0, 106, 72, 1) : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            admissionText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Provider Header Details inside the same container
          Padding(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isVerified) ...[
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  providerType,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: AppTextStyles.heading1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.space16),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space16),
                Text(
                  description,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSizes.space16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        locationStr.isEmpty ? 'الموقع غير متوفر' : locationStr,
                        style: AppTextStyles.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($reviewsCount تقييم معتمد)',
                        style: AppTextStyles.body,
                      ),
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

  Widget _buildCoursesSection(ProviderDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  'الدورات والبرامج المتاحة (${controller.filteredCourses.length} برامج)',
                  style: AppTextStyles.heading2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'تخفيضات دليل+\nسارية',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        SizedBox(
          height: 42,
          child: Obx(
            () => ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                final isSelected = controller.selectedCategory.value == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => controller.selectedCategory.value = cat,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        Obx(() {
          final list = controller.filteredCourses;
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppSizes.space24),
              alignment: Alignment.center,
              child: Text(
                'لا توجد برامج متاحة في هذا القسم حالياً',
                style: AppTextStyles.body,
              ),
            );
          }

          return Column(
            children: list.map((course) => _buildCourseCard(controller, course)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildCourseCard(ProviderDetailsController controller, Map<String, dynamic> course) {
    final badge = course['badge'] ?? course['category_subtag'] ?? course['categorySubtag'] ?? course['category'];
    final discount = course['discount'] ?? ((course['discounted_price'] != null || course['discountedPrice'] != null) ? 'خصم خاص' : null);
    final title = course['title'] ?? course['name'] ?? '';
    final description = course['description'] ?? course['details'] ?? '';
    final totalHours = course['total_hours'] ?? course['totalHours'];
    final duration = course['duration'] ?? (totalHours != null ? '$totalHours ساعة تدريبية' : '');
    final price = course['price'] ?? course['discounted_price'] ?? course['discountedPrice'] ?? course['original_price'] ?? course['originalPrice'];
    final oldPrice = course['oldPrice'] ?? ((course['discounted_price'] != null || course['discountedPrice'] != null) ? course['original_price'] ?? course['originalPrice'] : null);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
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
              Flexible(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ProviderFormat.price(price),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (oldPrice != null)
                    Text(
                      ProviderFormat.price(oldPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textHint,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(description, style: AppTextStyles.body),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(duration, style: AppTextStyles.caption),
                ],
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => controller.openServiceDetails(course),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('عرض التفاصيل والحجز'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorsSection(ProviderDetailsController controller) {
    final List list = controller.provider['instructors'] ?? [];
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الكادر التدريبي المعتمد بالمركز',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSizes.space16),
        ...list.map((item) {
          final name = item['name'] ?? '';
          final title = item['title'] ?? '';
          final initials = item['initials'] ?? (name.isNotEmpty ? name.substring(0, 1) : '');

          return GestureDetector(
            onTap: () => Get.to(TutorProfileScreen()),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(Icons.verified, size: 16, color: AppColors.success),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: AppTextStyles.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewsSection(ProviderDetailsController controller) {
    final reviews = controller.reviews;
    final int reviewsCount = controller.provider['reviewsCount'] ?? reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'آراء وتقييمات الطلاب',
              style: AppTextStyles.heading2,
            ),
            TextButton(
              onPressed: () {
                Get.snackbar('جميع التقييمات', 'عرض جميع تقييمات الطلاب (${ProviderFormat.number(reviewsCount)})');
              },
              child: Text(
                'عرض الكل ($reviewsCount)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        if (reviews.isEmpty)
          const Text('لا توجد تقييمات متاحة حتى الآن.', style: AppTextStyles.body)
        else
          Column(
            children: reviews.map((rev) {
              final name = rev['name'] ?? 'طالب دبلوم';
              final tag = rev['tag'] ?? 'تقييم موثق';
              final comment = rev['comment'] ?? rev['text'] ?? '';
              final rating = (rev['rating'] ?? 5.0).toDouble();
              final initials = rev['initials'] ?? (name.isNotEmpty ? name.substring(0, 1) : '');

              return Container(
                margin: const EdgeInsets.only(bottom: AppSizes.cardPadding),
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
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubdued,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            rating.toInt(),
                            (_) => const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      comment,
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class ContainerPlaceholder extends StatelessWidget {
  const ContainerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFFFAF9FF);
    return Container(
      color: scaffoldBg,
    );
  }
}
