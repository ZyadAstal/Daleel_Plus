import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/course_details_controller.dart';
import '../../bookings/screens/checkout_screen.dart';
import 'academy_details_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/not_found_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  static void open(String courseId) {
    Get.to(() => CourseDetailsScreen(courseId: courseId), preventDuplicates: false);
  }

  static const Map<String, IconData> _facilityIcons = {
    'ac': Icons.ac_unit,
    'wifi': Icons.wifi,
    'certificate': Icons.workspace_premium_outlined,
    'power': Icons.bolt,
    'lab': Icons.computer_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CourseDetailsController(courseId), tag: courseId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.topBarHeight),
        child: Obx(() => StudentTopBar(title: controller.text('title'), actions: const [])),
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

        if (controller.course.isEmpty) {
          return const NotFoundScreen();
        }

        final modules = controller.listOf('syllabus');
        final facilities = controller.listOf('facilities');

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            _Hero(controller: controller),
            const SizedBox(height: AppSizes.space16),
            if (controller.provider['businessName'] != null) _ProviderCard(controller: controller),
            const SizedBox(height: AppSizes.space16),
            _InfoCard(controller: controller),
            if (modules.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space24),
              _SectionTitle(
                title: 'محاور المنهج التعليمي',
                subtitle: '${modules.length} وحدات عملية تؤهلك لسوق العمل',
                badge: 'محدثة لعام ${DateTime.now().year}',
              ),
              const SizedBox(height: 12),
              ...modules.asMap().entries.map(
                    (entry) => _ModuleCard(
                  index: entry.key,
                  module: entry.value,
                  isExpanded: controller.expandedModule.value == entry.key,
                  onTap: () => controller.toggleModule(entry.key),
                ),
              ),
            ],
            if (controller.text('instructorName').isNotEmpty) ...[
              const SizedBox(height: AppSizes.space24),
              const _SectionTitle(title: 'المدرب المشرف على الدورة'),
              const SizedBox(height: 12),
              _InstructorCard(controller: controller),
            ],
            if (facilities.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space24),
              const _SectionTitle(title: 'المرافق والامتيازات المشمولة'),
              const SizedBox(height: 12),
              ...facilities.map(
                    (facility) => _FacilityTile(
                  icon: _facilityIcons[facility['icon']] ?? Icons.check_circle_outline,
                  title: (facility['title'] ?? '').toString(),
                  subtitle: (facility['subtitle'] ?? '').toString(),
                ),
              ),
            ],
            if (controller.reviews.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space24),
              const _SectionTitle(title: 'آراء وتقييمات الطلاب'),
              const SizedBox(height: 12),
              ...controller.reviews.take(5).map((review) => _ReviewCard(review: review)),
            ],
          ],
        );
      }),
      bottomNavigationBar: _BookingBar(
        controller: controller,
        onBook: () => CheckoutScreen.openCourse(courseId),
      ),
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

class _Hero extends StatelessWidget {
  final CourseDetailsController controller;

