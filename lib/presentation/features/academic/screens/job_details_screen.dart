import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/job_details_controller.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/not_found_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  static void open(String jobId) {
    Get.to(() => JobDetailsScreen(jobId: jobId), preventDuplicates: false);
  }

  static const Map<String, IconData> _icons = {
    'school': Icons.school_outlined,
    'tools': Icons.design_services_outlined,
    'portfolio': Icons.folder_open_outlined,
    'team': Icons.forum_outlined,
    'power': Icons.bolt,
    'mentor': Icons.psychology_outlined,
    'award': Icons.workspace_premium_outlined,
  };

  void _openApplyDialog(JobDetailsController controller) {
    final cvController = TextEditingController(text: (controller.student['cvUrl'] ?? '').toString());
    final noteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'التقديم السريع',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cvController,
              decoration: const InputDecoration(hintText: 'رابط السيرة الذاتية CV (https://...)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'رسالة قصيرة للشركة (اختياري)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
          ),
          Obx(
                () => TextButton(
              onPressed: controller.isSending.value
                  ? null
                  : () async {
                final success = await controller.apply(
                  cvUrl: cvController.text,
                  note: noteController.text,
                );
                if (!success) return;
                Get.back();
                Get.snackbar('تم إرسال طلبك', 'ستصلك تحديثات حالة الطلب في الإشعارات');
              },
              child: const Text(
                'إرسال الطلب',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobDetailsController(jobId), tag: jobId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: StudentTopBar(
        title: 'تفاصيل الفرصة',
        actions: [
          Obx(
                () => IconButton(
              onPressed: controller.toggleFavorite,
              icon: Icon(
                controller.isFavorite.value ? Icons.bookmark : Icons.bookmark_border,
                color: controller.isFavorite.value ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_outline, color: AppColors.white, size: 18),
          ),
        ],
      ),
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

        if (controller.job.isEmpty) {
          return const NotFoundScreen();
        }

        final job = controller.job;
        final num reward = job['monthlyReward'] ?? 0;
        final num seats = job['seats'] ?? 0;
        final requirements = controller.listOf('requirements');
        final benefits = controller.listOf('benefits');
        final logo = controller.text('logoUrl');
        final isOpen = job['status'] == 'open';

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 52,
                          height: 52,
                          color: AppColors.surfaceSubdued,
                          child: logo.isEmpty
                              ? const Icon(Icons.business_outlined, color: AppColors.primary)
                              : Image.network(
                            logo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.business_outlined, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    controller.text('companyName'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (job['isVerified'] == true) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 16, color: AppColors.success),
                                ],
                              ],
                            ),
                            if (controller.text('companyNameEn').isNotEmpty)
                              Text(
                                controller.text('companyNameEn'),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      _Pill(
                        text: isOpen ? 'نشطة ومتاحة' : 'مغلقة',
                        color: isOpen ? AppColors.success : AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.text('title'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  if (controller.text('address').isNotEmpty || controller.text('location').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            controller.text('address').isEmpty ? controller.text('location') : controller.text('address'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (controller.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.tags.asMap().entries.map((entry) {
                        final colors = [AppColors.success, AppColors.primary, AppColors.secondary];
                        return _Pill(text: entry.value, color: colors[entry.key % colors.length]);
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _StatCard(
                  icon: Icons.payments_outlined,
                  color: AppColors.success,
                  label: 'المكافأة الشهرية',
                  value: reward > 0 ? '${JobDetailsController.money(reward)} ₪ / شهر' : 'تطوعية',
                ),
                _StatCard(
                  icon: Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  label: 'مدة البرنامج',
                  value: controller.text('durationLabel').isEmpty ? '-' : controller.text('durationLabel'),
                  valueColor: AppColors.textPrimary,
                ),
                _StatCard(
                  icon: Icons.hourglass_bottom,
                  color: AppColors.secondary,
                  label: 'انتهاء التقديم',
                  value: controller.deadlineText,
                ),
                _StatCard(
                  icon: Icons.groups_outlined,
                  color: AppColors.primary,
                  label: 'عدد المقاعد',
                  value: seats > 0 ? '$seats متدربين فقط' : 'غير محدد',
                ),
              ],
            ),
            if (controller.text('description').isNotEmpty) ...[
              const SizedBox(height: AppSizes.space16),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Title(text: 'نبذة عن فرصة التدريب', color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      controller.text('description'),
                      style: const TextStyle(fontSize: 13, height: 1.8, color: AppColors.textSecondary),
                    ),
                    if (controller.text('highlightTitle').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.rocket_launch_outlined, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.text('highlightTitle'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    controller.text('highlightSubtitle'),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (requirements.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space16),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Title(text: 'الشروط والمتطلبات الأكاديمية', color: AppColors.primary),
                    const SizedBox(height: 12),
                    ...requirements.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(_icons[item['icon']] ?? Icons.check, size: 16, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    item['details'] ?? '',
                                    style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (benefits.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space16),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Title(text: 'المزايا والحوافز المقدمة للطالب', color: AppColors.success),
                    const SizedBox(height: 12),
                    ...benefits.asMap().entries.map((entry) {
                      final colors = [AppColors.success, AppColors.primary, AppColors.secondary];
                      final color = colors[entry.key % colors.length];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                              child: Icon(_icons[entry.value['icon']] ?? Icons.star_outline, color: AppColors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value['title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    entry.value['details'] ?? '',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            if (controller.text('address').isNotEmpty) ...[
              const SizedBox(height: AppSizes.space16),
              const Text(
                'موقع الجهة التفصيلي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': controller.text('address')}),
                  mode: LaunchMode.externalApplication,
                ),
                child: _Card(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          controller.text('address'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.map_outlined, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.space24, 12, AppSizes.space24, AppSizes.space24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
          ],
        ),
        child: Obx(() {
          final applied = controller.myApplication.value != null;
          final isOpen = controller.job['status'] == 'open';
          final canApply = !applied && isOpen;
          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: canApply ? () => _openApplyDialog(controller) : null,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: applied ? AppColors.success : (canApply ? AppColors.primary : AppColors.textHint),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          applied ? Icons.check_circle_outline : Icons.upload_file_outlined,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          applied
                              ? 'تم إرسال طلبك (قيد المراجعة)'
                              : isOpen
                              ? 'التقديم السريع الآن (إرفاق CV)'
                              : 'انتهى التقديم',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: controller.toggleFavorite,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(color: AppColors.surfaceSubdued, shape: BoxShape.circle),
                  child: Icon(
                    controller.isFavorite.value ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.primary,
                  ),
                ),
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

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  final Color color;

  const _Title({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: AppSizes.space8),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.valueColor,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: valueColor ?? color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}