import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/checkout_controller.dart';
import 'booking_success_screen.dart';
import '../../app_status/screens/system_error_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static void openCourse(String courseId) => _open('course', courseId);

  static void openSession(String tutorId) => _open('session', tutorId);

  static void _open(String type, String id) {
    Get.delete<CheckoutController>(force: true);
    Get.put(CheckoutController(type: type, itemId: id));
    Get.to(() => const CheckoutScreen());
  }

  static const Map<String, IconData> _paymentIcons = {
    'jawwal_pay': Icons.phone_android,
    'cash': Icons.payments_outlined,
    'card': Icons.credit_card,
  };

  static const Map<String, String> _paymentNotes = {
    'jawwal_pay': 'تسوية فورية وآمنة برقم الجوال (+970 59)',
    'cash': 'حجز مقعد مؤقت لمدة 24 ساعة لتأكيد الحضور',
    'card': 'بوابات الدفع الوطنية وبنك فلسطين',
  };

  Future<void> _confirm(CheckoutController controller) async {
    final orderId = await controller.confirm();
    if (orderId == null) return;
    Get.off(() => BookingSuccessScreen(orderId: orderId));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'مراجعة الطلب و الدفع', actions: []),
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

        final num hours = controller.item['totalHours'] ?? 0;
        final coupon = controller.coupon.value;

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            _Card(
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
                            _Badge(
                              text: controller.isSession ? 'جلسات التدريس الخاص' : 'التعليم والتدريب التقني',
                              color: AppColors.primary,
                              withDot: true,
                            ),
                            const SizedBox(height: AppSizes.space8),
                            Text(
                              controller.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.code, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.apartment_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          controller.providerName,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      if (controller.providerArea.isNotEmpty)
                        _Badge(text: '(${controller.providerArea})', color: AppColors.textSecondary),
                    ],
                  ),
                  if (controller.dateText.isNotEmpty || hours > 0)
                    _InfoLine(
                      icon: Icons.calendar_today_outlined,
                      text: [
                        if (controller.dateText.isNotEmpty) 'يبدأ ${controller.dateText}',
                        if (hours > 0) '$hours ساعة تدريبية',
                      ].join(' • '),
                    ),
                  _InfoLine(icon: Icons.location_on_outlined, text: controller.attendanceText),
                  if (controller.studentDiscount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.success,
                            child: Icon(Icons.verified_outlined, size: 18, color: AppColors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'بطاقة دليل+ الطلابية مفعلة',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'خصم ${controller.studentDiscountPercent}% حصري للمقاعد الجامعية',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          _Badge(text: '-${controller.studentDiscountPercent}%', color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.card_giftcard, size: 20, color: AppColors.secondary),
                      SizedBox(width: 6),
                      Text(
                        'كوبون الخصم الطلابي الإضافي',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                              if (coupon != null) ...[
                                const Icon(Icons.check_circle_outline, size: 20, color: AppColors.success),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: TextField(
                                  controller: controller.couponController,
                                  enabled: coupon == null,
                                  textCapitalization: TextCapitalization.characters,
                                  onSubmitted: (_) => controller.applyCoupon(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'أدخل كود الخصم',
                                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
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
                        onTap: coupon == null ? controller.applyCoupon : controller.removeCoupon,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubdued,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            coupon == null ? 'تطبيق' : 'تغيير',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (coupon != null) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        '🎉 تم تطبيق كود إضافي بقيمة ${CheckoutController.money(controller.couponDiscount)} ₪ بنجاح',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل الفاتورة والمستحقات',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _PriceRow(
                    label: controller.isSession ? 'سعر الجلسة (ساعة)' : 'السعر الأصلي',
                    value: '${CheckoutController.money(controller.originalPrice)} ₪',
                  ),
                  if (controller.studentDiscount > 0)
                    _PriceRow(
                      label: 'خصم بطاقة دليل+ الأكاديمية (${controller.studentDiscountPercent}%)',
                      value: '- ${CheckoutController.money(controller.studentDiscount)} ₪',
                      color: AppColors.success,
                    ),
                  if (coupon != null)
                    _PriceRow(
                      label: 'كوبون إضافي للطلاب (${coupon['code']})',
                      value: '- ${CheckoutController.money(controller.couponDiscount)} ₪',
                      color: AppColors.success,
                    ),
                  _PriceRow(
                    label: 'رسوم إصدار الشهادة وحقيبة المواد',
                    value: controller.fees == 0 ? 'مجاناً 0.00 ₪' : '${CheckoutController.money(controller.fees)} ₪',
                    isBadge: controller.fees == 0,
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إجمالي المبلغ المستحق',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              Text(
                                'شامل الضريبة وكافة المواد',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${CheckoutController.money(controller.total)} ₪',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'طريقة الدفع المعتمدة',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      Text('اختر وسيلتك المفضلة', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...CheckoutController.paymentNames.entries.map((entry) {
                    final isSelected = controller.paymentMethod.value == entry.key;
                    final isEnabled = CheckoutController.enabledPayments.contains(entry.key);
                    return GestureDetector(
                      onTap: () => controller.changePayment(entry.key),
                      child: Opacity(
                        opacity: isEnabled ? 1 : 0.55,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(AppSizes.space16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isSelected ? AppColors.primary : AppColors.textHint,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      isEnabled ? _paymentNotes[entry.key]! : 'سيتوفر قريبًا',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.surfaceSubdued,
                                child: Icon(_paymentIcons[entry.key], size: 20, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.success,
                    child: Icon(Icons.verified_user_outlined, size: 20, color: AppColors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ضمان استرداد كامل خلال 48 ساعة',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          'يمكنك طلب استرداد الرسوم بالكامل حتى بعد المحاضرة الأولى إن لم تتوافق تطلعاتك التعليمية.',
                          style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.space24, AppSizes.space16, AppSizes.space24, AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
          ],
        ),
        child: Obx(() {
          final canSend = !controller.isLoading.value && !controller.isSending.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: canSend ? () => _confirm(controller) : null,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                  decoration: BoxDecoration(
                    color: canSend ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: controller.isSending.value
                      ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                    ),
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.paymentMethod.value == 'cash' ? 'تأكيد الحجز الآن' : 'تأكيد الحجز والدفع الآن',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${CheckoutController.money(controller.total)} ₪',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: AppColors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'معاملات مشفرة ومحمية وفق أعلى معايير الأمان المصرفي',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

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
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final bool withDot;

  const _Badge({required this.text, required this.color, this.withDot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withDot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.space8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBadge;

  const _PriceRow({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
    this.isBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: color))),
          if (isBadge)
            _Badge(text: value, color: AppColors.primary)
          else
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}