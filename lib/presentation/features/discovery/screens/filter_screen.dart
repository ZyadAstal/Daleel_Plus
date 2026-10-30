import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/search_controller.dart';
import 'search_results_screen.dart';

class FilterScreen extends StatelessWidget {
  final bool fromResults;

  const FilterScreen({super.key, this.fromResults = false});

  static const Map<String, String> _categoryEmojis = {
    'all': '',
    'course': '🎓 ',
    'printing': '🖨️ ',
    'job': '💼 ',
    'tutor': '🧑‍🏫 ',
  };

  static const Map<String, IconData> _modeIcons = {
    'onsite': Icons.apartment_outlined,
    'online': Icons.laptop_outlined,
    'hybrid': Icons.swap_horiz,
    'delivery': Icons.local_shipping_outlined,
  };

  void _apply() {
    if (fromResults) {
      Get.back();
    } else {
      Get.off(() => const SearchResultsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = DiscoverySearchController.instance;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: ''),
      body: Obx(() {
        final min = controller.minPrice.value;
        final max = controller.maxPrice.value;
        final maxText = max >= DiscoverySearchController.maxPriceLimit ? '+${max.toInt()}' : '${max.toInt()}';

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSizes.space24),
          children: [
            _Header(onReset: controller.resetFilters),
            _Section(
              dotColor: AppColors.primary,
              title: 'القسم الرئيسي',
              hint: 'اختر مجالك الأكاديمي',
              child: Wrap(
                spacing: AppSizes.space8,
                runSpacing: AppSizes.space8,
                children: DiscoverySearchController.categories.entries.map((entry) {
                  final isSelected = controller.category.value == entry.key;
                  return _Chip(
                    text: '${_categoryEmojis[entry.key]}${entry.value}',
                    isSelected: isSelected,
                    filled: true,
                    onTap: () => controller.changeCategory(entry.key),
                  );
                }).toList(),
              ),
            ),
            _Section(
              dotColor: AppColors.secondary,
              title: 'نطاق السعر (بالشيكل ILS)',
              trailing: Text(
                '${min.toInt()} - $maxText ₪',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.secondary),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _PriceBox(label: 'الحد الأدنى', value: '${min.toInt()}')),
                      const SizedBox(width: 12),
                      Expanded(child: _PriceBox(label: 'الحد الأقصى', value: maxText)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space8),
                  RangeSlider(
                    values: RangeValues(min, max),
                    min: 0,
                    max: DiscoverySearchController.maxPriceLimit,
                    divisions: 80,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceSubdued,
                    onChanged: controller.changePriceRange,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.space16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0 ₪', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('400 ₪', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('800 ₪', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              dotColor: AppColors.success,
              title: 'طريقة الحضور وتقديم الخدمة',
              hint: 'اختيار متعدد',
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3,
                children: DiscoverySearchController.modeLabels.entries.map((entry) {
                  final isSelected = controller.modes.contains(entry.key);
                  return GestureDetector(
                    onTap: () => controller.toggleMode(entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(_modeIcons[entry.key], size: 20, color: AppColors.primary),
                          const SizedBox(width: AppSizes.space8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSelected ? AppColors.primary : AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            _Section(
              dotColor: AppColors.primary,
              title: 'الموقع الجغرافي',
              hint: 'المناطق المتاحة',
              child: Wrap(
                spacing: AppSizes.space8,
                runSpacing: AppSizes.space8,
                children: DiscoverySearchController.areaOptions.map((area) {
                  return _Chip(
                    text: '${area.contains('جامعة') ? '🏛️' : area.startsWith('غزة') ? '📍' : '🌴'} $area',
                    isSelected: controller.areas.contains(area),
                    onTap: () => controller.toggleArea(area),
                  );
                }).toList(),
              ),
            ),
            _Section(
              dotColor: AppColors.secondary,
              title: 'التقييم الأدنى للمزود',
              hint: 'حسب آراء الطلاب',
              child: Row(
                children: [4.5, 4.0, 3.5].map((value) {
                  final isSelected = controller.minRating.value == value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeMinRating(value),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
                                Text(
                                  ' ${value.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'فما فوق',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
            _Section(
              dotColor: AppColors.success,
              title: 'ميزات إضافية وتفضيلات',
              child: Column(
                children: [
                  _SwitchRow(
                    icon: Icons.verified_outlined,
                    color: AppColors.success,
                    title: 'شهادة معتمدة',
                    subtitle: 'خدمات تمنح إفادة أو رخصة رسمية',
                    value: controller.onlyCertified.value,
                    onChanged: (value) => controller.onlyCertified.value = value,
                  ),
                  _SwitchRow(
                    icon: Icons.percent,
                    color: AppColors.secondary,
                    title: 'خصم طلابي حصري',
                    subtitle: 'عروض خاصة لحاملي بطاقة دليل+',
                    value: controller.onlyStudentDiscount.value,
                    onChanged: (value) => controller.onlyStudentDiscount.value = value,
                  ),
                  _SwitchRow(
                    icon: Icons.event_seat_outlined,
                    color: AppColors.error,
                    title: 'مقاعد متبقية محدودة',
                    subtitle: 'إظهار الفرص الأسرع اكتمالا',
                    value: controller.onlyLimitedSeats.value,
                    onChanged: (value) => controller.onlyLimitedSeats.value = value,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.space24, AppSizes.space16, AppSizes.space24, AppSizes.space24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
          ],
        ),
        child: Obx(() {
          final count = controller.results.length;
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: _apply,
                  child: Container(
                    height: AppSizes.buttonHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(28)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 18, color: AppColors.white),
                        const SizedBox(width: 6),
                        Text(
                          'تطبيق الفلترة (إظهار $count نتيجة)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: controller.resetFilters,
                  child: Container(
                    height: AppSizes.buttonHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Text(
                      'مسح الكل',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onReset;

  const _Header({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(AppSizes.space24, AppSizes.space8, AppSizes.space24, AppSizes.space16),
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تصفية وتخصيص النتائج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  'قم بتضييق خيارات البحث للوصول لأفضل نتائج',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    'إعادة ضبط',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.refresh, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String? hint;
  final Widget? trailing;
  final Widget child;

  const _Section({
    required this.dotColor,
    required this.title,
    required this.child,
    this.hint,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.space24, 0, AppSizes.space24, AppSizes.space16),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              if (hint != null) Text(hint!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool filled;
  final VoidCallback onTap;

  const _Chip({required this.text, required this.isSelected, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    Color background = AppColors.surfaceSubdued;
    Color textColor = AppColors.textPrimary;
    if (isSelected) {
      background = filled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.12);
      textColor = filled ? AppColors.white : AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String value;

  const _PriceBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.surfaceSubdued, borderRadius: BorderRadius.circular(14)),
          child: Text(
            '₪ $value',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: color),
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
          Switch(
            value: value,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}