import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/search_controller.dart';
import 'search_results_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const Map<String, IconData> _categoryIcons = {
    'all': Icons.auto_awesome,
    'course': Icons.school_outlined,
    'tutor': Icons.people_outline,
    'printing': Icons.print_outlined,
    'job': Icons.work_outline,
  };

  static const Map<String, IconData> _typeIcons = {
    'course': Icons.school_outlined,
    'tutor': Icons.person_outline,
    'printing': Icons.print_outlined,
    'job': Icons.work_outline,
  };

  void _openResults(DiscoverySearchController controller) {
    controller.saveSearch();
    Get.to(() => const SearchResultsScreen());
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

        final hasQuery = controller.query.value.trim().isNotEmpty;
        final suggestions = controller.suggestions;

        if (hasQuery && suggestions.isEmpty) {
          return EmptyStateScreen(
            searchTerm: controller.query.value.trim(),
            onClearSearch: controller.clearQuery,
            onResetFilters: () {
              controller.resetFilters();
              controller.clearQuery();
            },
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          children: [
            _padded(
              _SearchField(
                controller: controller,
                onSubmit: () => _openResults(controller),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                children: DiscoverySearchController.categories.entries.map((entry) {
                  final isSelected = controller.category.value == entry.key;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSizes.space8),
                    child: GestureDetector(
                      onTap: () => controller.changeCategory(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _categoryIcons[entry.key],
                              size: 16,
                              color: isSelected ? AppColors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.white : AppColors.textSecondary,
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
            if (controller.recentSearches.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space24),
              _padded(
                Row(
                  children: [
                    const Icon(Icons.history, size: 20, color: AppColors.textPrimary),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'عمليات البحث الأخيرة',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.clearRecent,
                      child: const Text(
                        'مسح السجل',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _padded(
                Wrap(
                  spacing: AppSizes.space8,
                  runSpacing: AppSizes.space8,
                  children: controller.recentSearches
                      .map(
                        (term) => _RecentChip(
                      text: term,
                      onTap: () => controller.useSearchTerm(term),
                      onRemove: () => controller.removeRecent(term),
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
            if (hasQuery) ...[
              const SizedBox(height: AppSizes.space24),
              _padded(
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppSizes.space8),
                    const Text(
                      'نتائج مقترحة فورية',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: AppSizes.space8),
                    _Badge(text: '${suggestions.length} عروض', color: AppColors.primary),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _openResults(controller),
                      child: const Text(
                        'عرض كل النتائج',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...suggestions.map((item) => _padded(_SuggestionCard(item: item))),
            ],
            if (controller.trending.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space16),
              _padded(
                const Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'الأكثر بحثاً اليوم بين الطلاب',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    _Badge(text: 'تحديث حي', color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _padded(
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                  children: controller.trending.map((item) {
                    final type = (item['type'] ?? 'course').toString();
                    final color = DiscoverySearchController.typeColor(type);
                    final term = (item['term'] ?? '').toString();
                    return GestureDetector(
                      onTap: () {
                        controller.useSearchTerm(term);
                        _openResults(controller);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: _cardDecoration(),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_typeIcons[type] ?? Icons.search, size: 18, color: color),
                            ),
                            const SizedBox(width: AppSizes.space8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    term,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.trending_up, size: 12, color: AppColors.success),
                                      const SizedBox(width: 2),
                                      Text(
                                        '+${item['count'] ?? 0} بحث',
                                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
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

class _SearchField extends StatelessWidget {
  final DiscoverySearchController controller;
  final VoidCallback onSubmit;

  const _SearchField({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
      decoration: _cardDecoration(radius: 28),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSizes.space8),
          Expanded(
            child: TextField(
              controller: controller.searchField,
              autofocus: true,
              onChanged: controller.changeQuery,
              onSubmitted: (_) => onSubmit(),
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'ابحث عن دورة، مدرس، مطبعة، أو فرصة...',
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
          if (controller.query.value.isNotEmpty)
            GestureDetector(
              onTap: controller.clearQuery,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: AppColors.surfaceSubdued, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
              ),
            ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.border,
          ),
          GestureDetector(
            onTap: () => Get.snackbar('البحث الصوتي', 'هذه الميزة ستتوفر قريبًا'),
            child: const Icon(Icons.mic_none, color: AppColors.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({required this.text, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: _cardDecoration(radius: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 14, color: AppColors.textHint),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _SuggestionCard({required this.item});

  String get _imageLabel {
    final type = item['type'];
    final num rating = item['rating'];
    if (type == 'course' && rating > 0) return '★ ${DiscoverySearchController.ratingText(rating)}';
    if (type == 'tutor' && item['hasCertificate'] == true) return 'موثق';
    if (type == 'printing' && item['hasStudentDiscount'] == true) {
      return 'خصم ${item['raw']['service']['studentDiscountPercent']}%';
    }
    if (type == 'job' && (item['price'] as num) > 0) return 'مدفوع';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;
    final color = DiscoverySearchController.typeColor(type);
    final isMain = type == 'course' || type == 'job';
    final num price = item['price'];
    final area = (item['area'] ?? '').toString();
    final imageUrl = (item['imageUrl'] ?? '').toString();

    return GestureDetector(
      onTap: () => DiscoverySearchController.openItem(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    color: AppColors.surfaceSubdued,
                    child: imageUrl.isEmpty
                        ? Icon(Icons.image_outlined, color: color)
                        : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, color: color),
                    ),
                  ),
                  if (_imageLabel.isNotEmpty)
                    PositionedDirectional(
                      bottom: 4,
                      end: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: type == 'printing' ? AppColors.secondary : AppColors.textPrimary.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _imageLabel,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DiscoverySearchController.typeLabels[type] ?? '',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (area.isNotEmpty) ...[
                        const Icon(Icons.near_me_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    item['subtitle'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: '${DiscoverySearchController.money(price)} ₪',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                            children: [
                              TextSpan(
                                text: ' / ${item['priceUnit']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => DiscoverySearchController.openItem(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isMain ? AppColors.primary : AppColors.surfaceSubdued,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DiscoverySearchController.actionText(type),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isMain ? AppColors.white : AppColors.primary,
                            ),
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
      ),
    );
  }
}