import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../academic/screens/course_details_screen.dart';
import '../../academic/screens/job_details_screen.dart';
import '../../academic/screens/jobs_screen.dart';
import '../../academic/screens/tutor_profile_screen.dart';
import '../../academic/screens/tutors_screen.dart';
import '../../printing/screens/print_centers_screen.dart';
import '../state/explore_controller.dart';
import '../state/student_home_controller.dart';
import 'explore_screen.dart';
import 'filter_screen.dart';
import 'search_screen.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../app_status/screens/system_error_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentHomeController());

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

        final offer = controller.offer.value;
        final favorites = controller.favoriteIds.toSet();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          children: [
            _padded(_Greeting(name: controller.firstName, university: controller.universityText)),
            const SizedBox(height: AppSizes.space16),
            _padded(const _SearchBar()),
            if (offer != null) ...[
              const SizedBox(height: AppSizes.space24),
              _padded(
                _SectionHeader(
                  title: 'عروض وتخفيضات حصرية',
                  color: AppColors.secondary,
                  trailing: _Badge(
                    text: 'تصل إلى ${offer['discountPercent'] ?? 0}%',
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              _padded(_OfferCard(offer: offer, onActivate: controller.copyOfferCode)),
            ],
            const SizedBox(height: AppSizes.space24),
            _padded(const _SectionHeader(title: 'الخدمات الأكاديمية الرئيسية', color: AppColors.primary)),
            const SizedBox(height: AppSizes.space16),
            _padded(
              _ServicesGrid(
                coursesCount: controller.coursesCount,
                jobsCount: controller.jobsCount,
                printCentersCount: controller.printCentersCount,
                tutorsCount: controller.tutorsCount,
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            _padded(const _QuickPrintBanner()),
            const SizedBox(height: AppSizes.space24),
            _padded(
              _SectionHeader(
                title: 'دورات تدريبية مميزة',
                color: AppColors.primary,
                trailing: _LinkText(
                  text: 'الكل (${controller.coursesCount})',
                  onTap: () => Get.to(() => const ExploreScreen(initialSection: ExploreSection.courses)),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _FeaturedCourses(
              courses: controller.featuredCourses,
              favoriteIds: favorites,
              onFavorite: (id) => controller.toggleFavorite(id, 'course'),
            ),
            const SizedBox(height: AppSizes.space24),
            _padded(
              _SectionHeader(
                title: 'أحدث فرص التدريب والوظائف',
                color: AppColors.success,
                trailing: _LinkText(text: 'عرض الكل', color: AppColors.primary, onTap: () => Get.to(() => const JobsScreen())),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            ...controller.latestJobs.asMap().entries.map(
                  (entry) => _padded(_JobCard(job: entry.value, index: entry.key)),
            ),
            const SizedBox(height: AppSizes.space8),
            _padded(
              _SectionHeader(
                title: 'أفضل المدرسين',
                color: AppColors.secondary,
                trailing: _LinkText(text: 'عرض الكل', color: AppColors.primary, onTap: () => Get.to(() => const TutorsScreen())),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _TopTutors(tutors: controller.topTutors),
            const SizedBox(height: AppSizes.bottomNavGap),
          ],
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
    );
  }

  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
    child: child,
  );
}

class _Greeting extends StatelessWidget {
  final String name;
  final String university;

  const _Greeting({required this.name, required this.university});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً $name 👋',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        if (university.isNotEmpty) ...[
          const SizedBox(height: AppSizes.space8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(university, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const SearchScreen()),
            child: Container(
              height: AppSizes.fieldHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                  SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      'ابحث عن دورة، مدرس، مطبعة، أو فرصة...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: AppColors.textHint),
                    ),
                  ),
                  Icon(Icons.mic_none, color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Get.to(() => const FilterScreen()),
          child: Container(
            width: AppSizes.fieldHeight,
            height: AppSizes.fieldHeight,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
            ),
            child: const Icon(Icons.tune, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final Widget? trailing;

  const _SectionHeader({required this.title, required this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: AppSizes.space8),
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _LinkText({required this.text, required this.onTap, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final VoidCallback onActivate;

  const _OfferCard({required this.offer, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    final days = StudentHomeController.daysLeft(offer['endsAt']);
    final code = (offer['code'] ?? '').toString();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          stops: [0.45, 1],
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -10,
            bottom: -20,
            child: Icon(Icons.percent, size: 110, color: AppColors.white.withValues(alpha: 0.12)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer_outlined, size: 13, color: AppColors.white),
                          const SizedBox(width: 4),
                          Text(
                            offer['tag'] ?? '',
                            style: const TextStyle(fontSize: 11, color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (days > 0)
                      Text(
                        'ينتهي خلال $days أيام',
                        style: TextStyle(fontSize: 11, color: AppColors.white.withValues(alpha: 0.85)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  offer['title'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  offer['description'] ?? '',
                  style: TextStyle(fontSize: 12, color: AppColors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: AppSizes.space16),
                Row(
                  children: [
                    Text(
                      'كود الخصم',
                      style: TextStyle(fontSize: 11, color: AppColors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onActivate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'تفعيل العرض',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
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

class _ServicesGrid extends StatelessWidget {
  final int coursesCount;
  final int jobsCount;
  final int printCentersCount;
  final int tutorsCount;

  const _ServicesGrid({
    required this.coursesCount,
    required this.jobsCount,
    required this.printCentersCount,
    required this.tutorsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ServiceCard(
                icon: Icons.school_outlined,
                title: 'دورات وتعليم',
                subtitle: '+$coursesCount دورة معتمدة',
                badge: 'معتمد',
                action: 'استكشاف الدورات',
                color: AppColors.primary,
                onTap: () => Get.to(() => const ExploreScreen(initialSection: ExploreSection.courses)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                icon: Icons.work_outline,
                title: 'وظائف وتدريب',
                subtitle: '$jobsCount فرصة شاغرة',
                badge: 'حديث',
                action: 'تصفح الفرص',
                color: AppColors.success,
                onTap: () => Get.to(() => const JobsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ServiceCard(
                icon: Icons.print_outlined,
                title: 'مراكز الطباعة',
                subtitle: '$printCentersCount مركز طباعة',
                badge: 'استلام فوري',
                action: 'ارسل ملفك',
                color: AppColors.secondary,
                onTap: () => Get.to(() => const PrintCentersScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                icon: Icons.people_outline,
                title: 'مدرسون خصوصيون',
                subtitle: '+$tutorsCount مدرس معتمد',
                badge: 'مباشر / عن بعد',
                action: 'احجز جلسة',
                color: AppColors.primary,
                onTap: () => Get.to(() => const TutorsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final String action;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.action,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppColors.white, size: 22),
                ),
                const Spacer(),
                Flexible(child: _Badge(text: badge, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(action, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPrintBanner extends StatelessWidget {
  const _QuickPrintBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -16,
            bottom: -16,
            child: Icon(Icons.print, size: 110, color: AppColors.white.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 13, color: AppColors.white),
                      SizedBox(width: 4),
                      Text('خدمة الطباعة السريعة', style: TextStyle(fontSize: 11, color: AppColors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'اطبع أبحاثك ومشاريعك بضغطة زر',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'ارفع ملف PDF واستلمه مغلفاً وموثقاً من أقرب مكتبة لحرم الجامعة',
                  style: TextStyle(fontSize: 12, color: AppColors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: AppSizes.space16),
                GestureDetector(
                  onTap: () => Get.to(() => const PrintCentersScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'رفع ملف للطباعة',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
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

class _FeaturedCourses extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Set<String> favoriteIds;
  final void Function(String id) onFavorite;

  const _FeaturedCourses({required this.courses, required this.favoriteIds, required this.onFavorite});

  @override
  Widget build(BuildContext context) {

    if (courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.space24),
        child: Text('لا توجد دورات متاحة حاليًا', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return SizedBox(
      height: 306,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24, vertical: AppSizes.space8),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final course = courses[index];
          return _CourseCard(
            course: course,
            isFavorite: favoriteIds.contains(course['id']),
            onFavorite: () => onFavorite(course['id']),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const _CourseCard({
    required this.course,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final num original = course['originalPrice'] ?? 0;
    final num? discounted = course['discountedPrice'];
    final price = discounted ?? original;
    final discount = discounted == null || original == 0 ? 0 : ((original - discounted) / original * 100).round();
    final rating = StudentHomeController.rating(course);

    return GestureDetector(
      onTap: () => CourseDetailsScreen.open(course['id']),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  _NetworkImage(url: course['coverImageUrl'] ?? '', width: double.infinity, height: 130),
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: _ImageChip(
                      text: (course['categorySubtag'] ?? course['category'] ?? '').toString(),
                      color: AppColors.primary,
                    ),
                  ),
                  if (discount > 0)
                    PositionedDirectional(
                      bottom: 8,
                      start: 8,
                      child: _ImageChip(text: 'خصم $discount%', color: AppColors.error),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    course['providerName'] ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                if (rating > 0) ...[
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                  Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              course['title'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '${StudentHomeController.money(price)} شيكل',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                if (discount > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    StudentHomeController.money(original),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_add_outlined,
                      size: 18,
                      color: AppColors.white,
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

class _ImageChip extends StatelessWidget {
  final String text;
  final Color color;

  const _ImageChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white)),
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
    final days = StudentHomeController.daysLeft(job['deadline']);
    final num reward = job['monthlyReward'] ?? 0;
    final workType = (job['workTypeLabel'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_outline, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  job['companyName'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (reward > 0)
                  Text(
                    'مكافأة ${StudentHomeController.money(reward)} شيكل',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success),
                  ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (workType.isNotEmpty) _Badge(text: workType, color: color),
                    if (days > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 2),
                          Text('متبقي $days أيام', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          GestureDetector(
            onTap: () => JobDetailsScreen.open(job['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: const Text(
                'تقديم',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTutors extends StatelessWidget {
  final List<Map<String, dynamic>> tutors;

  const _TopTutors({required this.tutors});

  @override
  Widget build(BuildContext context) {
    if (tutors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.space24),
        child: Text('لا يوجد مدرسون حاليًا', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24, vertical: AppSizes.space8),
        itemCount: tutors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => _TutorCard(tutor: tutors[index]),
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final Map<String, dynamic> tutor;

  const _TutorCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    final rating = StudentHomeController.rating(tutor);
    final num rate = tutor['hourlyRate'] ?? 0;
    final bool isAvailable = tutor['isAvailable'] ?? true;

    return GestureDetector(
      onTap: () => TutorProfileScreen.open(tutor['id']),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipOval(child: _NetworkImage(url: tutor['logoUrl'] ?? '', width: 60, height: 60)),
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
            const SizedBox(height: AppSizes.space8),
            Text(
              tutor['businessName'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              tutor['headline'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            if (rating > 0)
              Text(
                '★ ${rating.toStringAsFixed(1)} (${tutor['sessionsCount'] ?? 0} جلسة)',
                style: const TextStyle(fontSize: 11, color: AppColors.secondary),
              ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${StudentHomeController.money(rate)} شيكل/ساعة',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}