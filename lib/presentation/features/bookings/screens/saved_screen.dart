import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../academic/screens/academy_details_screen.dart';
import '../../academic/screens/course_details_screen.dart';
import '../../academic/screens/job_details_screen.dart';
import '../../academic/screens/tutor_profile_screen.dart';
import '../../printing/screens/print_order_screen.dart';
import '../state/saved_controller.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  void _confirmClear(SavedController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('إفراغ المحفوظات', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('هل تريد حذف كل العناصر المحفوظة؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearAll();
            },
            child: const Text('إفراغ الكل', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedController());

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

        final items = controller.items;

        if (items.isEmpty && (controller.searchText.value.trim().isNotEmpty || controller.type.value.isNotEmpty)) {
          return EmptyStateScreen(
            searchTerm: controller.searchText.value.trim().isEmpty ? null : controller.searchText.value.trim(),
            onClearSearch: () => controller.changeSearch(''),
            onResetFilters: () {
              controller.changeSearch('');
              controller.changeType('');
            },
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: _cardDecoration(radius: 24),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              onChanged: controller.changeSearch,
                              decoration: const InputDecoration(
                                hintText: 'ابحث في محفوظاتك...',
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
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: controller.toggleSort,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: _cardDecoration(radius: 24),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_vert, size: 18, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            controller.newestFirst.value ? 'الأحدث حفظا' : 'الأقدم حفظا',
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                children: SavedController.typeNames.entries.map((entry) {
                  final isSelected = controller.type.value == entry.key;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSizes.space8),
                    child: GestureDetector(
                      onTap: () => controller.changeType(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: isSelected ? AppColors.white.withValues(alpha: 0.25) : AppColors.surfaceSubdued,
                              child: Text(
                                '${controller.countFor(entry.key)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
              child: Row(
                children: [
                  const Icon(Icons.bookmarks_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'المحفوظات المعروضة (${items.length})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  if (controller.countFor('') > 0)
                    GestureDetector(
                      onTap: () => _confirmClear(controller),
                      child: const Row(
                        children: [
                          Icon(Icons.delete_sweep_outlined, size: 16, color: AppColors.error),
                          SizedBox(width: 2),
                          Text(
                            'إفراغ الكل',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.space24),
                child: Center(
                  child: Text('لا توجد عناصر محفوظة هنا', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ...items.map(
                  (favorite) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: _SavedCard(controller: controller, favorite: favorite),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 3),
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

class _SavedCard extends StatelessWidget {
  final SavedController controller;
  final Map<String, dynamic> favorite;

  const _SavedCard({required this.controller, required this.favorite});

  static String _money(num value) => value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(2);

  static int _daysLeft(dynamic value) {
    try {
      final days = (value.toDate() as DateTime).difference(DateTime.now()).inDays;
      return days < 0 ? 0 : days;
    } catch (_) {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = (favorite['targetType'] ?? '').toString();
    final data = controller.dataOf(favorite);
    final id = (favorite['targetId'] ?? '').toString();

    IconData icon = Icons.school_outlined;
    Color color = AppColors.primary;
    String badge = 'دورات وتدريب';
    String title = (data['title'] ?? data['businessName'] ?? '').toString();
    String line1 = '';
    String line2 = '';
    String price = '';
    String extra = '';
    String action = 'عرض التفاصيل';
    VoidCallback onAction = () {};

    switch (type) {
      case 'course':
        final num original = data['originalPrice'] ?? 0;
        final num? discounted = data['discountedPrice'];
        icon = Icons.code;
        line1 = controller.providerName((data['providerId'] ?? '').toString());
        line2 = '★ ${data['averageRating'] ?? '-'}';
        price = '${_money(discounted ?? original)} ₪';
        if (discounted != null && original > 0) extra = 'خصم ${((original - discounted) / original * 100).round()}%';
        action = 'حجز المقعد';
        onAction = () => CourseDetailsScreen.open(id);
        break;
      case 'job':
        final num reward = data['monthlyReward'] ?? 0;
        final days = _daysLeft(data['deadline']);
        icon = Icons.design_services_outlined;
        color = AppColors.success;
        badge = 'فرص وتدريب';
        line1 = (data['companyName'] ?? '').toString();
        line2 = (data['workTypeLabel'] ?? '').toString();
        price = reward > 0 ? '${_money(reward)} ₪ / شهر' : 'تطوعية';
        if (days >= 0) extra = 'متبقي $days أيام';
        action = 'تقديم الآن';
        onAction = () => JobDetailsScreen.open(id);
        break;
      case 'printshop':
        final Map service = data['service'] ?? {};
        icon = Icons.print_outlined;
        color = AppColors.secondary;
        badge = 'خدمات طباعة ومكتبات';
        line1 = [data['city'], data['addressDetails']].where((t) => t != null).join(' - ');
        line2 = service['bindingPrice'] != null ? 'تجليد حراري متاح' : '';
        price = '${service['bwPagePrice'] ?? '-'} ₪ / صفحة';
        action = 'طلب طباعة';
        onAction = () => PrintOrderScreen.open(data);
        break;
      case 'tutor':
        final subjects = (data['subjects'] ?? []) as List;
        icon = Icons.person_pin_outlined;
        badge = 'مدرسون خصوصيون';
        line1 = subjects.isEmpty ? '' : (subjects.first['name'] ?? '').toString();
        line2 = (data['headline'] ?? '').toString();
        price = '${_money(data['hourlyRate'] ?? 0)} ₪ / ساعة';
        extra = '★ ${data['averageRating'] ?? '-'}';
        action = 'حجز جلسة';
        onAction = () => TutorProfileScreen.open(id);
        break;
      default:
        icon = Icons.apartment_outlined;
        badge = 'أكاديميات ومراكز';
        line1 = (data['city'] ?? '').toString();
        line2 = '★ ${data['averageRating'] ?? '-'}';
        action = 'عرض المركز';
        onAction = () => AcademyDetailsScreen.open(id);
    }

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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color == AppColors.secondary ? AppColors.textPrimary : color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '● $badge',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color == AppColors.secondary ? AppColors.textPrimary : color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.remove(favorite),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  child: const Icon(Icons.bookmark_remove_outlined, size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceSubdued, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(line1, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    if (line2.isNotEmpty)
                      Text(
                        line2,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                  ],
                ),
                if (price.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      if (extra.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            extra,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  SavedController.savedAgo(favorite['savedAt']),
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: color == AppColors.success ? AppColors.success : color,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    action,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color == AppColors.secondary ? AppColors.textPrimary : AppColors.white,
                    ),
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