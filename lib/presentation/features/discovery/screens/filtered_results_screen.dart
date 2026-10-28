import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../state/filtered_results_controller.dart';
import '../../../shared/constants/app_colors.dart';
import 'filter_screen.dart';

class FilteredResultsScreen extends StatelessWidget {
  FilteredResultsScreen({Key? key}) : super(key: key);

  final FilteredResultsController controller = Get.put(
    FilteredResultsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubdued,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderBar(),
            _buildActiveFiltersBar(),
            _buildSortAndFilterBar(),
            Expanded(
              child: Stack(
                children: [_buildResultsList(), _buildFloatingCompareBar()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الهيدر وعدد النتائج الحقيقي
  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Get.back(),
              ),
              Row(
                children: const [
                  Icon(Icons.notifications_none, color: AppColors.textPrimary),
                  SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    controller.activeCategory.value.isNotEmpty
                        ? '« ${controller.activeCategory.value} »'
                        : '« جميع النتائج »',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${controller.resultsList.length} نتيجة',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'نتائج البحث المصفاة:',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  // عرض الفلاتر المختارة فعلياً من قِبل المستخدم دون أي فلاتر افتراضية
  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          final List<Widget> chips = [];

          // 1. فلتر الفئة
          if (controller.activeCategory.value.isNotEmpty) {
            chips.add(
              _buildFilterChip(
                controller.activeCategory.value,
                Icons.school,
                AppColors.primary,
                () => controller.removeCategoryFilter(),
              ),
            );
          }

          // 2. فلاتر السعر (إن تم تخصيصه)
          if (controller.activeMinPrice.value > 0 ||
              controller.activeMaxPrice.value < 1000) {
            chips.add(
              _buildFilterChip(
                'السعر: ${controller.activeMinPrice.value.toInt()} - ${controller.activeMaxPrice.value.toInt()} ₪',
                Icons.local_offer,
                Colors.indigo,
                () => controller.removePriceFilter(),
              ),
            );
          }

          // 3. فلاتر المواقع المحددة
          for (var loc in controller.activeLocations) {
            chips.add(
              _buildFilterChip(
                loc,
                Icons.location_on,
                Colors.red,
                () => controller.removeLocationFilter(loc),
              ),
            );
          }

          for (var mode in controller.activeAttendanceModes) {
            chips.add(
              _buildFilterChip(
                mode,
                Icons.devices,
                Colors.teal,
                () => controller.removeAttendanceFilter(mode),
              ),
            );
          }

          if (controller.activeMinRating.value > 0) {
            chips.add(
              _buildFilterChip(
                'تقييم ${controller.activeMinRating.value}+ ⭐',
                Icons.star,
                Colors.amber.shade800,
                () => controller.removeRatingFilter(),
              ),
            );
          }

          if (chips.isEmpty) {
            return const SizedBox.shrink();
          }

          return Row(
            children: [
              GestureDetector(
                onTap: () => controller.clearAllFilters(),
                child: const Text(
                  'مسح الكل',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...chips,
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onRemove,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildSortAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.sort, size: 18, color: AppColors.textPrimary),
                  Text(
                    'الأعلى تقييماً ⭐',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.to(() => FilterScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'تصفية',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Obx(() {
      if (controller.resultsList.isEmpty) {
        return const Center(
          child: Text(
            'لا توجد نتائج مطابقة للفلاتر المختارة حالياً',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Cairo',
              color: AppColors.textHint,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        itemCount: controller.resultsList.length,
        itemBuilder: (context, index) {
          final item = controller.resultsList[index];
          final String title = item['title'] ?? item['name'] ?? 'بدون عنوان';
          final String provider =
              item['provider'] ??
              item['instructor'] ??
              item['center_name'] ??
              'مُزود خدمة';
          final String location = item['location'] ?? 'غير محدد';
          final String price = item['price'] != null
              ? '${item['price']} ₪'
              : 'مجاني';
          final String rating = item['rating'] != null
              ? '${item['rating']}'
              : '4.5';
          final String itemId = item['id'] ?? '$index';

          return _buildDynamicServiceCard(
            badgeText: item['collection'] ?? 'خدمة',
            title: title,
            provider: provider,
            rating: rating,
            locationOrDetail: location,
            priceText: price,
            itemId: itemId,
          );
        },
      );
    });
  }

  Widget _buildDynamicServiceCard({
    required String badgeText,
    required String title,
    required String provider,
    required String rating,
    required String locationOrDetail,
    required String priceText,
    required String itemId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            provider,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 4),
              Text(
                locationOrDetail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                priceText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
              Row(
                children: [
                  Obx(() {
                    final isCompared = controller.comparedItems.contains(
                      itemId,
                    );
                    return InkWell(
                      onTap: () => controller.toggleCompareItem(itemId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCompared
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCompared
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: Checkbox(
                                value: isCompared,
                                activeColor: AppColors.primary,
                                onChanged: (_) =>
                                    controller.toggleCompareItem(itemId),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'قارن',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'التفاصيل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCompareBar() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Obx(() {
        if (controller.comparedItems.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'قارن الآن ←',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'اخترت ${controller.comparedItems.length} خدمتين للمقارنة ⚖️',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const Text(
                        'مقارنة الأسعار والمميزات وجها لوجه',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.balance, color: Colors.amber),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
