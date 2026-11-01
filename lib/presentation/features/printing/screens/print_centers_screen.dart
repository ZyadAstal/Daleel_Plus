import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../providers/state/provider_helpers.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../state/print_centers_controller.dart';
import '../state/print_order_controller.dart';
import 'print_order_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class PrintCentersScreen extends StatelessWidget {
  const PrintCentersScreen({super.key});

  void _openOrder(Map<String, dynamic> center) => PrintOrderScreen.open(center);

  void _showSortSheet(PrintCentersController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ترتيب المراكز', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSizes.space16),
                _sortOption(controller, PrintSort.rating, 'الأعلى تقييمًا', Icons.star_outline),
                _sortOption(controller, PrintSort.price, 'الأقل سعرًا للصفحة', Icons.sell_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sortOption(PrintCentersController controller, PrintSort sort, String label, IconData icon) {
    final isSelected = controller.sortBy.value == sort;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? AppColors.primary : AppColors.textHint,
      ),
      onTap: () {
        controller.changeSort(sort);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrintCentersController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'المكتبات ومراكز الطباعة'),
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

        final centers = controller.visibleCenters;
        final available = controller.centers.where((c) => c['isAcceptingOrders'] ?? true).toList();

        if (centers.isEmpty && controller.searchText.value.trim().isNotEmpty) {
          return EmptyStateScreen(
            searchTerm: controller.searchText.value.trim(),
            onClearSearch: () => controller.changeSearch(''),
            onResetFilters: () {
              controller.changeSearch('');
              controller.changeFilter(PrintFilter.all);
            },
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: _SearchBar(
                  onChanged: controller.changeSearch,
                  onFilterTap: () => _showSortSheet(controller),
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              _FilterChips(controller: controller),
              const SizedBox(height: AppSizes.space24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: Column(
                  children: [
                    _HeroCard(
                      onUpload: available.isEmpty ? null : () => _openOrder(available.first),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    _StatsRow(
                      centersCount: controller.centers.length,
                      prepMinutes: controller.averagePrepMinutes,
                      discount: controller.maxStudentDiscount,
                    ),
                    const SizedBox(height: AppSizes.space24),
                    if (centers.isEmpty)
                      _EmptyState(
                        message: controller.searchText.value.trim().isEmpty
                            ? 'لا توجد مراكز طباعة في هذا القسم'
                            : 'لا توجد نتائج مطابقة لـ "${controller.searchText.value.trim()}"',
                      ),
                    ...centers.map(
                          (center) => _CenterCard(
                        center: center,
                        isFavorite: controller.favoriteIds.contains(center['id']),
                        onFavorite: () => controller.toggleFavorite(center['id']),
                        onOrder: () => _openOrder(center),
                      ),
                    ),
                    const SizedBox(height: AppSizes.bottomNavGap),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const _SearchBar({required this.onChanged, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.fieldHeight,
      padding: const EdgeInsetsDirectional.only(end: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'ابحث باسم المطبعة، المنطقة أو نوع الورق...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textPrimary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, size: 20, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final PrintCentersController controller;

  const _FilterChips({required this.controller});

  static const Map<PrintFilter, String> _labels = {
    PrintFilter.all: 'الكل',
    PrintFilter.research: 'طباعة أبحاث ومشاريع',
    PrintFilter.engineering: 'مخططات هندسية A0/A1',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: Row(
        children: PrintFilter.values.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;
          final label = filter == PrintFilter.all
              ? '${_labels[filter]} (${controller.countFor(filter)})'
              : _labels[filter]!;

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSizes.space8),
            child: GestureDetector(
              onTap: () => controller.changeFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback? onUpload;

  const _HeroCard({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF5B3FE0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.secondary),
                SizedBox(width: 6),
                Text(
                  'توفير الوقت والجهد الأكاديمي',
                  style: TextStyle(fontSize: 11, color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خدمة الطباعة والتجليد الفورية لمشاريع التخرج والأبحاث',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: AppSizes.space8),
                    Text(
                      'ارفع ملفاتك رقميًا واستلم مشروعك مطبوعًا ومجلدًا فورًا بدون طوابير انتظار!',
                      style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.print, color: AppColors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, color: AppColors.secondary, size: 20),
                const SizedBox(width: AppSizes.space8),
                const Expanded(
                  child: Text(
                    'ارفع ملف PDF لحساب التكلفة',
                    style: TextStyle(fontSize: 12, color: AppColors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: onUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('رفع سريع'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int centersCount;
  final int prepMinutes;
  final int discount;

  const _StatsRow({
    required this.centersCount,
    required this.prepMinutes,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat(Icons.verified_outlined, '$centersCount', 'مركز معتمد', AppColors.primary),
        const SizedBox(width: 12),
        _stat(Icons.bolt, '$prepMinutes د', 'متوسط التجهيز', AppColors.success),
        const SizedBox(width: 12),
        _stat(null, '$discount %', 'خصم الطلاب', AppColors.secondary),
      ],
    );
  }

  Widget _stat(IconData? icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: AppSizes.space4),
                ],
                Flexible(child: Text(
                  value,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color),
                )),
              ],
            ),
            const SizedBox(height: AppSizes.space4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.surfaceSubdued,
            child: Icon(Icons.search_off_rounded, size: 30, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  final Map<String, dynamic> center;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onOrder;

  const _CenterCard({
    required this.center,
    required this.isFavorite,
    required this.onFavorite,
    required this.onOrder,
  });

  Map<String, dynamic> get _service => Map<String, dynamic>.from(center['service'] ?? {});

  String _text(String key) => (center[key] ?? '').toString();

  // نافذة تفاصيل المركز: العنوان، الدوام، الأسعار، والتواصل
  void _showDetails(bool isAvailable) {
    final List days = center['workingDays'] ?? [];
    final hours = days.isEmpty
        ? 'لم تُحدد بعد'
        : '${ProviderFormat.dayName(days.first)} - ${ProviderFormat.dayName(days.last)} '
            '(${ProviderFormat.time12h(_text('openingTime'))} - ${ProviderFormat.time12h(_text('closingTime'))})';
    final address = [_text('city'), _text('addressDetails')].where((t) => t.isNotEmpty).join(' - ');
    const prices = {
      'bwPagePrice': 'صفحة أبيض وأسود',
      'colorPagePrice': 'صفحة ملونة',
      'spiralBindingPrice': 'تجليد سلك',
      'thermalBindingPrice': 'تجليد حراري',
      'hardCoverBindingPrice': 'تجليد كرتون مقوى',
      'largePosterPrice': 'بوستر كبير',
    };
    final whatsapp = _text('whatsappNumber').replaceAll(RegExp(r'[^0-9]'), '');

    Widget line(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.space8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSizes.space8),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
            ],
          ),
        );

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_text('businessName'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              if (_text('headline').isNotEmpty)
                Text(_text('headline'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: AppSizes.space16),
              if (address.isNotEmpty) line(Icons.location_on_outlined, address),
              line(Icons.schedule, hours),
              line(isAvailable ? Icons.check_circle_outline : Icons.pause_circle_outline,
                  isAvailable ? 'يستقبل طلبات الآن' : 'لا يستقبل طلبات حاليًا'),
              if (_text('bioDescription').isNotEmpty) ...[
                const SizedBox(height: AppSizes.space8),
                Text(_text('bioDescription'),
                    style: const TextStyle(fontSize: 12, height: 1.7, color: AppColors.textSecondary)),
              ],
              const SizedBox(height: AppSizes.space16),
              const Text('الأسعار', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSizes.space8),
              for (final price in prices.entries)
                if ((_service[price.key] ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(price.value, style: const TextStyle(fontSize: 13))),
                        Text('${_service[price.key]} ₪',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ),
              const SizedBox(height: AppSizes.space16),
              Row(
                children: [
                  if (whatsapp.isNotEmpty) ...[
                    Expanded(
                      child: _button(
                        text: 'واتساب',
                        icon: Icons.chat_outlined,
                        onTap: () => launchUrl(Uri.parse('https://wa.me/$whatsapp'),
                            mode: LaunchMode.externalApplication),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (address.isNotEmpty)
                    Expanded(
                      child: _button(
                        text: 'الخريطة',
                        icon: Icons.map_outlined,
                        onTap: () => launchUrl(
                          Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': address}),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _button(
                text: 'طلب طباعة فوري',
                icon: Icons.send_outlined,
                isMain: true,
                onTap: isAvailable
                    ? () {
                        Get.back();
                        onOrder();
                      }
                    : null,
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = center['isAcceptingOrders'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image(isAvailable),
              const SizedBox(width: 12),
              Expanded(child: _info()),
              GestureDetector(
                onTap: onFavorite,
                child: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorite ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          _priceBox(),
          const SizedBox(height: AppSizes.space16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _button(
                  text: 'طلب طباعة فوري',
                  icon: Icons.send_outlined,
                  isMain: true,
                  onTap: isAvailable ? onOrder : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _button(text: 'تفاصيل المركز', onTap: () => _showDetails(isAvailable)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _image(bool isAvailable) {
    final String url = center['coverImageUrl'] ?? '';

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url.isEmpty
                ? Container(
              width: 80,
              height: 80,
              color: AppColors.surfaceSubdued,
              child: const Icon(Icons.print_outlined, color: AppColors.primary, size: 30),
            )
                : Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
          ),
          PositionedDirectional(
            bottom: 6,
            start: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isAvailable ? AppColors.success : AppColors.textSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 6, color: AppColors.white),
                  const SizedBox(width: 3),
                  Text(
                    isAvailable ? 'متاح' : 'مغلق',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
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

  Widget _info() {
    final rating = (center['averageRating'] ?? 0).toDouble();
    final int reviews = ((center['ratingsCount'] ?? center['reviewsCount'] ?? 0) as num).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reviews > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 13, color: AppColors.secondary),
                const SizedBox(width: 2),
                Text(
                  '${rating.toStringAsFixed(1)} ($reviews تقييم)',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Text(
          center['businessName'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                center['addressDetails'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _priceBox() {
    final service = _service;
    final List features = service['features'] ?? [];
    final String offer = service['offerText'] ?? '';
    final String highlight = service['highlight'] ?? '';
    final largePoster = service['largePosterPrice'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlight.isNotEmpty)
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13),
                children: [
                  const TextSpan(
                    text: 'التميز: ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextSpan(
                    text: highlight,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                const Text(
                  'سعر الطباعة:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'تبدأ من '),
                        TextSpan(
                          text: PrintOrderController.money((service['bwPagePrice'] ?? 0).toDouble()),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(text: ' / صفحة'),
                        if (largePoster != null) ...[
                          const TextSpan(text: '  |  '),
                          TextSpan(
                            text: PrintOrderController.money(largePoster.toDouble()),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const TextSpan(text: ' / مخطط A0'),
                        ],
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: AppSizes.space8,
              runSpacing: AppSizes.space8,
              children: features
                  .map(
                    (feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                      const SizedBox(width: AppSizes.space4),
                      Text(feature.toString(), style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ],
          if (offer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sell_outlined, size: 14, color: AppColors.textPrimary),
                  const SizedBox(width: AppSizes.space4),
                  Text(offer, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _button({
    required String text,
    IconData? icon,
    bool isMain = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isMain ? AppColors.primary : AppColors.surfaceSubdued,
          foregroundColor: isMain ? AppColors.white : AppColors.primary,
          elevation: isMain ? 4 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}