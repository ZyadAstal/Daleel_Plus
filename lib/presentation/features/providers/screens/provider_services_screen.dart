import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/provider_helpers.dart';
import '../state/provider_services_controller.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/provider_bottom_nav.dart';
import '../widgets/provider_top_bar.dart';
import 'add_service_basic_screen.dart';

class ProviderServicesScreen extends StatelessWidget {
  const ProviderServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderServicesController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.topBarHeight),
        child: Obx(
              () => ProviderTopBar(
            title: 'الخدمات',
            showBack: false,
            isVerified: controller.isVerified.value,
            isAvailable: controller.isAvailable.value,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // إذا صار خطأ: بعد تجهيز شاشة 42 من app_status استبدلي السطر الحالي بـ:
        // if (controller.errorMessage.value.isNotEmpty) {
        //   return const UnexpectedErrorScreen(); // شاشة 42 من app_status
        // }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final courses = controller.visibleCourses;
        final topCourse = controller.mostRequestedCourse;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space24,
            vertical: AppSizes.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchField(onChanged: controller.changeSearch),
              const SizedBox(height: AppSizes.space24),
              _FilterTabs(controller: controller),
              const SizedBox(height: AppSizes.space24),
              // لا توجد نتائج للبحث: بعد تجهيز شاشة 41 من app_status استبدلي _EmptyState بـ:
              // const NoSearchResultsScreen() // شاشة 41 من app_status
              if (courses.isEmpty)
                _EmptyState(
                  message: controller.searchText.value.trim().isEmpty
                      ? 'لا توجد خدمات في هذا القسم'
                      : 'لا توجد نتائج مطابقة لـ "${controller.searchText.value.trim()}"',
                ),
              ...courses.map((course) => _ServiceCard(controller: controller, course: course)),
              const _TipCard(),
              if (topCourse != null) ...[
                const SizedBox(height: AppSizes.space16),
                _MostRequestedCard(
                  title: topCourse['title'] ?? '',
                  count: controller.mostRequestedCount,
                ),
              ],
              const SizedBox(height: AppSizes.space24),
              AppPrimaryButton(
                text: 'إضافة خدمة أو دورة جديدة',
                icon: Icons.add_circle_outline,
                onPressed: () => AddServiceBasicScreen.open(),
              ),
              const SizedBox(height: AppSizes.bottomNavGap),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 1),
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
      child: Center(
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
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.fieldHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      ),
      child: TextField(
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'ابحث في خدماتك ودوراتك...',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textPrimary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.space16),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final ProviderServicesController controller;

  const _FilterTabs({required this.controller});

  static const Map<ServiceFilter, String> _labels = {
    ServiceFilter.all: 'الكل',
    ServiceFilter.active: 'النشطة',
    ServiceFilter.full: 'مكتملة',
    ServiceFilter.paused: 'متوقفة',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => _tabs());
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: ServiceFilter.values.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_labels[filter]} (${controller.countFor(filter)})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
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

class _ServiceCard extends StatelessWidget {
  final ProviderServicesController controller;
  final Map<String, dynamic> course;

  const _ServiceCard({required this.controller, required this.course});

  bool get _isHourly => ProviderServicesController.isHourly(course);
  bool get _isFull => ProviderServicesController.isFull(course);
  bool get _isActive => ProviderServicesController.isActive(course);

  int get _maxSeats => (course['maxSeats'] as num? ?? 0).toInt();
  int get _bookedSeats => (course['bookedSeats'] as num? ?? 0).toInt();
  int get _remainingSeats => (_maxSeats - _bookedSeats).clamp(0, _maxSeats);

  double get _occupancy =>
      _maxSeats == 0 ? 0.0 : (_bookedSeats / _maxSeats).clamp(0.0, 1.0).toDouble();

  Color get _accent {
    if (_isHourly) return AppColors.success;
    if (_isFull) return AppColors.secondary;
    return AppColors.primary;
  }

