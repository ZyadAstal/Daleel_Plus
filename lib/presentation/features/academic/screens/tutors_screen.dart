import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../discovery/screens/filter_screen.dart';
import '../../discovery/state/search_controller.dart';
import '../state/tutors_controller.dart';
import 'tutor_profile_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class TutorsScreen extends StatelessWidget {
  const TutorsScreen({super.key});

  void _openFilter() {
    DiscoverySearchController.instance.changeCategory('tutor');
    Get.to(() => const FilterScreen());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TutorsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'المدرسون الخصوصيون'),
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

        final tutors = controller.tutors;
        final departments = ['', ...controller.departments];

        if (tutors.isEmpty && (controller.searchText.value.trim().isNotEmpty || controller.department.value.isNotEmpty)) {
          return EmptyStateScreen(
            searchTerm: controller.searchText.value.trim().isEmpty ? null : controller.searchText.value.trim(),
            onClearSearch: () => controller.changeSearch(''),
            onResetFilters: () {
              controller.changeSearch('');
              controller.changeDepartment('');
            },
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: TextField(
                        onChanged: controller.changeSearch,
                        decoration: const InputDecoration(
                          hintText: 'ابحث باسم المدرس، المساق، التخصص...',
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
                    GestureDetector(
                      onTap: _openFilter,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.tune, size: 18, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                children: departments.map((item) {
                  final isSelected = controller.department.value == item;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSizes.space8),
                    child: GestureDetector(
                      onTap: () => controller.changeDepartment(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.isEmpty ? 'جميع المدرسين (${controller.tutorsCount})' : item,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.space16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.white,
                      child: Icon(Icons.verified_user_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مدرسون جامعيون معتمدون',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            'ضمان جودة الشرح ومراجعة شاملة للامتحانات النصفية والنهائية',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        '100% معتمد',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            if (tutors.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.space24),
                child: Center(
                  child: Text('لا يوجد مدرسون مطابقون', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ...tutors.map(
                  (tutor) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: _TutorCard(
                  tutor: tutor,
                  isSaved: controller.favoriteIds.contains(tutor['id']),
                  onSave: () => controller.toggleFavorite(tutor['id']),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final Map<String, dynamic> tutor;
  final bool isSaved;
  final VoidCallback onSave;

  const _TutorCard({required this.tutor, required this.isSaved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final image = (tutor['logoUrl'] ?? '').toString();
    final num rating = tutor['averageRating'] ?? 0;
    final num reviews = tutor['reviewsCount'] ?? tutor['ratingsCount'] ?? 0;
    final num rate = tutor['hourlyRate'] ?? 0;
    final bool isAvailable = tutor['isAvailable'] ?? false;
    final badge = (tutor['badgeLabel'] ?? ((tutor['isVerified'] ?? false) ? 'موثق معتمد' : '')).toString();
    final subjects = TutorsController.subjectsOf(tutor);
    final mode = (tutor['teachingModeLabel'] ?? '').toString();
    final note = (tutor['universitiesNote'] ?? '').toString();
    final freeTrial = tutor['freeTrial'] == true;

    return GestureDetector(
      onTap: () => TutorProfileScreen.open(tutor['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (freeTrial)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🎁 أول جلسة تجريبية (20 دقيقة) مجانا',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipOval(
                            child: Container(
                              width: 60,
                              height: 60,
                              color: AppColors.surfaceSubdued,
                              child: image.isEmpty
                                  ? const Icon(Icons.person_outline, color: AppColors.primary)
                                  : Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person_outline, color: AppColors.primary),
                              ),
                            ),
                          ),
                          if (isAvailable)
                            PositionedDirectional(
                              bottom: 0,
                              end: 0,
                              child: Container(
                                width: 16,
                                height: 16,
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
                            Text(
                              tutor['businessName'] ?? '',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (badge.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      badge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.verified_outlined, size: 12, color: AppColors.success),
                                  ],
                                ),
                              ),
                            Text(
                              tutor['headline'] ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            if (note.isNotEmpty)
                              Text(note, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onSave,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.surfaceSubdued,
                              child: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (rating > 0)
                            Text(
                              '★$rating',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          if (reviews > 0)
                            Text(
                              '($reviews تقييم)',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...subjects.take(3).map(
                            (subject) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subject,
                            style: const TextStyle(fontSize: 11, color: AppColors.primary),
                          ),
                        ),
                      ),
                      if (mode.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            mode,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.surfaceSubdued.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    '${TutorsController.money(rate)} ₪',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const Text(' / ساعة', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'عرض الملف والحجز',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: AppColors.white),
                      ],
                    ),
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