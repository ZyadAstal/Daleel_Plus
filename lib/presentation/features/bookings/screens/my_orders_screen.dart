import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../providers/state/provider_helpers.dart';
import '../state/my_orders_controller.dart';
import 'add_review_screen.dart';
import 'booking_success_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  final OrdersTab initialTab;

  const MyOrdersScreen({super.key, this.initialTab = OrdersTab.active});

  static const Map<OrdersTab, String> _tabNames = {
    OrdersTab.active: 'النشطة',
    OrdersTab.completed: 'المكتملة',
    OrdersTab.canceled: 'الملغاة',
  };

  void _openTypeFilter(MyOrdersController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: MyOrdersController.typeNames.entries
              .map(
                (entry) => ListTile(
              title: Text(entry.value),
              trailing: controller.typeFilter.value == entry.key
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.changeType(entry.key);
                Get.back();
              },
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyOrdersController(initialTab: initialTab));

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

        final orders = controller.orders;
        final prompt = controller.reviewPrompt;

        if (orders.isEmpty && (controller.searchText.value.trim().isNotEmpty || controller.typeFilter.value.isNotEmpty)) {
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
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سجل الحجوزات والطلبات',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'متابعة فورية ومباشرة لحالة خدماتك الأكاديمية',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: OrdersTab.values.map((value) {
                  final isSelected = controller.tab.value == value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(value),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: isSelected ? AppColors.primary : AppColors.white,
                              child: Text(
                                '${controller.countFor(value)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _tabNames[value]!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
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
            const SizedBox(height: AppSizes.space16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            onChanged: controller.changeSearch,
                            decoration: const InputDecoration(
                              hintText: 'البحث برقم الطلب أو اسم المزود...',
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
                  onTap: () => _openTypeFilter(controller),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.typeFilter.value.isEmpty
                          ? AppColors.surfaceSubdued
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.space24),
                child: Center(child: Text('لا توجد طلبات هنا', style: TextStyle(color: AppColors.textSecondary))),
              ),
            ...orders.map((order) => _OrderCard(controller: controller, order: order)),
            if (prompt != null && controller.tab.value == OrdersTab.active)
              _ReviewPrompt(order: prompt, onClose: () => controller.hideReviewPrompt.value = true),
          ],
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final MyOrdersController controller;
  final Map<String, dynamic> order;

  const _OrderCard({required this.controller, required this.order});

  static const Map<String, String> _typeNames = {
    'printing': 'طباعة وتجليد أكاديمي',
    'course': 'حجز مقعد تدريبي',
    'session': 'جلسة تدريس خصوصي',
  };

  static const Map<String, IconData> _typeIcons = {
    'printing': Icons.print_outlined,
    'course': Icons.school_outlined,
    'session': Icons.co_present_outlined,
  };

  String _statusText(String type, String status) {
    switch (status) {
      case 'ready_for_pickup':
        return 'جاهز للاستلام من المكتبة 📦';
      case 'confirmed':
        return type == 'session' ? 'موعد معتمد 🕒' : 'حجز مؤكد وموثق ✅';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل ✅';
      case 'canceled':
        return 'ملغي';
      default:
        return 'بانتظار التأكيد';
    }
  }

  void _showQr() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'باركود الاستلام',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.space16),
              QrImageView(data: (order['orderNumber'] ?? order['id']).toString(), size: 180),
              const SizedBox(height: 10),
              Text('#${order['orderNumber'] ?? ''}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text(
                'اعرض الكود على موظف المكتبة لاستلام طلبك',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails() {
    final num amount = order['totalPaidAmount'] ?? 0;
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
            Text(
              'إيصال الطلب #${order['orderNumber'] ?? ''}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text('الخدمة: ${order['itemTitle'] ?? ''}'),
            Text('المبلغ: ${amount.toStringAsFixed(2)} ₪'),
            Text('طريقة الدفع: ${ProviderFormat.paymentMethod(order['paymentMethod'])}'),
            Text('حالة الدفع: ${ProviderFormat.paymentStatus(order['paymentStatus'])}'),
            if (order['createdAt'] is Timestamp)
              Text('تاريخ الطلب: ${ProviderFormat.date((order['createdAt'] as Timestamp).toDate())}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = (order['orderType'] ?? 'course').toString();
    final status = (order['orderStatus'] ?? '').toString();
    final color = type == 'printing' ? AppColors.secondary : AppColors.primary;
    final provider = controller.providerOf(order);
    final course = controller.courseOf(order);
    final num amount = order['totalPaidAmount'] ?? 0;
    final isPaid = order['paymentStatus'] == 'paid';
    final specs = Map<String, dynamic>.from((order['printSpecs'] ?? {}) as Map);
    final appointment = order['appointmentAt'];
    final start = course['startDate'];

    final rows = <List<dynamic>>[];
    if (type == 'printing') {
      rows.add([Icons.storefront_outlined, provider['businessName'] ?? '']);
      if (order['createdAt'] is Timestamp) {
        rows.add([
          Icons.schedule,
          'تاريخ الإرسال: ${ProviderFormat.appointment((order['createdAt'] as Timestamp).toDate())}',
        ]);
      }
    } else if (type == 'course') {
      rows.add([Icons.apartment_outlined, provider['businessName'] ?? '']);
      if (order['seatNumber'] != null) rows.add([Icons.event_seat_outlined, 'المقعد: ${order['seatNumber']}']);
    } else {
      rows.add([Icons.person_outline, 'مع ${provider['businessName'] ?? ''}']);
      final hall = Map<String, dynamic>.from((provider['hall'] ?? {}) as Map);
      if ((hall['address'] ?? '').toString().isNotEmpty) rows.add([Icons.location_on_outlined, hall['address']]);
    }

    String highlight = '';
    if (type == 'printing' && specs.isNotEmpty) {
      highlight =
      '${specs['pages'] ?? 0} صفحة (${specs['colorMode'] == 'color' ? 'ملون' : 'أبيض وأسود'}${specs['binding'] != null && specs['binding'] != 'none' ? ' + تجليد' : ''})';
    } else if (type == 'course' && start is Timestamp) {
      highlight = '● تبدأ: ${ProviderFormat.date(start.toDate())}';
    } else if (type == 'session' && appointment is Timestamp) {
      highlight = ProviderFormat.appointment(appointment.toDate());
    }

    final buttons = <Widget>[];
    if (type == 'printing') {
      if (status == 'ready_for_pickup') {
        buttons.add(_Button(text: 'باركود الاستلام', icon: Icons.qr_code_2, isPrimary: true, onTap: _showQr));
      }
      buttons.add(_IconButton(icon: Icons.receipt_long_outlined, onTap: _showDetails));
    } else if (type == 'course') {
      buttons.add(_Button(
        text: 'تذكرة الحضور',
        icon: Icons.confirmation_number_outlined,
        onTap: () => Get.to(() => BookingSuccessScreen(orderId: order['id'], isTicketView: true)),
      ));
    } else if (status != 'completed' && status != 'canceled') {
      buttons.add(_Button(
        text: 'الموقع بالخريطة',
        icon: Icons.near_me_outlined,
        onTap: () {
          final hall = Map<String, dynamic>.from((provider['hall'] ?? {}) as Map);
          final url = (hall['mapUrl'] ?? '').toString();
          launchUrl(
            url.isEmpty
                ? Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '${hall['address'] ?? ''}'})
                : Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        },
      ));
      buttons.add(_Button(
        text: order['rescheduleRequested'] == true ? 'تم طلب إعادة الجدولة' : 'إعادة الجدولة',
        isLight: true,
        onTap: order['rescheduleRequested'] == true ? null : () => controller.requestReschedule(order),
      ));
    }
    if (status == 'completed' && order['isReviewed'] != true) {
      buttons.add(_Button(
        text: 'تقييم',
        icon: Icons.star_outline,
        isPrimary: true,
        onTap: () => AddReviewScreen.open(order['id']),
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(height: 5, color: color),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _typeNames[type] ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '#${order['orderNumber'] ?? ''}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order['itemTitle'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_typeIcons[type] ?? Icons.receipt_outlined, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: rows
                              .map(
                                (row) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(row[0] as IconData, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      row[1].toString(),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (highlight.isNotEmpty)
                            Text(
                              highlight,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: type == 'course' ? AppColors.success : AppColors.textPrimary,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (status == 'canceled' ? AppColors.error : AppColors.success)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _statusText(type, status),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: status == 'canceled' ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPaid ? 'القيمة الإجمالية المسددة:' : 'المبلغ المطلوب للدفع:',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)} ₪',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isPaid ? 'مسدد إلكترونيا' : '(${ProviderFormat.paymentStatus(order['paymentStatus'])})',
                            style: TextStyle(
                              fontSize: 10,
                              color: isPaid ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 6,
                        runSpacing: 6,
                        children: buttons,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isPrimary;
  final bool isLight;
  final VoidCallback? onTap;

  const _Button({required this.text, this.icon, this.isPrimary = false, this.isLight = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color background = AppColors.primary.withValues(alpha: 0.12);
    Color foreground = AppColors.primary;
    if (isPrimary) {
      background = AppColors.primary;
      foreground = AppColors.white;
    }
    if (isLight) {
      background = AppColors.surfaceSubdued;
      foreground = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 4),
            ],
            Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground)),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.surfaceSubdued,
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ReviewPrompt extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onClose;

  const _ReviewPrompt({required this.order, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rate_review_outlined, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'طلب سابق مكتمل',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'كيف كانت تجربتك مع ${order['itemTitle'] ?? ''}؟',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const Text(
                      'تقييمك يساعد زملاءك في اختيار الخدمة الأفضل.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(
                5,
                    (index) => GestureDetector(
                  onTap: () => AddReviewScreen.open(order['id']),
                  child: const Icon(Icons.star_border_rounded, size: 28, color: AppColors.secondary),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClose,
                child: const Text('تخطي الآن', style: TextStyle(color: AppColors.textSecondary)),
              ),
              GestureDetector(
                onTap: () => AddReviewScreen.open(order['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Text(
                    'إرسال التقييم',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
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