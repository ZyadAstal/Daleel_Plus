import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../academic/screens/job_details_screen.dart';
import '../../bookings/screens/my_orders_screen.dart';
import '../state/notifications_controller.dart';
import 'settings_screen.dart';
import '../../app_status/screens/system_error_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: ''),
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

        final groups = {
          'اليوم': controller.today,
          'هذا الأسبوع': controller.thisWeek,
          'أقدم': controller.older,
        };

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${controller.unreadCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'إشعارات غير مقروءة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: controller.unreadCount == 0
                      ? null
                      : controller.markAllRead,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'تحديد الكل كمقروء',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (controller.notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    'لا توجد إشعارات بعد',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            for (final group in groups.entries)
              if (group.value.isNotEmpty) ...[
                const SizedBox(height: AppSizes.space24),
                Row(
                  children: [
                    Text(
                      '● ${group.key}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      group.key == 'اليوم'
                          ? '${group.value.where((item) => item['isRead'] != true).length} تنبيهات جديدة'
                          : 'مقروءة سابقا',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...group.value.map(
                  (item) =>
                      _NotificationCard(controller: controller, item: item),
                ),
              ],
            const SizedBox(height: AppSizes.space16),
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعدادات الإشعارات والتنبيهات ⚙️',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'تحكم بنوع التنبيهات الفورية وقنوات الاستلام',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.white,
                        child: Icon(Icons.tune, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SettingTile(
                          text: 'تنبيهات SMS للطلبات',
                          value: controller.settings['notifySms'] ?? true,
                          onChanged: (value) =>
                              controller.toggleSetting('notifySms', value),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SettingTile(
                          text: 'تنبيهات المقابلات والوظائف',
                          value: controller.settings['notifyJobs'] ?? true,
                          onChanged: (value) =>
                              controller.toggleSetting('notifyJobs', value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Get.to(() => const SettingsScreen()),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تخصيص نغمات وأولويات الإشعارات',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 12,
              color: value ? AppColors.success : AppColors.textHint,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationsController controller;
  final Map<String, dynamic> item;

  const _NotificationCard({required this.controller, required this.item});

  static const Map<String, IconData> _icons = {
    'printing': Icons.print_outlined,
    'jobs': Icons.work_outline,
    'sessions': Icons.school_outlined,
    'offers': Icons.local_offer_outlined,
    'events': Icons.campaign_outlined,
  };

  static const Map<String, String> _categories = {
    'printing': 'خدمات الطباعة الأكاديمية',
    'jobs': 'فرص وتدريب مهني',
    'sessions': 'جلسات التدريس الخاص',
    'offers': 'عروض وخصومات خاصة',
    'events': 'فعاليات جامعية',
  };

  @override
  Widget build(BuildContext context) {
    final type = (item['type'] ?? 'events').toString();
    final color = type == 'jobs'
        ? AppColors.success
        : type == 'offers'
        ? AppColors.secondary
        : AppColors.primary;
    final isUnread = item['isRead'] != true;
    final code = (item['code'] ?? '').toString();
    final image = (item['imageUrl'] ?? '').toString();
    final attachment = (item['attachmentTitle'] ?? '').toString();

    final actions = <Widget>[];
    if (type == 'printing') {
      actions.add(
        _ActionButton(
          text: 'عرض تفاصيل الطلب والباركود',
          icon: Icons.arrow_forward,
          isPrimary: true,
          onTap: () => Get.to(() => const MyOrdersScreen()),
        ),
      );
    } else if (type == 'jobs') {
      if (item['actionDone'] == true) {
        actions.add(
          const _ActionButton(
            text: 'تم تأكيد الموعد ✓',
            color: AppColors.success,
          ),
        );
      } else {
        actions.add(
          _ActionButton(
            text: 'تأكيد موعد المقابلة',
            icon: Icons.event_available,
            color: AppColors.success,
            isPrimary: true,
            onTap: () => controller.confirmAction(item),
          ),
        );
        actions.add(
          _ActionButton(
            text: item['changeRequested'] == true
                ? 'تم طلب التعديل'
                : 'تعديل الموعد',
            onTap: item['changeRequested'] == true
                ? null
                : () => controller.requestChange(item),
          ),
        );
      }
      if ((item['jobId'] ?? '').toString().isNotEmpty) {
        actions.add(
          _ActionButton(
            text: 'تفاصيل الفرصة',
            onTap: () => JobDetailsScreen.open(item['jobId']),
          ),
        );
      }
    } else if (type == 'sessions' && item['eventAt'] != null) {
      actions.add(
        _ActionButton(
          text: 'إضافة إلى تقويم الهاتف',
          icon: Icons.calendar_today_outlined,
          isLink: true,
          onTap: () => controller.addToCalendar(item),
        ),
      );
    }

    return GestureDetector(
      onTap: () => controller.markRead(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space16),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              (item['category'] ?? _categories[type] ?? '')
                                  .toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color == AppColors.secondary
                                    ? AppColors.textPrimary
                                    : color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            NotificationsController.timeAgo(item),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 4),
                            const CircleAvatar(
                              radius: 4,
                              backgroundColor: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['body'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _icons[type],
                    color: color == AppColors.secondary
                        ? AppColors.textPrimary
                        : color,
                  ),
                ),
              ],
            ),
            if (attachment.isNotEmpty || code.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    if (image.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: 48, height: 48),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            code.isNotEmpty ? code : attachment,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if ((item['attachmentSubtitle'] ?? '')
                              .toString()
                              .isNotEmpty)
                            Text(
                              item['attachmentSubtitle'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (code.isNotEmpty)
                      GestureDetector(
                        onTap: () => controller.copyCode(code),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'نسخ الرمز',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    if (type == 'sessions' &&
                        (item['locationText'] ?? item['mapUrl']) != null)
                      GestureDetector(
                        onTap: () => controller.openMap(item),
                        child: const Text(
                          'عرض الخريطة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final bool isPrimary;
  final bool isLink;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.text,
    this.icon,
    this.color = AppColors.primary,
    this.isPrimary = false,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLink) {
      return GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? color : AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPrimary ? AppColors.white : AppColors.textSecondary,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 16,
                color: isPrimary ? AppColors.white : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
