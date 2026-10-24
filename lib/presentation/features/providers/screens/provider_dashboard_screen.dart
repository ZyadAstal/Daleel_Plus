import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/provider_dashboard_controller.dart';
import '../state/provider_helpers.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/provider_bottom_nav.dart';
import '../widgets/provider_top_bar.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/student_request_card.dart';
import '../widgets/weekly_bookings_chart.dart';
import 'provider_profile_screen.dart';
import 'add_service_basic_screen.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderDashboardController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.topBarHeight),
        child: Obx(
              () => ProviderTopBar(
            title: 'لوحة التحكم',
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

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space24,
            vertical: AppSizes.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CenterCard(controller: controller),
              const SizedBox(height: AppSizes.space24),
              if (controller.newOrdersCount.value > 0) ...[
                _NewRequestsBanner(count: controller.newOrdersCount.value),
                const SizedBox(height: AppSizes.space24),
              ],
              _StatsGrid(controller: controller),
              const SizedBox(height: AppSizes.space24),
              const _QuickActions(),
              const SizedBox(height: AppSizes.space24),
              WeeklyBookingsChart(counts: controller.weeklyCounts.toList()),
              const SizedBox(height: AppSizes.space24),
              _LatestRequests(controller: controller),
              const SizedBox(height: AppSizes.space8),
              const _TipCard(),
              const SizedBox(height: AppSizes.space24),
              AppPrimaryButton(
                text: 'نشر دورة أو خدمة أكاديمية جديدة',
                icon: Icons.add_circle_outline,
                onPressed: () => AddServiceBasicScreen.open(),
              ),
              const SizedBox(height: AppSizes.bottomNavGap),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 0),
    );
  }
}

class _CenterCard extends StatelessWidget {
  final ProviderDashboardController controller;

