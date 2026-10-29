import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/course_details_controller.dart';
import 'provider_details_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String? courseId;

  const CourseDetailsScreen({super.key, this.courseId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CourseDetailsController(courseId: courseId),
      tag: courseId ?? 'default',
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
          title: Obx(
            () {
              final model = controller.courseModel.value;
              final title = model?.title ?? controller.course['title'] ?? 'تفاصيل الدورة';
              return Text(
                title,
                style: AppTextStyles.heading2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
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
                      onPressed: controller.loadCourseDetails,
                    ),
                  ],
                ),
              ),
            );
          }

          final c = controller.course;
          final p = controller.provider;

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
                    // 1. Top Category & Bookmark Row
                    _buildCategoryRow(controller, c),
                    const SizedBox(height: AppSizes.space16),

                    // 2. Hero Image Banner with Badges & Title
                    _buildHeroBanner(controller, c),
                    const SizedBox(height: AppSizes.space16),

                    // 3. Service Center Card
                    _buildCenterCard(p),
                    const SizedBox(height: AppSizes.space24),

                    // 4. Overview & Pricing Card
                    _buildOverviewCard(controller, c),
                    const SizedBox(height: AppSizes.space24),

                    // 5. Curriculum Modules
                    _buildCurriculumSection(controller, c),
                    const SizedBox(height: AppSizes.space24),

                    // 6. Lead Instructor
                    _buildInstructorSection(controller, c),
                    const SizedBox(height: AppSizes.space24),

                    // 7. Amenities & Facilities
                    _buildAmenitiesSection(c),
                    const SizedBox(height: AppSizes.space24),

                    // 8. Reviews Section
                    _buildReviewsSection(controller),
                    const SizedBox(height: 120), // Bottom padding for sticky action bar
                  ],
                ),
              ),

              // Sticky Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(controller, c),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryRow(CourseDetailsController controller, Map<String, dynamic> c) {
    final model = controller.courseModel.value;
    final category = model?.categorySubtag.isNotEmpty == true
        ? model!.categorySubtag
        : (c['category_subtag'] ?? c['category'] ?? 'دورات وتعليم • دبلوم مهني معتمد');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubdued,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.primary,
            ),
            onPressed: controller.toggleBookmark,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(CourseDetailsController controller, Map<String, dynamic> c) {
    final model = controller.courseModel.value;
    final imageUrl = (model?.coverImageUrl.isNotEmpty == true
        ? model!.coverImageUrl
        : (c['cover_image_url'] ?? c['imageUrl'])) ?? 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80';
    
    final discountTag = model?.hasDiscount == true
        ? 'خصم ${model!.discountPercentage}% لطلاب دليل+'
        : (c['discountTag'] ?? 'خصم 20% لطلاب دليل+');
        
    final rating = c['rating'] ?? 4.9;
    final studentsCount = c['studentsCount'] ?? 148;
    final title = model?.title.isNotEmpty == true ? model!.title : (c['title'] ?? '');

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              left: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      discountTag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '$rating ($studentsCount طالب)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCard(Map<String, dynamic> p) {
    final name = p['name'] ?? 'أكاديمية الإبداع التكنولوجي';
    final address = p['address'] ?? 'غزة - الرمال، شارع الوحدة';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
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
                        name,
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
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () => Get.to(() => const ProviderDetailsScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceSubdued,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('المركز'),
                SizedBox(width: 4),
                Icon(Icons.arrow_back, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(CourseDetailsController controller, Map<String, dynamic> c) {
    final model = controller.courseModel.value;
    final fullTitle = model?.title.isNotEmpty == true
        ? model!.title
        : (c['fullTitle'] ?? c['title'] ?? 'دبلوم تطوير الويب المتكامل Full-Stack Web Development');
        
    final List features = c['features'] ?? [
      '${model?.totalHours ?? 120} ساعة تدريبية معتمدة ومكثفة',
      'نمط الحضور: ${model?.attendanceModeText ?? 'وجاهي بالقاعة الذكية'}',
      'المستوى: ${model?.targetLevelText ?? 'مبتدئ إلى متقدم'}',
    ];

    final effectivePrice = model?.effectivePrice ?? (c['price'] ?? 260.0).toDouble();
    final originalPrice = model?.originalPrice ?? (c['oldPrice'] ?? 350.0).toDouble();

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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'مسار وظيفي واعد',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  model?.hasAccreditedCertificate == true ? 'شهادة مهنية معتمدة' : 'شهادة تدريب',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fullTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
          ),
          const SizedBox(height: 16),
          // Features List Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeatureRow(Icons.access_time_rounded, features.isNotEmpty ? features[0] : ''),
                const SizedBox(height: 10),
                _buildFeatureRow(Icons.calendar_month_outlined, features.length > 1 ? features[1] : ''),
                const SizedBox(height: 10),
                _buildFeatureRow(Icons.desktop_windows_outlined, features.length > 2 ? features[2] : ''),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Pricing Banner Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الرسوم الأكاديمية للطلاب',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${effectivePrice.toStringAsFixed(0)} ₪',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        if (originalPrice > effectivePrice) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${originalPrice.toStringAsFixed(0)} ₪',
                            style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: AppColors.textHint),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        model?.hasDiscount == true
                            ? 'وفر ${model!.discountPercentage}% ببطاقة دليل+'
                            : 'وفر 20% ببطاقة دليل+',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'خصم فوري حصري عبر التطبيق',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculumSection(CourseDetailsController controller, Map<String, dynamic> c) {
    final List modules = c['modules'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('محاور المنهج التعليمي', style: AppTextStyles.heading2),
                  SizedBox(height: 2),
                  Text('4 وحدات عملية تؤهلك لسوق العمل الحر والشركات', style: AppTextStyles.caption),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'محدث لعام 2026',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        ...List.generate(modules.length, (index) {
          final mod = modules[index];
          final num = mod['number'] ?? (index + 1);
          final title = mod['title'] ?? '';
          final subtitle = mod['subtitle'] ?? '';
          final content = mod['content'] ?? '';

          return Obx(() {
            final isExpanded = controller.expandedModules[index] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => controller.toggleModule(index),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$num',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    subtitle: Text(subtitle, style: AppTextStyles.caption),
                    trailing: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        content,
                        style: AppTextStyles.body,
                      ),
                    ),
                ],
              ),
            );
          });
        }),
      ],
    );
  }

  Widget _buildInstructorSection(CourseDetailsController controller, Map<String, dynamic> c) {
    final model = controller.courseModel.value;
    final inst = c['instructor'] ?? {};
    final name = model?.instructorName ?? inst['name'] ?? 'م. محمد عبد الله';
    final badge = inst['badge'] ?? 'معتمد دولياً';
    final role = inst['role'] ?? 'Senior Full-Stack Engineer & Mentor';
    final experience = inst['experience'] ?? 'أكثر من 8+ سنوات خبرة دولية';
    final bio = inst['bio'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المدرب المشرف على الدبلوم', style: AppTextStyles.heading2),
        const SizedBox(height: AppSizes.space16),
        Container(
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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.surfaceSubdued,
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1) : '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(role, style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text('5.0 • $experience', style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(bio, style: AppTextStyles.body),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(Map<String, dynamic> c) {
    final List amenities = c['amenities'] ?? [];
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المرافق والامتيازات المشمولة', style: AppTextStyles.heading2),
        const SizedBox(height: AppSizes.space16),
        ...amenities.map((item) {
          final IconData icon = item['icon'] ?? Icons.check_circle_outline;
          final title = item['title'] ?? '';
          final subtitle = item['subtitle'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewsSection(CourseDetailsController controller) {
    final reviews = controller.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('آراء وتقييمات الطلاب', style: AppTextStyles.heading2),
            TextButton(
              onPressed: () {},
              child: const Text('عرض كل التقييمات', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        ...reviews.map((rev) {
          final name = rev['name'] ?? '';
          final tag = rev['tag'] ?? '';
          final comment = rev['comment'] ?? '';
          final rating = (rev['rating'] ?? 5.0).toDouble();
          final initials = rev['initials'] ?? (name.isNotEmpty ? name.substring(0, 1) : '');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surfaceSubdued,
                      child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.success)),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        rating.toInt(),
                        (_) => const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(comment, style: AppTextStyles.body),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActionBar(CourseDetailsController controller, Map<String, dynamic> c) {
    final model = controller.courseModel.value;
    final double price = model?.effectivePrice ?? (c['price'] ?? 260.0).toDouble();
    final double oldPrice = model?.originalPrice ?? (c['oldPrice'] ?? 350.0).toDouble();
    final double saved = model?.savedAmount ?? (c['savedAmount'] ?? 90.0).toDouble();
    final int remainingSeats = c['remainingSeats'] ?? 4;

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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '• وفرت ${saved.toStringAsFixed(2)} ₪',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${price.toStringAsFixed(2)} ₪',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    if (oldPrice > price) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${oldPrice.toStringAsFixed(2)} ₪',
                        style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: AppColors.textHint),
                      ),
                    ],
                  ],
                ),
                const Text(
                  'شامل الحقيبة والشهادة',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.bookCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('احجز مقعدك الآن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_back, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'متبقي $remainingSeats مقاعد فقط في هذه الشعبة',
                    style: const TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
