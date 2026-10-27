import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import '../../providers/state/provider_helpers.dart';

class OrderStatusDialog extends StatelessWidget {
  final String orderId;

  const OrderStatusDialog({super.key, required this.orderId});

  static const List<String> _steps = [
    'تم إرسال الطلب',
    'قبول المكتبة للطلب',
    'جاهز للاستلام',
    'تم التسليم',
  ];

  int _currentStep(String status) {
    switch (status) {
      case 'confirmed':
      case 'in_progress':
        return 1;
      case 'ready_for_pickup':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'confirmed':
      case 'in_progress':
        return 'قبلت المكتبة طلبك وجاري تجهيزه الآن';
      case 'ready_for_pickup':
        return 'طلبك جاهز، يمكنك استلامه الآن';
      case 'completed':
        return 'تم تسليم الطلب بنجاح';
      case 'canceled':
        return 'اعتذرت المكتبة عن تنفيذ الطلب';
      default:
        return 'بانتظار قبول المكتبة لطلبك';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          final order = snapshot.data?.data() ?? {};
          final String status = order['orderStatus'] ?? 'pending';
          final isCanceled = status == 'canceled';
          final color = isCanceled ? AppColors.error : AppColors.success;

          return Padding(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(
                    isCanceled ? Icons.cancel_outlined : Icons.check_circle_outline,
                    color: color,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSizes.space16),
                Text(
                  isCanceled ? 'تم إلغاء الطلب' : 'تم إرسال طلب الطباعة',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  _statusMessage(status),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSizes.space16),
                _OrderSummary(order: order),
                if (!isCanceled) ...[
                  const SizedBox(height: AppSizes.space16),
                  _StatusSteps(steps: _steps, currentStep: _currentStep(status)),
                ],
                const SizedBox(height: AppSizes.space16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sync, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: AppSizes.space4),
                    Text(
                      'يتم تحديث حالة الطلب مباشرة',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space16),
                AppPrimaryButton(text: 'تم', onPressed: () => Get.back()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row('رقم الطلب', '#${order['orderNumber'] ?? ''}', isBold: true),
          _row('مكان الاستلام', order['pickupLocation'] ?? ''),
          _row('طريقة الدفع', 'عند الاستلام'),
          _row(
            'المبلغ المستحق',
            '${ProviderFormat.number((order['totalPaidAmount'] ?? 0).toDouble(), decimals: 2)} ₪',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: AppSizes.space8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: isBold ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSteps extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const _StatusSteps({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentStep;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: isDone ? AppColors.primary : AppColors.border,
                  child: Icon(
                    isDone ? Icons.check : Icons.circle,
                    size: isDone ? 14 : 6,
                    color: AppColors.white,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 18,
                    color: index < currentStep ? AppColors.primary : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                steps[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: index == currentStep ? FontWeight.w700 : FontWeight.w500,
                  color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}