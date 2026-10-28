import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../state/filter_controller.dart';
import '../../../shared/constants/app_colors.dart';

class FilterScreen extends StatelessWidget {
  FilterScreen({Key? key}) : super(key: key);

  final FilterController controller = Get.put(FilterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubdued,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'تصفية وتخصيص النتائج',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => controller.resetFilters(),
            icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
            label: const Text(
              'إعادة ضبط',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('القسم الرئيسي', 'اختر مجالَك الأكاديمي'),
            const SizedBox(height: 10),
            _buildCategoriesChips(),
            const SizedBox(height: 20),

            _buildSectionHeader(
              'نطاق السعر (بالشيكل ILS)',
              'حدد الحد الأدنى والأقصى',
            ),
            const SizedBox(height: 10),
            _buildPriceRangeSlider(),
            const SizedBox(height: 20),

            // قسم طريقة الحضور وتقديم الخدمة (بعد نطاق السعر مباشرة)
            _buildSectionHeader('طريقة الحضور وتقديم الخدمة', 'اختيار متعدد'),
            const SizedBox(height: 10),
            _buildAttendanceModesGrid(),
            const SizedBox(height: 20),

            _buildSectionHeader(
              'الموقع الجغرافي',
              'المناطق المتاحة من قاعدة البيانات',
            ),
            const SizedBox(height: 10),
            _buildLocationsChipsFromFirebase(),
            const SizedBox(height: 20),

            _buildSectionHeader('التقييم الأدنى للمزود', 'حسب آراء الطلاب'),
            const SizedBox(height: 10),
            _buildRatingFilter(),
            const SizedBox(height: 20),

            _buildSectionHeader('ميزات إضافية وتفضيلات', ''),
            const SizedBox(height: 10),
            _buildAdditionalToggles(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionButtons(),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
              fontFamily: 'Cairo',
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesChips() {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.categories.map((cat) {
          final isSelected = controller.selectedCategory.value == cat;
          return ChoiceChip(
            label: Text(
              cat,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white,
            onSelected: (_) => controller.changeCategory(cat),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPriceRangeSlider() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الحد الأدنى: ${controller.minPrice.value.toInt()} ₪',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'الحد الأقصى: ${controller.maxPrice.value.toInt()} ₪',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: RangeValues(
                controller.minPrice.value,
                controller.maxPrice.value,
              ),
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                '${controller.minPrice.value.toInt()} ₪',
                '${controller.maxPrice.value.toInt()} ₪',
              ),
              onChanged: (values) {
                controller.minPrice.value = values.start;
                controller.maxPrice.value = values.end;
                controller.applyDynamicFiltering();
              },
            ),
          ],
        ),
      );
    });
  }

  // قسم طريقة الحضور وتقديم الخدمة مع مراعاة تفاعل GetX لكل عنصر بشكل مستقل
  Widget _buildAttendanceModesGrid() {
    final List<Map<String, dynamic>> modes = [
      {'title': 'وجاهي بالمقر', 'icon': Icons.business},
      {'title': 'أونلاين عن بُعد', 'icon': Icons.laptop_mac},
      {'title': 'مختلط Hybrid', 'icon': Icons.swap_horiz},
      {'title': 'توصيل للموقع المراد', 'icon': Icons.local_shipping_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: modes.length,
      itemBuilder: (context, index) {
        final mode = modes[index];
        final String title = mode['title'];

        return Obx(() {
          final bool isSelected = controller.selectedAttendanceModes.contains(
            title,
          );

          return GestureDetector(
            onTap: () => controller.toggleAttendanceMode(title),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    mode['icon'],
                    size: 20,
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // جلب المواقع الجغرافية ديناميكياً من Firebase
  Widget _buildLocationsChipsFromFirebase() {
    return Obx(() {
      if (controller.isLoadingLocations.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.availableLocations.isEmpty) {
        return const Text(
          'لا توجد مواقع مسجلة في النظام حالياً',
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.availableLocations.map((loc) {
          final isSelected = controller.selectedLocations.contains(loc);
          return FilterChip(
            label: Text(
              loc,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white,
            onSelected: (_) => controller.toggleLocation(loc),
          );
        }).toList(),
      );
    });
  }

  // التقييم الأدنى للمزود (3 خيارات دقيقة مطابقة للصورة)
  Widget _buildRatingFilter() {
    final ratings = [3.5, 4.0, 4.5];
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ratings.map((rate) {
          final isSelected = controller.minRating.value == rate;
          return GestureDetector(
            onTap: () {
              controller.minRating.value = rate;
              controller.applyDynamicFiltering();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              child: Text(
                '$rate ⭐\nفما فوق',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildAdditionalToggles() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'شهادة معتمدة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              value: controller.hasCertifiedCertificate.value,
              activeColor: AppColors.primary,
              onChanged: (val) {
                controller.hasCertifiedCertificate.value = val;
                controller.applyDynamicFiltering();
              },
            ),
            SwitchListTile(
              title: const Text(
                'خصم طلابي حصري',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              value: controller.hasStudentDiscount.value,
              activeColor: AppColors.primary,
              onChanged: (val) {
                controller.hasStudentDiscount.value = val;
                controller.applyDynamicFiltering();
              },
            ),
            SwitchListTile(
              title: const Text(
                'مقاعد متبقية محدودة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              value: controller.hasLimitedSeats.value,
              activeColor: AppColors.primary,
              onChanged: (val) {
                controller.hasLimitedSeats.value = val;
                controller.applyDynamicFiltering();
              },
            ),
          ],
        ),
      );
    });
  }

  // زر تطبيق الفلترة السفلي الذي يعرض عدد النتائج الفعلي المتطابق
  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => controller.resetFilters(),
              child: const Text(
                'مسح الكل',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(() {
              int count = controller.filteredResults.length;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.applyFiltersAndNavigate(),
                child: Text(
                  'تطبيق الفلترة (إظهار $count نتيجة)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    fontSize: 13,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
