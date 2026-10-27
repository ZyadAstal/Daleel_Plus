import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';
import '../../../shared/constants/app_colors.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  final AppSearchController controller = Get.put(AppSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubdued,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBarHeader(),
            _buildCategoriesFilterBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecentSearchesSection(),
                    const SizedBox(height: 16),
                    _buildInstantResultsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: TextField(
              controller: controller.textController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (val) => controller.onSearchChanged(val),
              onSubmitted: (val) => controller.onSearchSubmitted(
                val,
              ), // حفظ البحث عند الضغط على Enter
              decoration: InputDecoration(
                hintText: 'ابحث عن دورة، وظيفة، مدرس...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                  fontFamily: 'Cairo',
                ),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textHint,
                    size: 18,
                  ),
                  onPressed: () => controller.clearSearch(), // تنظيف الحقل والنتائج فوراً عند الضغط على X
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesFilterBar() {
    final categories = [
      'الكل',
      'التعليم والتدريب',
      'المدرسون الخصوصيون',
      'الطباعة والمكتبات',
      'الوظائف',
    ];
    return Container(
      height: 50,
      color: AppColors.white,
      child: Obx(() {
        final selectedIdx = controller.selectedCategoryIndex.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIdx == index;
            return GestureDetector(
              onTap: () => controller.changeCategoryFilter(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildRecentSearchesSection() {
    return Obx(() {
      final searches = controller.recentSearches;
      if (searches.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'عمليات البحث الأخيرة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              GestureDetector(
                onTap: () => controller.clearRecentSearches(),
                child: const Text(
                  'مسح السجل',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: searches.map((term) {
              return ActionChip(
                label: Text(
                  term,
                  style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                ),
                avatar: const Icon(
                  Icons.history,
                  size: 14,
                  color: AppColors.textHint,
                ),
                backgroundColor: AppColors.white,
                onPressed: () {
                  controller.textController.text = term;
                  controller.onSearchSubmitted(term);
                },
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildInstantResultsSection() {
    return Obx(() {
      final query = controller.searchQuery.value;
      if (query.trim().isEmpty) return const SizedBox.shrink();

      final results = controller.searchResults;
      final isLoading = controller.isLoadingSearch.value;
      final displayedResults = results.take(4).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نتائج مقترحة فورية (${results.length} عروض)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              if (results.length > 4)
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'عرض كل النتائج',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (displayedResults.isEmpty)
            const Center(
              child: Text(
                'لا توجد نتائج مطابقة لبحثك',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedResults.length,
              itemBuilder: (context, index) {
                var item = displayedResults[index];
                return GestureDetector(
                  onTap: () {
                    controller.saveSearchQuery(query);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bookmark_border,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? item['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['academy'] ??
                                    item['company'] ??
                                    'خدمة معتمدة',
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      );
    });
  }
}