  const _CenterCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _logo(),
                const SizedBox(width: 12),
                Expanded(child: _details()),
                Container(
                  width: 32,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.open_in_new, size: 18, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            Row(
              children: [
                Switch(
                  value: controller.isAvailable.value,
                  onChanged: controller.changeAvailability,
                  activeTrackColor: AppColors.success,
                ),
                const SizedBox(width: AppSizes.space4),
                Expanded(child: _availabilityText()),
                _profileButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    final logoUrl = controller.logoUrl.value;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubdued,
            borderRadius: BorderRadius.circular(12),
          ),
          child: logoUrl.isEmpty
              ? const Icon(Icons.school, color: AppColors.primary)
              : Image.network(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.school, color: AppColors.primary),
          ),
        ),
        PositionedDirectional(
          bottom: -4,
          end: -4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: controller.isAvailable.value
                  ? AppColors.success
                  : AppColors.textHint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success.withValues(alpha: 0.15), width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.businessName.value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        if (controller.isVerified.value) ...[
          const SizedBox(height: AppSizes.space4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 12, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'معتمد',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSizes.space4),
        Text(
          controller.locationText,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _availabilityText() {
    final isAvailable = controller.isAvailable.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAvailable ? 'متاح لاستقبال الطلبات' : 'غير متاح حاليًا',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isAvailable ? AppColors.success : AppColors.textHint,
          ),
        ),
        Text(
          isAvailable ? 'الرد الفوري مفعل' : 'لن تصلك طلبات جديدة',
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _profileButton() {
    return GestureDetector(
      onTap: () => Get.off(() => const ProviderProfileScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ملف المركز',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.visibility_outlined, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _NewRequestsBanner extends StatelessWidget {
  final int count;

  const _NewRequestsBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF5232CC)],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.white.withValues(alpha: 0.15),
            child: Icon(Icons.notifications_active, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 1 ? 'لديك طلب جديد!' : 'لديك $count طلبات جديدة!',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const Text(
                  'تتطلب المراجعة خلال أقل من ساعة',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'مراجعة الآن',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ProviderDashboardController controller;

  const _StatsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: 'إجمالي الحجوزات',
                  value: ProviderFormat.number(controller.totalOrders.value),
                  icon: Icons.calendar_month_outlined,
                  note: controller.monthGrowthText,
                  noteIcon: Icons.trending_up,
                  noteColor: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.space16),
              Expanded(
                child: DashboardStatCard(
                  title: 'صافي الأرباح',
                  value: ProviderFormat.number(controller.netEarnings.value),
                  unit: '₪',
                  unitSize: 26,
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.success,
                  iconBackground: AppColors.success.withValues(alpha: 0.15),
                  valueColor: AppColors.success,
                  note: 'أرباح محققة قابلة للسحب',
                  noteIcon: Icons.circle,
                  noteIconSize: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: 'الخدمات النشطة',
                  value: '${controller.activeCourses.value}',
                  unit: 'دورات',
                  icon: Icons.layers_outlined,
                  iconBackground: AppColors.surfaceSubdued,
                  note: '${controller.pendingReviewCourses.value} دورات بانتظار التحديث',
                ),
              ),
              const SizedBox(width: AppSizes.space16),
              Expanded(
                child: DashboardStatCard(
                  title: 'تقييم الطلاب',
                  value: controller.ratingText,
                  unit: controller.reviewsCount.value == 0 ? '' : '★',
                  unitSize: 20,
                  unitColor: AppColors.secondary,
                  icon: Icons.star_rounded,
                  iconColor: AppColors.secondary,
                  iconBackground: AppColors.secondary.withValues(alpha: 0.2),
                  note: controller.reviewsNote,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'إجراءات سريعة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'إدارة المركز',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        Row(
          children: [
            QuickActionButton(
              label: 'إضافة خدمة',
              icon: Icons.add,
              isMain: true,
              onTap: () => AddServiceBasicScreen.open(),
            ),
            QuickActionButton(label: 'المواعيد', icon: Icons.schedule, onTap: () {}),
            QuickActionButton(
              label: 'سحب الأرباح',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.success,
              onTap: () {},
            ),
            QuickActionButton(
              label: 'الدعم الفني',
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.textPrimary,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _LatestRequests extends StatelessWidget {
  final ProviderDashboardController controller;

  const _LatestRequests({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        children: [
          Row(
            children: [
              const Text(
                'أحدث طلبات الطلاب',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSizes.space8),
              if (controller.newOrdersCount.value > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${controller.newOrdersCount.value} قيد الانتظار',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          if (controller.latestOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSizes.space24),
              child: Text(
                'لا توجد طلبات حتى الآن',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ...controller.latestOrders.map((order) => _orderCard(order)),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final status = order['orderStatus'] ?? '';
    final orderNumber = '#${order['orderNumber'] ?? ''}';
    final time = ProviderFormat.timeAgo(order['createdAt']);
    final price = ProviderFormat.price(order['totalPaidAmount']);
    final isFree = price == 'مجانا';
    final isPaid = order['paymentStatus'] == 'paid';

    var statusText = ProviderFormat.orderStatus(status);
    var statusColor = AppColors.success;
    var statusBackground = AppColors.success.withValues(alpha: 0.15);
    var priceColor = isFree ? AppColors.textPrimary : AppColors.primary;
    var infoIcon = Icons.receipt_long_outlined;
    var info = 'رقم الطلب $orderNumber · ${ProviderFormat.paymentMethod(order['paymentMethod'])}';
    var extraText = ProviderFormat.paymentStatus(order['paymentStatus']);
    var extraColor = AppColors.textSecondary;
    Widget? bottom;

    if (status == 'pending') {
      final isAccepting = controller.acceptingOrderId.value == order['id'];
      statusColor = AppColors.primary;
      statusBackground = AppColors.surfaceSubdued;
      infoIcon = Icons.access_time;
      info = '$time · رقم الطلب $orderNumber';
      extraText = ProviderFormat.attendance(order['attendanceMode']);
      extraColor = AppColors.secondary;
      bottom = Row(
        children: [
          Expanded(
            flex: 3,
            child: _smallButton(
              text: isAccepting ? 'جاري القبول...' : 'قبول الطلب',
              icon: Icons.check,
              isMain: true,
              onTap: isAccepting ? null : () => controller.acceptOrder(order),
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          Expanded(child: _smallButton(text: 'التفاصيل', onTap: () {})),
        ],
      );
    } else if ((status == 'confirmed' || status == 'completed') && isPaid) {
      statusText = status == 'completed' ? 'مكتمل' : 'مؤكد ومسدد';
      priceColor = AppColors.success;
      extraText = 'مكتمل التحقق';
      extraColor = AppColors.success;
      bottom = _smallButton(
        text: 'عرض إيصال السداد ومراسلة الطالب',
        icon: Icons.receipt_long,
        onTap: () {},
      );
    } else if (status == 'in_progress') {
      statusColor = AppColors.secondary;
      statusBackground = AppColors.secondary.withValues(alpha: 0.2);
      infoIcon = Icons.assignment_outlined;
      info = 'رقم الطلب $orderNumber · $time';
      extraText = 'متابعة الفحص';
      extraColor = AppColors.primary;
    } else if (status == 'ready_for_pickup') {
      statusColor = AppColors.secondary;
      statusBackground = AppColors.secondary.withValues(alpha: 0.2);
    }

    return StudentRequestCard(
      studentName: order['studentName'] ?? '',
      avatarUrl: order['studentAvatar'] ?? '',
      serviceName: order['itemTitle'] ?? '',
      price: price,
      priceColor: priceColor,
      statusText: statusText,
      statusColor: statusColor,
      statusBackground: statusBackground,
      infoIcon: infoIcon,
      info: info,
      extraText: extraText,
      extraColor: extraColor,
      isHighlighted: status == 'pending',
      bottom: bottom,
    );
  }

  Widget _smallButton({
    required String text,
    IconData? icon,
    bool isMain = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isMain ? AppColors.primary : AppColors.surfaceSubdued,
          foregroundColor: isMain ? AppColors.white : AppColors.primary,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 16),
            ],
          ],
        ),
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
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.lightbulb_outline, color: AppColors.textPrimary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نصيحة لتسريع المبيعات',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'إضافة توصيف تفصيلي للدورة ومخرجاتها يزيد من معدل التحاق الطلاب بنسبة 45%.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}