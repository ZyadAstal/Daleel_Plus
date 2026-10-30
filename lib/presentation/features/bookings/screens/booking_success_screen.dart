import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../discovery/screens/student_home_screen.dart';
import '../state/booking_ticket_controller.dart';
import 'my_orders_screen.dart';
import '../../app_status/screens/not_found_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String orderId;
  final bool isTicketView;

  const BookingSuccessScreen({super.key, required this.orderId, this.isTicketView = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingTicketController(orderId), tag: orderId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: isTicketView
          ? AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: const Text(
          'تذكرة الحضور',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      )
          : null,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.order.isEmpty) {
            return const NotFoundScreen();
          }

          final status = controller.status;

          return ListView(
            padding: const EdgeInsets.all(AppSizes.space24),
            children: [
              if (!isTicketView) ...[
                const SizedBox(height: AppSizes.space16),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 24),
                      ],
                    ),
                    child: const Icon(Icons.check_circle, size: 48, color: AppColors.white),
                  ),
                ),
                const SizedBox(height: AppSizes.space16),
                Text(
                  controller.isConfirmed ? 'تم تأكيد حجزك بنجاح! 🎉' : 'تم إرسال طلب حجزك! 🎉',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.isConfirmed
                      ? 'تم حجز مقعدك بنجاح، وهذه تذكرتك لتأكيد الحضور.'
                      : 'سيقوم المركز بمراجعة طلبك وتأكيده، وتتحدث حالة التذكرة هنا مباشرة.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.space24),
              ],
              _Ticket(controller: controller, status: status),
              const SizedBox(height: AppSizes.space24),
              const Text(
                'إجراءات سريعة لتذكرتك',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.edit_calendar_outlined,
                text: 'إضافة الموعد إلى تقويم الهاتف',
                trailing: '📅',
                isHighlighted: true,
                onTap: controller.addToCalendar,
              ),
              _ActionTile(
                icon: Icons.picture_as_pdf_outlined,
                text: 'تحميل التذكرة بصيغة PDF',
                trailing: '📥',
                // TODO: تحميل التذكرة PDF بعد إضافة باكج pdf
                onTap: () => Get.snackbar('قريبًا', 'تحميل التذكرة بصيغة PDF سيتوفر قريبًا'),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: controller.openLocation,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                        child: const Icon(Icons.location_on_outlined, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مقر ${controller.provider['businessName'] ?? 'المركز'}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              controller.providerAddress.isEmpty ? 'عرض الموقع على الخريطة' : controller.providerAddress,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.map_outlined, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              if (!isTicketView) ...[
                const SizedBox(height: AppSizes.space24),
                GestureDetector(
                  onTap: () => Get.off(() => const MyOrdersScreen()),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(28)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'الانتقال إلى حجوزاتي وطلباتي',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: AppColors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Get.offAll(() => const StudentHomeScreen()),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 18, color: AppColors.textPrimary),
                        SizedBox(width: 6),
                        Text(
                          'العودة إلى الشاشة الرئيسية',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );
}

class _Ticket extends StatelessWidget {
  final BookingTicketController controller;
  final String status;

  const _Ticket({required this.controller, required this.status});

  @override
  Widget build(BuildContext context) {
    final order = controller.order;
    final statusColor = status == 'canceled'
        ? AppColors.error
        : controller.isConfirmed
        ? AppColors.success
        : AppColors.secondary;
    final seat = (order['seatNumber'] ?? '').toString();
    final section = (order['sectionName'] ?? controller.course['sectionName'] ?? '').toString();
    final num amount = order['totalPaidAmount'] ?? 0;
    final isPaid = order['paymentStatus'] == 'paid';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(height: 5, color: AppColors.primary),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '#${controller.text('orderNumber')}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.statusText,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('اسم البرنامج الأكاديمي', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  controller.text('itemTitle'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [controller.provider['businessName'] ?? '', controller.providerAddress]
                            .where((text) => text.toString().isNotEmpty)
                            .join(' - '),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 24,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(
                        30,
                            (_) => Expanded(
                          child: Container(
                            height: 1.5,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            color: AppColors.border,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const PositionedDirectional(start: -12, top: 0, child: _Notch()),
                const PositionedDirectional(end: -12, top: 0, child: _Notch()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              children: [
                _InfoBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('اسم الطالب المستفيد',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text(
                              controller.text('studentName'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              [controller.text('studentUniversity'), controller.text('studentMajor')]
                                  .where((text) => text.isNotEmpty)
                                  .join(' - '),
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('المقعد والشعبة', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          Text(
                            seat.isEmpty ? 'يُحدد عند التأكيد' : 'Seat: $seat',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          if (section.isNotEmpty)
                            Text(section, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _InfoBox(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.event_available, color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.dateText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (controller.timeText.isNotEmpty)
                              Text(
                                controller.timeText,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _InfoBox(
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: AppColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('حالة السداد والطريقة',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text(
                              controller.paymentText,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${amount.toStringAsFixed(2)} ₪',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            isPaid ? 'مكتمل ✅' : 'عند الحضور',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isPaid ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.space16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _cardDecoration(),
                  child: QrImageView(
                    data: controller.text('orderNumber').isEmpty ? controller.orderId : controller.text('orderNumber'),
                    size: 150,
                    backgroundColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'امسح الكود عند مدخل المركز لتأكيد الحضور فورا',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const Text(
                  'صالحة لمرة واحدة فقط للدخول الشخصي للمقعد المخصص',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(color: AppColors.scaffoldBg, shape: BoxShape.circle),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Widget child;

  const _InfoBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String trailing;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.text,
    required this.trailing,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: isHighlighted
            ? BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        )
            : _cardDecoration(),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            Text(trailing, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}