import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/tutor_profile_controller.dart';

class TutorProfileScreen extends StatelessWidget {
  final String? tutorId;

  const TutorProfileScreen({super.key, this.tutorId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TutorProfileController(tutorId: tutorId),
      tag: tutorId ?? 'default',
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
            'الملف الأكاديمي للمدرس',
            style: AppTextStyles.heading2,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.primary),
              onPressed: () {},
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
                      onPressed: controller.loadTutorProfile,
                    ),
                  ],
                ),
              ),
            );
          }

          final t = controller.tutor;

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
                    // 1. Tutor Header & Stats Card
                    _buildTutorHeader(controller, t),
                    const SizedBox(height: AppSizes.space24),

                    // 2. Academic Philosophy & Bio
                    _buildPhilosophySection(t),
                    const SizedBox(height: AppSizes.space24),

                    // 3. Courses & Subjects
                    _buildCoursesSection(t),
                    const SizedBox(height: AppSizes.space24),

                    // 4. Teaching Method & Venue
                    _buildTeachingMethodsSection(t),
                    const SizedBox(height: AppSizes.space24),

                    // 5. Student Reviews
                    _buildReviewsSection(controller),
                    const SizedBox(height: 120), // Bottom padding for sticky bar
                  ],
                ),
              ),

              // Sticky Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(controller, t),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTutorHeader(TutorProfileController controller, Map<String, dynamic> t) {
    final name = t['name'] ?? 'د. إبراهيم النجار';
    final title = t['title'] ?? '';
    final rating = t['rating'] ?? 4.9;
    final reviewsSub = t['reviewsSub'] ?? '142 تقييم موثق من طلاب الأزهر والإسلامية';
    final expYears = t['experienceYears'] ?? 8;
    final sessions = t['completedSessions'] ?? 380;
    final satisfaction = t['satisfactionRate'] ?? 99;
    final hourlyRate = t['hourlyRate'] ?? 40;
    final avatarUrl = t['avatarUrl'] ?? '';

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar + Status Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceSubdued,
                      child: const Icon(Icons.person, size: 48, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Color(0xFF15803D)),
                      SizedBox(width: 4),
                      Text(
                        'متاح اليوم',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '🎓 المدرسون الخصوصيون المعتمدون',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$rating',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  '($reviewsSub)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stats Row (4 metrics)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: _buildHeaderMetric('الخبرة', '$expYears سنوات', 'تدريس جامعي')),
                Expanded(child: _buildHeaderMetric('الجلسات', '+$sessions', 'جلسة مكتملة')),
                Expanded(child: _buildHeaderMetric('نسبة الرضا', '$satisfaction%', 'توصية طلابية')),
                Expanded(child: _buildHeaderMetric('سعر الساعة', '$hourlyRate ₪', 'جلسة فردية', isPrimary: true)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons Row
          Row(
            children: [
              _buildActionButton(
                title: 'موقع القاعة',
                icon: Icons.location_on_outlined,
                onPressed: () {
                  Get.snackbar('موقع القاعة', t['location'] ?? '');
                },
                bgColor: AppColors.surfaceSubdued,
                fgColor: AppColors.primary,
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                title: 'واتساب فوري',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: controller.openWhatsapp,
                bgColor: const Color(0xFF4ADE80),
                fgColor: const Color(0xFF064E3B),
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                title: 'اتصال مباشر',
                icon: Icons.phone_outlined,
                onPressed: controller.makeDirectCall,
                bgColor: AppColors.surfaceSubdued,
                fgColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required Color bgColor,
    required Color fgColor,
  }) {
    return Expanded(
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: fgColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value, String sub, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isPrimary ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ],
    );
  }

  Widget _buildPhilosophySection(Map<String, dynamic> t) {
    final bio = t['bio'] ?? '';
    final List philosophies = t['philosophies'] ?? [];

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
          _buildSectionHeaderTitle('نبذة أكاديمية وفلسفة التدريس', AppColors.primary),
          const SizedBox(height: 12),
          Text(bio, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ...philosophies.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    item.toString(),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(Map<String, dynamic> t) {
    final List courses = t['courses'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: const Text('المساقات والمواد المتاحة للتدريس', style: AppTextStyles.heading2)),
            Text(
              '${courses.length} مساقات رئيسية',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        ...courses.map((course) {
          final code = course['code'] ?? '';
          final name = course['name'] ?? '';
          final badge = course['badge'];
          final pill = course['pill'];
          final iconType = course['icon'] ?? 'book';

          IconData getIcon() {
            switch (iconType) {
              case 'math':
                return Icons.functions_rounded;
              case 'code':
                return Icons.account_tree_outlined;
              case 'grid':
                return Icons.grid_view_rounded;
              case 'stats':
                return Icons.insights_rounded;
              default:
                return Icons.menu_book_rounded;
            }
          }

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
                // 1. Right side: Course Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(getIcon(), color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                // 2. Center: Course Name & English Subtitle
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
                        code,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 3. Left side: Badge or Pill Tag
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  )
                else if (pill != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pill,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTeachingMethodsSection(Map<String, dynamic> t) {
    final List modes = t['teachingModes'] ?? [];
    final location = t['location'] ?? '';
    final List amenities = t['amenities'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('طريقة التدريس والمواعيد', style: AppTextStyles.heading2),
        const SizedBox(height: AppSizes.space16),
        Row(
          children: modes.map<Widget>((mode) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
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
                        Icon(
                          mode['type'] == 'فردي' ? Icons.person_outline : Icons.group_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubdued,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mode['type'] ?? '',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(mode['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(mode['desc'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(mode['price'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSizes.space16),
        // Accredited Hall Card
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
              const Row(
                children: [
                  Icon(Icons.business_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('قاعة التدريس المعتمدة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                location,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 12),
              Row(
                children: amenities.map<Widget>((a) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        a.toString(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(TutorProfileController controller) {
    final reviews = controller.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('تقييمات وآراء الطلاب', style: AppTextStyles.heading2),
            TextButton(
              onPressed: () {},
              child: const Text('عرض الكل (142)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        ...reviews.map((rev) {
          final name = rev['name'] ?? '';
          final tag = rev['tag'] ?? '';
          final comment = rev['comment'] ?? '';
          final timeAgo = rev['timeAgo'] ?? '';
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(timeAgo, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                        const SizedBox(height: 2),
                        Row(
                          children: List.generate(
                            rating.toInt(),
                            (_) => const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                          ),
                        ),
                      ],
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

  Widget _buildBottomActionBar(TutorProfileController controller, Map<String, dynamic> t) {
    final hourlyRate = t['hourlyRate'] ?? 40;

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
                const Text(
                  'يبدأ سعر الساعة من',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$hourlyRate ₪',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const Text(
                      ' / ساعة',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.bookSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('احجز جلستك الآن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
