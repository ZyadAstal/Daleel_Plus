import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../state/provider_helpers.dart';
import '../state/provider_notifications_controller.dart';
import '../state/provider_requests_controller.dart';
import '../widgets/provider_top_bar.dart';
import 'provider_requests_screen.dart';

class ProviderNotificationsScreen extends StatelessWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = providerNotifications();
    // بنحفظ آخر مرة شاف فيها الإشعارات، وبعد ما تنفتح الصفحة بنعتبر الكل مقروء
    controller.seenBeforeOpen = controller.seenAt.value;
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.markAllSeen());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const ProviderTopBar(title: 'الإشعارات'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.items;
        if (items.isEmpty) {
          return const Center(
            child: Text('لا توجد إشعارات حتى الآن', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: items
              .map((item) => _NotificationTile(
                    item: item,
                    isUnread: controller.isUnread(item, controller.seenBeforeOpen),
                  ))
              .toList(),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isUnread;

  const _NotificationTile({required this.item, required this.isUnread});

  bool get _isReview => item['kind'] == 'review';

  bool get _isNew => !_isReview && item['orderStatus'] == 'pending';

  String get _title {
    if (_isReview) return 'تقييم جديد ⭐ ${item['rating'] ?? ''}';
    if (_isNew) return 'طلب حجز جديد';
    return 'طلب #${item['orderNumber'] ?? ''} · ${ProviderFormat.orderStatus(item['orderStatus'])}';
  }

  String get _body {
    if (_isReview) {
      final comment = (item['comment'] ?? '').toString();
      return comment.isEmpty ? 'تقييم بدون تعليق' : comment;
    }
    final String name = (item['studentName'] ?? '').toString();
    return '${name.isEmpty ? 'طالب' : name}: ${item['itemTitle'] ?? ''}';
  }

  void _open() {
    if (_isReview) return;
    final status = item['orderStatus'];
    var filter = RequestFilter.active;
    if (status == 'pending') filter = RequestFilter.pending;
    if (status == 'completed') filter = RequestFilter.completed;
    if (status == 'canceled') filter = RequestFilter.canceled;
    ProviderRequestsScreen.open(filter: filter, search: (item['orderNumber'] ?? '').toString());
  }

  @override
  Widget build(BuildContext context) {
    final color = _isReview ? AppColors.secondary : AppColors.primary;
    final time = (item['updatedAt'] ?? item['createdAt']) as Timestamp?;

    return GestureDetector(
      onTap: _open,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.surfaceSubdued : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(_isReview ? Icons.star_rounded : Icons.inbox_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    _body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ProviderFormat.timeAgo(time),
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            if (isUnread)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: CircleAvatar(radius: 4, backgroundColor: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}
