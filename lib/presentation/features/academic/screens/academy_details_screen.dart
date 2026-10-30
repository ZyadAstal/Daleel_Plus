import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/academy_details_controller.dart';
import 'course_details_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/not_found_screen.dart';

class AcademyDetailsScreen extends StatelessWidget {
  final String providerId;

  const AcademyDetailsScreen({super.key, required this.providerId});

  static void open(String providerId) {
    Get.to(() => AcademyDetailsScreen(providerId: providerId), preventDuplicates: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcademyDetailsController(providerId), tag: providerId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: StudentTopBar(
        title: '',
        actions: [
          Obx(
                () => IconButton(
              onPressed: controller.toggleFavorite,
              icon: Icon(
                controller.isFavorite.value ? Icons.bookmark : Icons.bookmark_border,
                color: controller.isFavorite.value ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_outline, color: AppColors.white, size: 18),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return SystemErrorScreen(
            description: controller.errorMessage.value,
            showSafetyCard: false,
            errorDetails: null,
            apiPath: null,
            timeoutText: null,
            onRetry: controller.retry,
          );
        }

        if (controller.provider.isEmpty) {
          return const NotFoundScreen();
        }

        final courses = controller.courses;

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            _InfoCard(controller: controller),
            const SizedBox(height: AppSizes.space24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الدورات والبرامج المتاحة (${controller.coursesCount} برامج)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                if (controller.hasDiscounts)
                  const Text(
                    'تخفيضات دليل+ سارية',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['', ...controller.categories].map((category) {
                  final isSelected = controller.selectedCategory.value == category;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSizes.space8),
                    child: GestureDetector(
                      onTap: () => controller.changeCategory(category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.isEmpty ? 'الكل' : category,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            if (courses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.space16),
                child: Center(
                  child: Text('لا توجد برامج متاحة حاليًا', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ...courses.map((course) => _CourseCard(course: course)),
            if (controller.instructors.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space8),
              Container(
                padding: const EdgeInsets.all(AppSizes.space16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الكادر التدريبي المعتمد بالمركز',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ...controller.instructors.map((instructor) => _InstructorTile(instructor: instructor)),
                  ],
                ),
              ),
            ],
            if (controller.reviews.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'آراء وتقييمات الطلاب',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                  if (controller.reviews.length > 2)
                    GestureDetector(
                      onTap: controller.showAllReviews.toggle,
                      child: Text(
                        controller.showAllReviews.value ? 'عرض أقل' : 'عرض الكل (${controller.reviewsCount})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...controller.visibleReviews.map((review) => _ReviewCard(review: review)),
            ],
          ],
        );
      }),
    );
  }
}

BoxDecoration _cardDecoration({double radius = 20}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );
}

class _InfoCard extends StatelessWidget {
  final AcademyDetailsController controller;

  const _InfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final provider = controller.provider;
      final cover = controller.text('coverImageUrl');
      final bool isVerified = provider['isVerified'] ?? false;
      final bool isOpen = provider['isAdmissionOpen'] ?? true;
      final num rating = provider['averageRating'] ?? 0;
      final location = [controller.text('city'), controller.text('addressDetails')]
          .where((text) => text.isNotEmpty)
          .join(' / ');

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 170,
                  color: AppColors.surfaceSubdued,
                  child: cover.isEmpty
                      ? const Icon(Icons.image_outlined, color: AppColors.textHint)
                      : Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textHint),
                  ),
                ),
                PositionedDirectional(
                  top: 12,
                  start: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isOpen ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOpen ? 'القبول والتسجيل مفتوح' : 'التسجيل مغلق حاليًا',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
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
                            if (isVerified)
                              const Row(
                                children: [
                                  Icon(Icons.verified, size: 16, color: AppColors.success),
                                  SizedBox(width: 4),
                                  Text(
                                    'مزود تعليمي وتدريبي مرخص',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            Text(
                              controller.text('businessName'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.school_outlined, color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (controller.text('description').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      controller.text('description'),
                      style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
                    ),
                  ],
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(location, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ],
                  if (rating > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                          Text(
                            ' $rating',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            ' (${controller.reviewsCount} تقييم معتمد)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final num original = course['originalPrice'] ?? 0;
    final num? discounted = course['discountedPrice'];
    final price = discounted ?? original;
    final discount = discounted == null || original == 0 ? 0 : ((original - discounted) / original * 100).round();
    final num hours = course['totalHours'] ?? 0;
    final category = (course['categorySubtag'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
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
                    Wrap(
                      spacing: 6,
                      children: [
                        if (category.isNotEmpty) _Tag(text: category, color: AppColors.primary),
                        if (discount > 0) _Tag(text: 'خصم $discount%', color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course['title'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.space8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₪ ${AcademyDetailsController.money(price)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  if (discount > 0)
                    Text(
                      '₪ ${AcademyDetailsController.money(original)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if ((course['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              course['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const Divider(height: 24, color: AppColors.border),
          Row(
            children: [
              if (hours > 0) ...[
                const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('$hours ساعة تدريبية', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => CourseDetailsScreen.open(course['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                  child: const Text(
                    'عرض التفاصيل والحجز',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;

  const _Avatar({required this.imageUrl, required this.name, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: imageUrl.isEmpty
          ? Text(
        AcademyDetailsController.initials(name),
        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
      )
          : Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Text(AcademyDetailsController.initials(name)),
      ),
    );
  }
}

class _InstructorTile extends StatelessWidget {
  final Map<String, dynamic> instructor;

  const _InstructorTile({required this.instructor});

  @override
  Widget build(BuildContext context) {
    final name = (instructor['name'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceSubdued, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _Avatar(imageUrl: (instructor['avatarUrl'] ?? '').toString(), name: name),
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
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_outlined, size: 16, color: AppColors.primary),
                  ],
                ),
                Text(
                  instructor['title'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final num rating = review['rating'] ?? 0;
    final bool isAnonymous = review['isAnonymous'] ?? false;
    final name = isAnonymous ? 'طالب جامعي' : (review['studentName'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                child: Text(
                  AcademyDetailsController.initials(name),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    if (!isAnonymous)
                      Text(
                        '${review['studentInfo'] ?? ''} - تقييم موثق',
                        style: const TextStyle(fontSize: 11, color: AppColors.success),
                      ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review['comment'] ?? '',
            style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}