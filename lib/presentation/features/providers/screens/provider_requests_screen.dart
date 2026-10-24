import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../state/provider_helpers.dart';
import '../state/provider_requests_controller.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/provider_bottom_nav.dart';
import '../widgets/provider_top_bar.dart';
import 'provider_profile_screen.dart';

class ProviderRequestsScreen extends StatelessWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderRequestsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.topBarHeight),
        child: Obx(
              () => ProviderTopBar(
            title: 'الطلبات',
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

        final orders = controller.visibleOrders;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: _HeaderCard(newCount: controller.countFor(RequestFilter.pending)),
              ),
              const SizedBox(height: AppSizes.space24),
              _StatusTabs(controller: controller),
              const SizedBox(height: AppSizes.space16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: _SearchField(onChanged: controller.changeSearch),
              ),
              const SizedBox(height: AppSizes.space16),
              _UniversityChips(controller: controller),
              const SizedBox(height: AppSizes.space24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: Column(
                  children: [
                    // لا توجد نتائج للبحث: بعد تجهيز شاشة 41 من app_status استبدلي _EmptyState بـ:
                    // const NoSearchResultsScreen() // شاشة 41 من app_status
                    if (orders.isEmpty)
                      _EmptyState(
                        message: controller.searchText.value.trim().isEmpty
                            ? 'لا توجد طلبات في هذا القسم'
                            : 'لا توجد نتائج مطابقة لـ "${controller.searchText.value.trim()}"',
                      ),
                    ...orders.map((order) => _RequestCard(controller: controller, order: order)),
                    _CollectionCard(amount: controller.amountToCollect),
                    const SizedBox(height: AppSizes.bottomNavGap),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 2),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int newCount;

  const _HeaderCard({required this.newCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSizes.space8),
              const Expanded(
                child: Text(
                  'حجوزات وطلبات الطلاب',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.secondary),
                    SizedBox(width: AppSizes.space4),
                    Text(
                      'مباشر الآن',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.secondary, size: 22),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: newCount == 0
                      ? const Text(
                    'لا توجد طلبات جديدة حاليًا',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  )
                      : Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      children: [
                        const TextSpan(text: 'لديك '),
                        TextSpan(
                          text: '$newCount طلبات جديدة',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(text: ' تتطلب اتخاذ إجراء فوري'),
                      ],
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

class _StatusTabs extends StatelessWidget {
  final ProviderRequestsController controller;

  const _StatusTabs({required this.controller});

  static const Map<RequestFilter, String> _labels = {
    RequestFilter.pending: 'الجديدة',
    RequestFilter.active: 'المؤكدة والجارية',
    RequestFilter.completed: 'المكتملة',
    RequestFilter.canceled: 'الملغاة',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: Row(
        children: RequestFilter.values.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSizes.space8),
            child: GestureDetector(
              onTap: () => controller.changeFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.white.withValues(alpha: 0.2)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${controller.countFor(filter)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _labels[filter]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
          hintText: 'ابحث برقم الطلب #KHT أو اسم الطالب...',
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textPrimary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.space16),
        ),
      ),
    );
  }
}

class _UniversityChips extends StatelessWidget {
  final ProviderRequestsController controller;

  const _UniversityChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: Row(
        children: controller.universities.map((university) {
          final isSelected = controller.selectedUniversity.value == university;

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSizes.space8),
            child: GestureDetector(
              onTap: () => controller.changeUniversity(university),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                ),
                child: Text(
                  university,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
              child: Icon(Icons.inbox_outlined, size: 30, color: AppColors.primary),
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

class _RequestCard extends StatelessWidget {
  final ProviderRequestsController controller;
  final Map<String, dynamic> order;

  const _RequestCard({required this.controller, required this.order});

  String get _status => order['orderStatus'] ?? '';
  String get _type => order['orderType'] ?? 'course';

  DateTime? get _appointment => (order['appointmentAt'] as Timestamp?)?.toDate();

  @override
  Widget build(BuildContext context) {
    return Obx(() => _card(context, controller.busyOrderId.value == order['id']));
  }

  Widget _card(BuildContext context, bool isBusy) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.space24),
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topRow(),
          const SizedBox(height: AppSizes.space16),
          _studentBox(),
          const SizedBox(height: AppSizes.space16),
          ..._body(context, isBusy),
        ],
      ),
    );
  }

  Widget _topRow() {
    final String location = order['pickupLocation'] ?? '';
    final subtitle = _type == 'printing' && location.isNotEmpty
        ? location
        : ProviderFormat.timeAgo(order['createdAt']);

    return Row(
      children: [
        Text(
          '#${order['orderNumber'] ?? ''}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Text(
            ' • $subtitle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        _statusBadge(),
      ],
    );
  }

  Widget _statusBadge() {
    final isPaid = order['paymentStatus'] == 'paid';

    switch (_status) {
      case 'pending':
        return _badge('طلب جديد', Icons.bolt, AppColors.secondary);
      case 'ready_for_pickup':
        return _badge('جاهز للاستلام', Icons.inventory_2_outlined, AppColors.secondary);
      case 'completed':
        return _badge('مكتمل', Icons.check_circle_outline, AppColors.success);
      case 'canceled':
        return _badge('ملغي', Icons.cancel_outlined, AppColors.error);
      default:
        return _badge(
          isPaid ? 'مؤكد ومسدد' : 'مؤكد',
          Icons.credit_card,
          AppColors.primary,
        );
    }
  }

  Widget _studentBox() {
    final String avatar = order['studentAvatar'] ?? '';
    final String name = order['studentName'] ?? '';
    final details = [
      order['studentMajor'],
      order['studentUniversity'],
      if (order['studentYear'] != null) 'سنة ${order['studentYear']}',
    ].where((item) => item != null && item.toString().isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.white,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? Text(
              name.length < 2 ? name : name.substring(0, 2),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (details.isNotEmpty)
                  Text(
                    details,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_serviceIcon, size: 16, color: _serviceColor),
                    const SizedBox(width: AppSizes.space4),
                    Expanded(
                      child: Text(
                        order['itemTitle'] ?? '',
                        style: TextStyle(fontSize: 12, color: _serviceColor),
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

  IconData get _serviceIcon {
    switch (_type) {
      case 'session':
        return Icons.person_outline;
      case 'printing':
        return Icons.menu_book_outlined;
      default:
        return Icons.code;
    }
  }

  Color get _serviceColor =>
      _type == 'printing' ? AppColors.textPrimary : AppColors.primary;

  List<Widget> _body(BuildContext context, bool isBusy) {
    switch (_status) {
      case 'pending':
        return _pendingBody(isBusy);
      case 'ready_for_pickup':
        return _pickupBody(isBusy);
      case 'confirmed':
      case 'in_progress':
        return _confirmedBody(context);
      default:
        return [_priceRow()];
    }
  }

  Widget _priceRow({String label = 'القيمة المستحقة', bool inline = false}) {
    final num discount = order['discountPercent'] ?? 0;
    final price = Text(
      ProviderFormat.price(order['totalPaidAmount']),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
    final labelText = Text(
      label,
      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        inline
            ? Row(children: [labelText, const SizedBox(width: AppSizes.space8), price])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [labelText, price]),
        const Spacer(),
        if (_status == 'ready_for_pickup' && order['paymentStatus'] == 'pay_on_arrival')
          _chip('الدفع عند الاستلام', AppColors.textSecondary, AppColors.border)
        else if (discount > 0)
          _chip(
            'خصم خطوتي الطلابي ${discount.round()}%',
            AppColors.success,
            AppColors.success.withValues(alpha: 0.15),
            icon: Icons.sell_outlined,
          ),
      ],
    );
  }

  List<Widget> _pendingBody(bool isBusy) {
    final String note = order['studentNote'] ?? '';

    return [
      _priceRow(),
      if (note.isNotEmpty) ...[
        const SizedBox(height: AppSizes.space16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(
                        text: 'ملاحظة الطالب: ',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      TextSpan(text: note),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: AppSizes.space16),
      _button(
        text: isBusy ? 'جاري القبول...' : 'قبول الحجز وتأكيد المقعد',
        icon: Icons.done_all,
        isMain: true,
        onTap: isBusy ? null : () => controller.acceptOrder(order),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _button(
              text: 'تواصل واتساب',
              icon: Icons.chat_outlined,
              iconColor: AppColors.success,
              onTap: () => controller.openWhatsapp(order),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _button(
              text: 'رفض / اعتذار',
              icon: Icons.close,
              background: AppColors.error.withValues(alpha: 0.12),
              foreground: AppColors.error,
              onTap: _confirmReject,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _confirmedBody(BuildContext context) {
    final appointment = _appointment;

    return [
      if (appointment != null)
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSizes.space8),
            Expanded(
              child: Text(
                ProviderFormat.appointment(appointment),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            _chip('جاهز للحضور', AppColors.success, AppColors.success.withValues(alpha: 0.15)),
          ],
        )
      else
        _priceRow(),
      const SizedBox(height: AppSizes.space16),
      Row(
        children: [
          Expanded(
            child: _button(
              text: 'إصدار تذكرة الحضور',
              icon: Icons.qr_code_2,
              isMain: true,
              onTap: _showTicket,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _button(
              text: 'تعديل الموعد',
              icon: Icons.edit_calendar_outlined,
              foreground: AppColors.textPrimary,
              onTap: () => _pickAppointment(context),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _pickupBody(bool isBusy) {
    return [
      _priceRow(label: 'المبلغ المطلوب:', inline: true),
      const SizedBox(height: AppSizes.space16),
      _button(
        text: 'تأكيد التسليم واستلام المبلغ',
        icon: Icons.qr_code_scanner,
        isMain: true,
        onTap: isBusy ? null : _confirmDelivery,
      ),
    ];
  }

  void _confirmReject() {
    showConfirmDialog(
      title: 'رفض الطلب',
      message: 'هل تريد رفض طلب ${order['studentName'] ?? ''}؟ سيتم إشعار الطالب بالاعتذار.',
      confirmText: 'رفض الطلب',
      icon: Icons.close,
      onConfirm: () => controller.rejectOrder(order),
    );
  }

  void _confirmDelivery() {
    showConfirmDialog(
      title: 'تأكيد التسليم',
      message: 'هل تم تسليم الطلب للطالب واستلام المبلغ؟',
      confirmText: 'تأكيد',
      icon: Icons.inventory_2_outlined,
      onConfirm: () => controller.confirmDelivery(order),
    );
  }

  Future<void> _pickAppointment(BuildContext context) async {
    final current = _appointment ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(DateTime.now()) ? DateTime.now() : current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;

    controller.changeAppointment(
      order,
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  void _showTicket() {
    final appointment = _appointment;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surfaceSubdued,
                child: Icon(Icons.confirmation_number_outlined, size: 30, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.space16),
              const Text(
                'تذكرة الحضور',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.space16),
              Text(
                '#${order['orderNumber'] ?? ''}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                order['studentName'] ?? '',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                order['itemTitle'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              if (appointment != null) ...[
                const SizedBox(height: AppSizes.space8),
                Text(
                  ProviderFormat.appointment(appointment),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: AppSizes.space24),
              _button(text: 'تم', isMain: true, onTap: () => Get.back()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button({
    required String text,
    IconData? icon,
    VoidCallback? onTap,
    bool isMain = false,
    Color? background,
    Color? foreground,
    Color? iconColor,
  }) {
    final bg = background ?? (isMain ? AppColors.primary : AppColors.surfaceSubdued);
    final fg = foreground ?? (isMain ? AppColors.white : AppColors.textPrimary);

    return SizedBox(
      width: double.infinity,
      height: isMain ? 48 : 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: isMain ? 4 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
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
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18, color: iconColor ?? fg),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppSizes.space4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color, Color background, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSizes.space4),
          ],
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final double amount;

  const _CollectionCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.space8),
              const Expanded(
                child: Text(
                  'مستحقات التحصيل اليوم',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'محفظة آمنة',
                  style: TextStyle(
                    fontSize: 10,
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
              const Expanded(
                child: Text(
                  'إجمالي المبالغ المستحقة للتحصيل:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              Text(
                '${ProviderFormat.number(amount, decimals: 2)} ₪',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.off(() => const ProviderProfileScreen()),
                child: const Row(
                  children: [
                    Text(
                      'عرض التقارير وسحب الأرباح',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'محدّث لحظيًا',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}