  IconData get _icon {
    if (_isHourly) return Icons.handshake_outlined;
    switch (course['attendanceMode']) {
      case 'online':
        return Icons.record_voice_over_outlined;
      case 'hybrid':
        return Icons.devices_outlined;
      default:
        return Icons.terminal_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.space24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: AppSizes.space16),
          if (_isHourly)
            _hourlyBody()
          else if (_isFull)
            _fullBody()
          else
            _detailedBody(),
        ],
      ),
    );
  }

  Widget _header() {
    final String category = course['categorySubtag'] ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_icon, color: _accent, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSizes.space8,
                runSpacing: AppSizes.space4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (category.isNotEmpty) _badge(category, _accent),
                  if (_isFull) _badge('مكتمل المقاعد 🔥', AppColors.error),
                  if (_isHourly && _isActive)
                    const Icon(Icons.circle, size: 8, color: AppColors.success),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                course['title'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
              ),
            ],
          ),
        ),
        _menu(),
      ],
    );
  }

  Widget _menu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      color: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      offset: const Offset(0, 40),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'edit') AddServiceBasicScreen.open(course: course);
        if (value == 'delete') _confirmDelete();
      },
      itemBuilder: (_) => [
        _menuItem(
          value: 'edit',
          text: 'تعديل الخدمة',
          icon: Icons.edit_outlined,
          color: AppColors.primary,
        ),
        _menuItem(
          value: 'delete',
          text: 'حذف الخدمة',
          icon: Icons.delete_outline,
          color: AppColors.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color == AppColors.error ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showConfirmDialog(
      title: 'حذف الخدمة',
      message: 'هل أنت متأكد من حذف "${course['title'] ?? ''}"؟ لا يمكن التراجع عن الحذف.',
      confirmText: 'حذف',
      icon: Icons.delete_outline,
      onConfirm: () => controller.deleteCourse(course),
    );
  }

  Widget _price({Color color = AppColors.primary}) {
    final num original = course['originalPrice'] ?? 0;
    final num? discounted = course['discountedPrice'];
    final hasDiscount = discounted != null && discounted < original && original > 0;
    final percent = hasDiscount ? ((original - discounted!) / original * 100).round() : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ProviderFormat.price(hasDiscount ? discounted : original),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: AppSizes.space8),
          Text(
            ProviderFormat.price(original),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          _badge('خصم $percent% للطلاب', AppColors.error, isSquare: true),
        ],
      ],
    );
  }

  Widget _detailedBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _price(),
        const SizedBox(height: AppSizes.space16),
        _seatsBox(
          title: 'نسبة الإشغال الحالية',
          seatsText: '$_bookedSeats / $_maxSeats مقعد',
          seatsColor: AppColors.primary,
          barColor: AppColors.primary,
          footer: 'متبقي $_remainingSeats مقاعد فقط',
          percentText: '${(_occupancy * 100).round()}% مكتمل',
          percentColor: AppColors.success,
        ),
        const SizedBox(height: AppSizes.space16),
        _activeSwitch(activeText: 'نشط وظاهر للطلاب', pausedText: 'متوقف ومخفي عن الطلاب'),
        const SizedBox(height: AppSizes.space16),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                text: _isActive ? 'إيقاف مؤقت' : 'تفعيل',
                icon: _isActive ? Icons.pause_outlined : Icons.play_arrow_outlined,
                foreground: AppColors.textPrimary,
                onTap: () => controller.changeActive(course, !_isActive),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                text: 'المسجلين',
                icon: Icons.group_outlined,
                background: AppColors.primary.withValues(alpha: 0.12),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullBody() {
    final waitlist = (course['waitlistCount'] as num? ?? 0).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _price(color: AppColors.textPrimary),
        const SizedBox(height: AppSizes.space16),
        _seatsBox(
          title: 'حالة الشعبة',
          seatsText: '$_bookedSeats / $_maxSeats مقعد (مكتمل)',
          seatsColor: AppColors.error,
          barColor: AppColors.secondary,
          footer: 'قائمة الانتظار: $waitlist طلاب',
          percentText: '100% مغلق',
          percentColor: AppColors.error,
        ),
        const SizedBox(height: AppSizes.space16),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                text: 'فتح شعبة جديدة',
                icon: Icons.add_task,
                background: AppColors.primary,
                foreground: AppColors.white,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                text: 'إدارة المقاعد ($_maxSeats)',
                icon: Icons.event_seat_outlined,
                foreground: AppColors.textPrimary,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hourlyBody() {
    return Column(
      children: [
        Row(
          children: [
            _price(color: AppColors.textPrimary),
            const Text(' / ساعة', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'حسب الطلب والمواعيد',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        Row(
          children: [
            Expanded(
              child: _activeSwitch(
                activeText: 'متاح لحجز المواعيد',
                pausedText: 'الحجز متوقف حاليًا',
                isBold: false,
              ),
            ),
            _actionButton(
              text: 'جدول المواعيد',
              icon: Icons.calendar_month_outlined,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _progressBar(Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: _occupancy,
        minHeight: 8,
        color: color,
        backgroundColor: AppColors.border,
      ),
    );
  }

  Widget _seatsBox({
    required String title,
    required String seatsText,
    required Color seatsColor,
    required Color barColor,
    required String footer,
    required String percentText,
    required Color percentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12))),
              Text(
                seatsText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: seatsColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _progressBar(barColor),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  footer,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
              Text(
                percentText,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: percentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeSwitch({
    required String activeText,
    required String pausedText,
    bool isBold = true,
  }) {
    return Row(
      children: [
        Switch(
          value: _isActive,
          onChanged: (value) => controller.changeActive(course, value),
          activeTrackColor: AppColors.success,
        ),
        const SizedBox(width: AppSizes.space8),
        Flexible(
          child: Text(
            _isActive ? activeText : pausedText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold && _isActive ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color background = AppColors.surfaceSubdued,
    Color foreground = AppColors.primary,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, {bool isSquare = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isSquare ? 4 : 999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'نصيحة للمزودين: ',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  TextSpan(
                    text: 'تحديث عدد المقاعد أولًا بأول يرفع تصنيف عروضك في نتائج بحث الطلاب بنسبة 40%.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MostRequestedCard extends StatelessWidget {
  final String title;
  final int count;

  const _MostRequestedCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.trending_up, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الأكثر طلبًا هذا الأسبوع',
                  style: TextStyle(fontSize: 12, color: AppColors.secondary),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_outlined, size: 14, color: AppColors.success),
                const SizedBox(width: AppSizes.space4),
                Text(
                  '$count طلب',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
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