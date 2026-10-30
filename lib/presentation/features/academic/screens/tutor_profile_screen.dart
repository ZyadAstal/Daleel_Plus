import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/tutor_profile_controller.dart';
import '../../bookings/screens/checkout_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/not_found_screen.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  static void open(String tutorId) {
    Get.delete<TutorProfileController>(force: true);
    Get.put(TutorProfileController(tutorId));
    Get.to(() => const TutorProfileScreen());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TutorProfileController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: StudentTopBar(
        title: 'الملف الأكاديمي للمدرس',
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
          IconButton(
            // TODO: مشاركة ملف المدرس عند إضافة باكج share_plus
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
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

        if (controller.tutor.isEmpty) {
          return const NotFoundScreen();
        }

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space16),
          children: [
            _HeaderCard(controller: controller),
            const SizedBox(height: AppSizes.space16),
            _AboutCard(controller: controller),
            const SizedBox(height: AppSizes.space16),
            _SubjectsCard(subjects: controller.subjects),
            const SizedBox(height: AppSizes.space16),
            _TeachingCard(controller: controller),
            const SizedBox(height: AppSizes.space16),
            _ReviewsCard(
              reviews: controller.reviews.toList(),
              total: controller.number('reviewsCount').toInt(),
            ),
            const SizedBox(height: AppSizes.space16),
          ],
        );
      }),
      bottomNavigationBar: Obx(
            () => _BottomBar(price: controller.number('hourlyRate')),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.icon, required this.color, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Chip({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final TutorProfileController controller;

  const _HeaderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final imageUrl = controller.text('logoUrl');
    final bool isAvailable = controller.tutor['isAvailable'] ?? false;
    final bool isVerified = controller.tutor['isVerified'] ?? false;
    final rating = controller.number('averageRating');
    final reviewsCount = controller.number('reviewsCount');

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.surfaceSubdued,
                backgroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: AppColors.textHint)
                    : null,
              ),
              if (isVerified)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 14, color: AppColors.white),
                  ),
                ),
              if (isAvailable)
                const PositionedDirectional(
                  top: -6,
                  start: -24,
                  child: _AvailableChip(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const _Chip(
            text: 'المدرسون الخصوصيون المعتمدون',
            color: AppColors.primary,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            controller.text('businessName'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            controller.text('headline'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          if (rating > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '(${reviewsCount.toInt()} تقييم موثق ${controller.text('reviewsNote')})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _StatsBox(controller: controller),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.phone_outlined,
                  text: 'اتصال مباشر',
                  color: AppColors.primary,
                  onTap: controller.callTutor,
                ),
              ),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: _ContactButton(
                  icon: Icons.chat_outlined,
                  text: 'واتساب فوري',
                  color: AppColors.success,
                  isFilled: true,
                  onTap: controller.openWhatsapp,
                ),
              ),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: _ContactButton(
                  icon: Icons.location_on_outlined,
                  text: 'موقع القاعة',
                  color: AppColors.secondary,
                  onTap: controller.openLocation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailableChip extends StatelessWidget {
  const _AvailableChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          const Text('متاح اليوم', style: TextStyle(fontSize: 10, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _StatsBox extends StatelessWidget {
  final TutorProfileController controller;

  const _StatsBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    final price = TutorProfileController.money(controller.number('hourlyRate'));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppSizes.space8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _stat('الخبرة', '${controller.number('experienceYears').toInt()} سنوات', 'تدريس جامعي', AppColors.textPrimary),
          _stat('الجلسات', '+${controller.number('sessionsCount').toInt()}', 'جلسة مكتملة', AppColors.primary),
          _stat('نسبة الرضا', '${controller.number('satisfactionRate').toInt()}%', 'توصية طلابية', AppColors.success),
          _stat('سعر الساعة', '$price₪', 'جلسة فردية', AppColors.secondary),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, String note, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(note, style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isFilled;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: isFilled ? color.withValues(alpha: 0.25) : AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final TutorProfileController controller;

  const _AboutCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final highlights = controller.textList('highlights');
    const colors = [AppColors.primary, AppColors.success, AppColors.secondary];

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.psychology_outlined,
            color: AppColors.primary,
            title: 'نبذة أكاديمية وفلسفة التدريس',
          ),
          const SizedBox(height: 12),
          Text(
            controller.text('bio'),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.7),
          ),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(highlights.length, (index) {
                  final color = colors[index % colors.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(highlights[index], style: TextStyle(fontSize: 12, color: color)),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubjectsCard extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;

  const _SubjectsCard({required this.subjects});

  @override
  Widget build(BuildContext context) {
    const icons = [Icons.functions, Icons.account_tree_outlined, Icons.grid_on, Icons.query_stats];

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _SectionTitle(
            icon: Icons.menu_book_outlined,
            color: AppColors.secondary,
            title: 'المساقات والمواد المتاحة للتدريس',
            trailing: Text(
              '${subjects.length} مساقات رئيسية',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(subjects.length, (index) {
            final subject = subjects[index];
            final tag = (subject['tag'] ?? '').toString();
            final isTop = index == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icons[index % icons.length], size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (subject['name'] ?? '').toString(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          (subject['nameEn'] ?? '').toString(),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (tag.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 100),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTop ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isTop ? AppColors.white : AppColors.textSecondary,
                        ),
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
}

class _TeachingCard extends StatelessWidget {
  final TutorProfileController controller;

  const _TeachingCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hall = controller.hall;
    final features = ((hall['features'] ?? []) as List).map((item) => item.toString()).toList();
    const featureIcons = [Icons.ac_unit, Icons.wifi, Icons.solar_power_outlined];
    final groupRate = controller.number('groupRate');

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.co_present_outlined,
            color: AppColors.success,
            title: 'طريقة التدريس والمواعيد',
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MethodCard(
                    icon: Icons.person_outline,
                    tag: 'فردي',
                    tagColor: AppColors.primary,
                    title: 'جلسة فردية 1on1',
                    description: 'تركيز كامل وحل مخصص لاحتياجاتك',
                    price: '${TutorProfileController.money(controller.number('hourlyRate'))}₪',
                    unit: '/ ساعة',
                    priceColor: AppColors.primary,
                  ),
                ),
                if (groupRate > 0) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MethodCard(
                      icon: Icons.groups_outlined,
                      tag: 'توفيري',
                      tagColor: AppColors.secondary,
                      title: 'مجموعات طلابية',
                      description: 'مجموعات صغيرة (3 - 5 طلاب كحد أقصى)',
                      price: '${TutorProfileController.money(groupRate)}₪',
                      unit: '/ للطالب',
                      priceColor: AppColors.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if ((hall['address'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.apartment, size: 18, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'قاعة التدريس المعتمدة',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hall['address'].toString(),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  ),
                  if (features.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: AppSizes.space8,
                      runSpacing: AppSizes.space8,
                      children: List.generate(features.length, (index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(featureIcons[index % featureIcons.length], size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(features[index], style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String tag;
  final Color tagColor;
  final String title;
  final String description;
  final String price;
  final String unit;
  final Color priceColor;

  const _MethodCard({
    required this.icon,
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: tagColor),
              const Spacer(),
              Text(tag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tagColor)),
            ],
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const Spacer(),
          const SizedBox(height: AppSizes.space8),
          Row(
            children: [
              Text(price, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: priceColor)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(fontSize: 11, color: priceColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final int total;

  const _ReviewsCard({required this.reviews, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _SectionTitle(
            icon: Icons.reviews_outlined,
            color: AppColors.secondary,
            title: 'تقييمات وآراء الطلاب',
            trailing: GestureDetector(
              // TODO: الانتقال لشاشة كل التقييمات عند تجهيزها
              onTap: () {},
              child: Text(
                'عرض الكل ($total)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSizes.space16),
              child: Text('لا توجد تقييمات بعد', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ...reviews.take(3).map((review) => _ReviewItem(review: review)),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (review['studentImageUrl'] ?? '').toString();
    final int rating = ((review['rating'] ?? 0) as num).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.white,
                backgroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 18, color: AppColors.textHint)
                    : null,
              ),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (review['studentName'] ?? '').toString(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          TutorProfileController.timeAgo(review['createdAt']),
                          style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                        ),
                      ],
                    ),
                    Text(
                      (review['studentInfo'] ?? '').toString(),
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: index < rating ? AppColors.secondary : AppColors.border,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            '"${review['comment'] ?? ''}"',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final num price;

  const _BottomBar({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.space16, 12, AppSizes.space16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('يبدأ سعر الحصة من', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Row(
                  children: [
                    Text(
                      '${TutorProfileController.money(price)}₪',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const Text(' / ساعة', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(width: AppSizes.space16),
            Expanded(
              child: SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => CheckoutScreen.openSession(Get.find<TutorProfileController>().tutorId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: const Text('احجز جلستك الآن', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}