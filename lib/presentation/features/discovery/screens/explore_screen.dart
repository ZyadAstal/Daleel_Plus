import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../printing/screens/print_centers_screen.dart';
import '../../printing/screens/print_order_screen.dart';
import '../../academic/screens/course_details_screen.dart';
import '../../academic/screens/job_details_screen.dart';
import '../../academic/screens/jobs_screen.dart';
import '../../academic/screens/tutor_profile_screen.dart';
import '../../academic/screens/tutors_screen.dart';
import '../state/explore_controller.dart';
import 'filter_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class ExploreScreen extends StatelessWidget {
  final ExploreSection initialSection;

  const ExploreScreen({super.key, this.initialSection = ExploreSection.all});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreController(initialSection: initialSection));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(),
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

        final courses = controller.visibleCourses;
        final jobs = controller.visibleJobs;
        final centers = controller.visiblePrintCenters;
        final tutors = controller.visibleTutors;

        if (controller.hasNoResults && controller.searchText.value.trim().isNotEmpty) {
          return EmptyStateScreen(
            searchTerm: controller.searchText.value.trim(),
            onClearSearch: () => controller.changeSearch(''),
            onResetFilters: () {
              controller.changeSearch('');
              controller.changeSection(ExploreSection.all);
            },
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          children: [
            _padded(const _Header()),
            const SizedBox(height: AppSizes.space16),
            _padded(_SearchBar(onChanged: controller.changeSearch)),
            const SizedBox(height: AppSizes.space16),
            _ChipsRow(
              items: ExploreController.sectionNames.values.toList(),
              selected: ExploreController.sectionNames[controller.section.value]!,
              color: AppColors.primary,
              filled: true,
              onTap: (name) => controller.changeSection(
                ExploreController.sectionNames.keys.firstWhere((key) => ExploreController.sectionNames[key] == name),
              ),
            ),
            if (controller.hasNoResults) ...[
              const SizedBox(height: AppSizes.space24),
              const _EmptyText(text: 'لا توجد نتائج مطابقة لبحثك'),
            ],
            if (controller.shows(ExploreSection.courses) && courses.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space24),
              _padded(
                _SectionHeader(
                  icon: Icons.school_outlined,
                  title: 'دورات وتطوير مهني',
                  color: AppColors.primary,
                  trailing: controller.section.value == ExploreSection.courses
                      ? null
                      : _LinkText(
                    text: 'عرض الكل',
                    onTap: () => controller.changeSection(ExploreSection.courses),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              _ChipsRow(
                items: controller.courseCategories,
                selected: controller.courseCategory.value,
                color: AppColors.primary,
                onTap: controller.changeCourseCategory,
              ),
              const SizedBox(height: AppSizes.space16),
              ...courses.asMap().entries.map(
                    (entry) => _padded(_CourseCard(course: entry.value, isTop: entry.key == 0)),
              ),
            ],
            if (controller.shows(ExploreSection.jobs) && jobs.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space8),
              _padded(
                _SectionHeader(
                  icon: Icons.work_outline,
                  title: 'وظائف وتدريب عملي',
                  color: AppColors.success,
                  trailing: _LinkText(text: 'عرض ${controller.jobsCount} فرصة', onTap: () => Get.to(() => const JobsScreen())),
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              _ChipsRow(
                items: controller.jobTypes,
                selected: controller.jobType.value,
                color: AppColors.success,
                onTap: controller.changeJobType,
              ),
              const SizedBox(height: AppSizes.space16),
              ...jobs.asMap().entries.map(
                    (entry) => _padded(_JobCard(job: entry.value, index: entry.key)),
              ),
            ],
            if (controller.shows(ExploreSection.printing) && centers.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space8),
              _padded(
                _SectionHeader(
                  icon: Icons.print_outlined,
                  title: 'أماكن طباعة وتصوير معتمدة',
                  color: AppColors.secondary,
                  trailing: controller.lowestPagePrice > 0
                      ? _Badge(
                    text: 'يبدأ من ${ExploreController.money(controller.lowestPagePrice)} ₪ / صفحة',
                    color: AppColors.secondary,
                  )
                      : null,
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              ...centers.map((center) => _padded(_PrintCenterCard(center: center))),
            ],
            if (controller.shows(ExploreSection.tutors) && tutors.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space8),
              _padded(
                _SectionHeader(
                  icon: Icons.person_search_outlined,
                  title: 'مدرسون خصوصيون معتمدون',
                  color: AppColors.primary,
                  trailing: _LinkText(text: 'تصفح المعلمين', onTap: () => Get.to(() => const TutorsScreen())),
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              _ChipsRow(
                items: controller.tutorSubjects,
                selected: controller.tutorSubject.value,
                color: AppColors.primary,
                filled: true,
                onTap: controller.changeTutorSubject,
              ),
              const SizedBox(height: AppSizes.space16),
              ...tutors.map((tutor) => _padded(_TutorCard(tutor: tutor))),
            ],
            const SizedBox(height: AppSizes.bottomNavGap),
          ],
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }

  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
    child: child,
  );
}

BoxDecoration _cardDecoration({double radius = AppSizes.cardRadius}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'استكشف الأقسام الأكاديمية',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              SizedBox(height: 4),
              Text(
                'دليلك المتكامل لجميع الخدمات والفرص الجامعية',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.explore_outlined, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppSizes.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            decoration: _cardDecoration(radius: AppSizes.fieldRadius),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن دورة، مساق، وظيفة، أو مركز طباعة...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Get.to(() => const FilterScreen()),
          child: Container(
            width: AppSizes.fieldHeight,
            height: AppSizes.fieldHeight,
            decoration: _cardDecoration(radius: AppSizes.fieldRadius),
            child: const Icon(Icons.tune, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final List<String> items;
  final String selected;
  final Color color;
  final bool filled;
  final ValueChanged<String> onTap;

  const _ChipsRow({
    required this.items,
    required this.selected,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.space8),
        itemBuilder: (_, index) {
          final item = items[index];
          final isSelected = item == selected;

          Color background = AppColors.surfaceSubdued;
          Color textColor = AppColors.textSecondary;
          if (isSelected) {
            background = filled ? color : color.withValues(alpha: 0.12);
            textColor = filled ? AppColors.white : color;
          }

          return GestureDetector(
            onTap: () => onTap(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected && !filled) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  const _SectionHeader({required this.icon, required this.title, required this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LinkText({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ImageChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _ImageChip({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.white),
            const SizedBox(width: 4),
          ],
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white)),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;

  const _NetworkImage({required this.url, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.surfaceSubdued,
      child: const Icon(Icons.image_outlined, color: AppColors.textHint),
    );

    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isTop;

  const _CourseCard({required this.course, required this.isTop});

  @override
  Widget build(BuildContext context) {
    final num original = course['originalPrice'] ?? 0;
    final num? discounted = course['discountedPrice'];
    final price = discounted ?? original;
    final discount = discounted == null || original == 0 ? 0 : ((original - discounted) / original * 100).round();
    final rating = ExploreController.rating(course);
    final num hours = course['totalHours'] ?? 0;
    final num students = course['bookedSeats'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _NetworkImage(url: course['coverImageUrl'] ?? '', width: double.infinity, height: 170),
                PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: Row(
                    children: [
                      if (isTop && rating > 0) ...[
                        const _ImageChip(text: 'الأعلى تقييما', color: AppColors.primary),
                        const SizedBox(width: 6),
                      ],
                      if (discount > 0) _ImageChip(text: 'خصم $discount%', color: AppColors.error),
                    ],
                  ),
                ),
                if (hours > 0)
                  PositionedDirectional(
                    bottom: 10,
                    end: 10,
                    child: _ImageChip(
                      text: '${ExploreController.money(hours)} ساعة معتمدة',
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                      icon: Icons.timer_outlined,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  course['providerName'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              if (rating > 0) ...[
                const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                Text(
                  ' ${ExploreController.ratingText(rating)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                if (students > 0)
                  Text(
                    ' ($students طالب)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            course['title'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            course['description'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.space16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discount > 0 ? 'الرسوم بعد الخصم' : 'الرسوم',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Row(
                      children: [
                        Text(
                          '${ExploreController.money(price)} ₪',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${ExploreController.money(original)} ₪',
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
              GestureDetector(
                onTap: () => CourseDetailsScreen.open(course['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'سجل الآن',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18, color: AppColors.white),
                    ],
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

class _InfoText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final int index;

  const _JobCard({required this.job, required this.index});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.primary;
    final days = ExploreController.daysLeft(job['deadline']);
    final location = (job['location'] ?? '').toString();
    final duration = (job['durationLabel'] ?? '').toString();
    final num distance = job['distanceKm'] ?? 0;

    return GestureDetector(
      onTap: () => JobDetailsScreen.open(job['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space16),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.work_outline, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job['companyName'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                        ),
                      ),
                      _Badge(text: 'متاح للتقديم', color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      if (location.isNotEmpty) _InfoText(icon: Icons.location_on_outlined, text: location),
                      if (distance > 0)
                        _InfoText(icon: Icons.near_me_outlined, text: 'تبعد ${ExploreController.money(distance)} كم'),
                      if (duration.isNotEmpty) _InfoText(icon: Icons.schedule, text: duration),
                      if (days > 0) _InfoText(icon: Icons.hourglass_bottom, text: 'متبقي $days يوم'),
                    ],
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

class _PrintCenterCard extends StatelessWidget {
  final Map<String, dynamic> center;

  const _PrintCenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    final Map service = center['service'];
    final num prepMinutes = service['prepMinutes'] ?? 0;
    final num discount = service['studentDiscountPercent'] ?? 0;
    final address = [center['addressDetails'], center['city']]
        .where((text) => (text ?? '').toString().isNotEmpty)
        .join(' • ');

    return GestureDetector(
      onTap: () => Get.to(() => const PrintCentersScreen()),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space16),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: _cardDecoration(radius: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center['businessName'] ?? '',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      if (address.isNotEmpty) _InfoText(icon: Icons.location_on_outlined, text: address),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            Row(
              children: [
                const Expanded(
                  child: _PrintServiceTile(
                    icon: Icons.menu_book_outlined,
                    title: 'طباعة وتجليد أبحاث',
                    subtitle: 'حراري / كرتون مقوى',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PrintServiceTile(
                    icon: Icons.copy_outlined,
                    title: 'تصوير ملازم دراسية',
                    subtitle: discount > 0 ? 'خصم $discount% للكميات' : 'أسعار طلابية',
                    subtitleColor: discount > 0 ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: _PrintServiceTile(
                    icon: Icons.image_outlined,
                    title: 'بوسترات تخرج',
                    subtitle: 'ورق كوشيه فاخر',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _PrintServiceTile(
                    icon: Icons.verified_outlined,
                    title: 'أختام وتصاريح',
                    subtitle: 'معتمدة رسميا',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            Row(
              children: [
                if (prepMinutes > 0)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'استلام فوري خلال $prepMinutes دقيقة',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                GestureDetector(
                  onTap: () => PrintOrderScreen.open(center),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file_outlined, size: 18, color: AppColors.white),
                        SizedBox(width: 6),
                        Text(
                          'إرسال ملف للطباعة',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;

  const _PrintServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Text(subtitle, style: TextStyle(fontSize: 10, color: subtitleColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final Map<String, dynamic> tutor;

  const _TutorCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    final rating = ExploreController.rating(tutor);
    final num rate = tutor['hourlyRate'] ?? 0;
    final bool isAvailable = tutor['isAvailable'] ?? true;
    final bool isVerified = tutor['isVerified'] ?? false;
    final subjects = ExploreController.subjectsOf(tutor).take(2).toList();
    final mode = (tutor['teachingModeLabel'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(radius: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipOval(child: _NetworkImage(url: tutor['logoUrl'] ?? '', width: 56, height: 56)),
                    if (isAvailable)
                      PositionedDirectional(
                        bottom: 0,
                        end: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
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
                              tutor['businessName'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_outlined, size: 16, color: AppColors.primary),
                          ],
                          const Spacer(),
                          if (rating > 0) ...[
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                            Text(
                              ExploreController.ratingText(rating),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        tutor['headline'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSizes.space8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ...subjects.asMap().entries.map(
                                (entry) => _Badge(
                              text: entry.value,
                              color: entry.key == 0 ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          if (mode.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.success),
                                const SizedBox(width: 2),
                                Text(
                                  mode,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.surfaceSubdued.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('سعر الجلسة', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        '${ExploreController.money(rate)} ₪ / ساعة',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => TutorProfileScreen.open(tutor['id']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.white),
                        SizedBox(width: 6),
                        Text(
                          'احجز جلسة',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                      ],
                    ),
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