  const _Hero({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cover = controller.text('coverImageUrl');
      final num rating = controller.course['averageRating'] ?? 0;
      final num students = controller.course['bookedSeats'] ?? 0;
      final category = controller.text('categorySubtag');

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.isEmpty ? '🎓 دورات وتعليم' : '🎓 دورات وتعليم • $category',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.toggleFavorite,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: _cardDecoration(radius: 12),
                  child: Icon(
                    controller.isFavorite.value ? Icons.bookmark : Icons.bookmark_border,
                    color: controller.isFavorite.value ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.surfaceSubdued,
                  child: cover.isEmpty
                      ? const Icon(Icons.image_outlined, color: AppColors.textHint)
                      : Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textHint),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.textPrimary.withValues(alpha: 0.85)],
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: AppSizes.space16,
                  end: AppSizes.space16,
                  bottom: AppSizes.space16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        children: [
                          if (controller.discountPercent > 0)
                            _Pill(
                              text: 'خصم ${controller.discountPercent}% لطلاب دليل+',
                              background: AppColors.secondary,
                              color: AppColors.textPrimary,
                            ),
                          if (rating > 0)
                            _Pill(
                              text: '★ $rating ($students طالب)',
                              background: AppColors.white.withValues(alpha: 0.9),
                              color: AppColors.textPrimary,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space8),
                      Text(
                        controller.text('title'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color color;

  const _Pill({required this.text, required this.background, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final CourseDetailsController controller;

  const _ProviderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final provider = controller.provider;
    final logo = (provider['logoUrl'] ?? '').toString();
    final location = [provider['city'], provider['addressDetails']]
        .where((text) => (text ?? '').toString().isNotEmpty)
        .join('، ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: logo.isEmpty
                ? const Icon(Icons.school_outlined, color: AppColors.primary)
                : Image.network(
              logo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.school_outlined, color: AppColors.primary),
            ),
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
                        provider['businessName'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    if (provider['isVerified'] == true) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 16, color: AppColors.primary),
                    ],
                  ],
                ),
                if (location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => AcademyDetailsScreen.open(provider['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Text(
                    'المركز',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CourseDetailsController controller;

  const _InfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final num hours = controller.course['totalHours'] ?? 0;
    final mode = CourseDetailsController.attendanceModes[controller.course['attendanceMode']] ?? '';
    final attendanceNote = controller.text('attendanceNote');
    final tags = controller.tags;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.asMap().entries.map((entry) {
                final color = entry.key == 0 ? AppColors.primary : AppColors.secondary;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
          Text(
            controller.text('subtitle').isEmpty ? controller.text('title') : controller.text('subtitle'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          if (hours > 0) _InfoRow(icon: Icons.schedule, text: '$hours ساعة تدريبية معتمدة ومكثفة'),
          if (controller.startDateText.isNotEmpty)
            _InfoRow(icon: Icons.calendar_month_outlined, text: 'يبدأ: ${controller.startDateText}'),
          if (mode.isNotEmpty)
            _InfoRow(
              icon: Icons.devices_outlined,
              text: attendanceNote.isEmpty ? mode : '$mode + $attendanceNote',
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الرسوم الأكاديمية للطلاب',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Row(
                        children: [
                          Text(
                            '${CourseDetailsController.money(controller.price)} ₪',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          if (controller.savedAmount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${CourseDetailsController.money(controller.originalPrice)} ₪',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (controller.discountPercent > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'وفر ${controller.discountPercent}% ببطاقة دليل+',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'خصم فوري حصري عبر التطبيق',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badge;

  const _SectionTitle({required this.title, this.subtitle, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surfaceSubdued, borderRadius: BorderRadius.circular(20)),
            child: Text(
              badge!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> module;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.index,
    required this.module,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final details = (module['details'] ?? '').toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: _cardDecoration(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module['title'] ?? '',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        module['subtitle'] ?? '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            if (isExpanded && details.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(details, style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  final CourseDetailsController controller;

  const _InstructorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final avatar = controller.text('instructorAvatar');
    final bio = controller.text('instructorBio');
    final num rating = controller.course['instructorRating'] ?? 0;
    final experience = controller.text('instructorExperience');

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceSubdued,
                backgroundImage: avatar.isEmpty ? null : NetworkImage(avatar),
                child: avatar.isEmpty ? const Icon(Icons.person_outline, color: AppColors.primary) : null,
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
                            controller.text('instructorName'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (controller.course['instructorVerified'] == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'معتمد دوليا',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      controller.text('instructorTitle'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (rating > 0 || experience.isNotEmpty)
                      Text(
                        [if (rating > 0) '★ $rating', if (experience.isNotEmpty) experience].join(' • '),
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(bio, style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary)),
            ),
          ],
        ],
      ),
    );
  }
}

class _FacilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FacilityTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(radius: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                radius: 18,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                child: Text(
                  name.isEmpty ? '' : name.substring(0, 1),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    if (!isAnonymous)
                      Text(
                        '${review['studentInfo'] ?? ''} - مسجل معتمد',
                        style: const TextStyle(fontSize: 10, color: AppColors.success),
                      ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 15,
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

class _BookingBar extends StatelessWidget {
  final CourseDetailsController controller;
  final VoidCallback onBook;

  const _BookingBar({required this.controller, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.orderStatusText;
      final seatsLeft = controller.seatsLeft;
      final isFull = seatsLeft == 0;
      final canBook = status.isEmpty && !isFull;
      final includes = controller.text('priceIncludes');

      String buttonText = 'احجز مقعدك الآن';
      if (status.isNotEmpty) buttonText = status;
      if (status.isEmpty && isFull) buttonText = 'المقاعد ممتلئة';

      return Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.space24, 12, AppSizes.space24, AppSizes.space24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.savedAmount > 0)
                  Text(
                    '● وفرت ${CourseDetailsController.money(controller.savedAmount)} ₪',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                  ),
                Row(
                  children: [
                    Text(
                      '${CourseDetailsController.money(controller.price)} ₪',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    if (controller.savedAmount > 0)
                      Text(
                        ' ${CourseDetailsController.money(controller.originalPrice)} ₪',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                if (includes.isNotEmpty)
                  Text(includes, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: AppSizes.space16),
            Expanded(
              child: GestureDetector(
                onTap: canBook ? onBook : null,
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: canBook ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          if (canBook) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 18, color: AppColors.white),
                          ],
                        ],
                      ),
                      if (canBook && seatsLeft > 0 && seatsLeft <= 10)
                        Text(
                          'متبقي $seatsLeft مقاعد فقط في هذه الشعبة',
                          style: TextStyle(fontSize: 10, color: AppColors.white.withValues(alpha: 0.85)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}