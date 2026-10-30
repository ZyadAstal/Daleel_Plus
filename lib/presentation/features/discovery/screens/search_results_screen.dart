import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../academic/screens/academy_details_screen.dart';
import '../state/search_controller.dart';
import 'compare_screen.dart';
import 'filter_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  void _openSort(DiscoverySearchController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ترتيب النتائج',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ...DiscoverySearchController.sortLabels.entries.map(
                  (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                trailing: controller.sortBy.value == entry.key
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  controller.changeSort(entry.key);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ActiveFilter> _activeFilters(DiscoverySearchController controller) {
    final list = <_ActiveFilter>[];
    if (controller.category.value != 'all') {
      list.add(_ActiveFilter(
        '${DiscoverySearchController.categories[controller.category.value]}',
            () => controller.changeCategory('all'),
      ));
    }
    final min = controller.minPrice.value;
    final max = controller.maxPrice.value;
    if (min > 0 || max < DiscoverySearchController.maxPriceLimit) {
      final text = min == 0 ? 'أقل من ${max.toInt()} ₪' : '${min.toInt()} - ${max.toInt()} ₪';
      list.add(_ActiveFilter(text, () => controller.changePriceRange(
        const RangeValues(0, DiscoverySearchController.maxPriceLimit),
      )));
    }
    for (final mode in controller.modes) {
      list.add(_ActiveFilter(DiscoverySearchController.modeLabels[mode]!, () => controller.toggleMode(mode)));
    }
    for (final area in controller.areas) {
      list.add(_ActiveFilter('📍 $area', () => controller.toggleArea(area)));
    }
    if (controller.minRating.value > 0) {
      list.add(_ActiveFilter('⭐ ${controller.minRating.value} فما فوق', () => controller.changeMinRating(0)));
    }
    if (controller.onlyCertified.value) {
      list.add(_ActiveFilter('شهادة معتمدة', () => controller.onlyCertified.value = false));
    }
    if (controller.onlyStudentDiscount.value) {
      list.add(_ActiveFilter('خصم طلابي', () => controller.onlyStudentDiscount.value = false));
    }
    if (controller.onlyLimitedSeats.value) {
      list.add(_ActiveFilter('مقاعد محدودة', () => controller.onlyLimitedSeats.value = false));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final controller = DiscoverySearchController.instance;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: ''),
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

        final results = controller.results;
        final filters = _activeFilters(controller);
        final query = controller.query.value.trim();

        if (results.isEmpty) {
          return EmptyStateScreen(
            searchTerm: query.isEmpty ? null : query,
            onClearSearch: controller.clearQuery,
            onResetFilters: () {
              controller.resetFilters();
              controller.clearQuery();
            },
          );
        }

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.space24, AppSizes.space16, AppSizes.space24, 120),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.search, size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('نتائج البحث عن:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          Text(
                            query.isEmpty ? '« جميع الخدمات »' : '« $query »',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${results.length} نتيجة',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => const FilterScreen(fromResults: true)),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            const Text(
                              'تصفية',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            if (controller.activeFiltersCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openSort(controller),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                          decoration: _cardDecoration(radius: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.sort, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                              Expanded(
                                child: Text(
                                  DiscoverySearchController.sortLabels[controller.sortBy.value]!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (filters.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filters.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 6),
                            itemBuilder: (_, index) => _FilterChip(filter: filters[index]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: controller.resetFilters,
                        child: const Text(
                          'مسح',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSizes.space16),
                ...results.map(
                      (item) => _ResultCard(
                    item: item,
                    isCompared: controller.compareIds.contains(item['id']),
                    onCompare: () => controller.toggleCompare(item['id']),
                  ),
                ),
              ],
            ),
            if (controller.compareIds.isNotEmpty)
              PositionedDirectional(
                start: AppSizes.space24,
                end: AppSizes.space24,
                bottom: AppSizes.space16,
                child: _CompareBar(
                  count: controller.compareIds.length,
                  onCompare: () => Get.to(() => CompareScreen(items: controller.compareItems)),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }
}

class _ActiveFilter {
  final String text;
  final VoidCallback onRemove;

  _ActiveFilter(this.text, this.onRemove);
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

class _FilterChip extends StatelessWidget {
  final _ActiveFilter filter;

  const _FilterChip({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(filter.text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: filter.onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isCompared;
  final VoidCallback onCompare;

  const _ResultCard({required this.item, required this.isCompared, required this.onCompare});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;
    final color = DiscoverySearchController.typeColor(type);
    final num price = item['price'];
    final num oldPrice = item['oldPrice'];
    final num rating = item['rating'];
    final area = (item['area'] ?? '').toString();
    final imageUrl = (item['imageUrl'] ?? '').toString();
    final note = (item['note'] ?? '').toString();
    final isPrinting = type == 'printing';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(radius: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => DiscoverySearchController.openItem(item),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          color: AppColors.surfaceSubdued,
                          child: imageUrl.isEmpty
                              ? Icon(Icons.image_outlined, color: color)
                              : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, color: color),
                          ),
                        ),
                        PositionedDirectional(
                          top: 6,
                          start: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              item['badge'] ?? '',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: type == 'course' && (item['providerId'] ?? '').toString().isNotEmpty
                                    ? () => AcademyDetailsScreen.open(item['providerId'])
                                    : null,
                                child: Text(
                                  type == 'tutor' ? (item['subtitle'] ?? '') : (item['providerName'] ?? ''),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                                ),
                              ),
                            ),
                            if (rating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '★ ${DiscoverySearchController.ratingText(rating)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        if (area.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  area,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.surfaceSubdued.withValues(alpha: 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${DiscoverySearchController.money(price)} ₪',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          const SizedBox(width: 4),
                          if (oldPrice > 0)
                            Text(
                              DiscoverySearchController.money(oldPrice),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            )
                          else
                            Text(
                              '/ ${item['priceUnit']}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                      if (note.isNotEmpty)
                        Text(
                          note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onCompare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompared ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'قارن',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.space8),
                GestureDetector(
                  onTap: () => DiscoverySearchController.openItem(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isPrinting ? AppColors.secondary : AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DiscoverySearchController.actionText(type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isPrinting ? AppColors.textPrimary : AppColors.white,
                      ),
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

class _CompareBar extends StatelessWidget {
  final int count;
  final VoidCallback onCompare;

  const _CompareBar({required this.count, required this.onCompare});

  @override
  Widget build(BuildContext context) {
    final isReady = count == 2;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.balance, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReady ? 'اخترت خدمتين للمقارنة ⚖️' : 'اختر خدمة أخرى للمقارنة',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.white),
                ),
                Text(
                  'مقارنة الأسعار والمميزات وجها لوجه',
                  style: TextStyle(fontSize: 10, color: AppColors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isReady ? onCompare : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isReady ? AppColors.secondary : AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    'قارن الآن',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.textPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}