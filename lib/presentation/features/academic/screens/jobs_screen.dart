import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../discovery/screens/filter_screen.dart';
import '../../discovery/state/search_controller.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../state/jobs_controller.dart';
import 'job_details_screen.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/empty_state_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  static const Map<String, String> _applicationStatus = {
    'submitted': 'قيد المراجعة',
    'interview': 'مدعو لمقابلة',
    'accepted': 'مقبول',
    'rejected': 'لم يتم القبول',
  };

  void _openFilter() {
    DiscoverySearchController.instance.changeCategory('job');
    Get.to(() => const FilterScreen());
  }

  void _showApplications(JobsController controller) {
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
            const Text(
              'طلباتي المقدمة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            if (controller.applications.isEmpty)
              const Text('لم تتقدم لأي فرصة بعد', style: TextStyle(color: AppColors.textSecondary)),
            ...controller.applications.map(
                  (application) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.work_outline, color: AppColors.primary),
                title: Text(
                  application['jobTitle'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(application['companyName'] ?? '', style: const TextStyle(fontSize: 12)),
                trailing: Text(
                  _applicationStatus[application['status']] ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success),
                ),
                onTap: () {
                  Get.back();
                  JobDetailsScreen.open(application['jobId']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'التدريبات و الوظائف'),
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

        final jobs = controller.jobs;
        final applied = controller.appliedJobIds;

        if (jobs.isEmpty && controller.searchText.value.trim().isNotEmpty) {
          return EmptyStateScreen(
            searchTerm: controller.searchText.value.trim(),
            onClearSearch: () => controller.changeSearch(''),
            onResetFilters: () => controller.changeSearch(''),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            GestureDetector(
              onTap: () => _showApplications(controller),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.space16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: const Icon(Icons.assignment_ind_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'طلباتي المقدمة',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (controller.pendingApplications > 0)
                                _Chip(
                                  text: '${controller.pendingApplications} قيد المراجعة',
                                  color: AppColors.success,
                                ),
                            ],
                          ),
                          Text(
                            controller.applications.isEmpty ? 'لم تتقدم لأي فرصة بعد' : controller.applicationsText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.white,
                      child: Icon(Icons.chevron_right, size: 20, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                    decoration: _cardDecoration(radius: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: AppSizes.space8),
                        Expanded(
                          child: TextField(
                            onChanged: controller.changeSearch,
                            decoration: const InputDecoration(
                              hintText: 'ابحث عن وظيفة، تدريب، أو تطوع...',
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
                  onTap: _openFilter,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.tune, color: AppColors.white),
                  ),
                ),
              ],
            ),
            if (controller.major.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'فرص موصى بها لطلاب ${controller.major}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: EditProfileScreen.open,
                      child: const Text(
                        'تعديل',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.space24),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'أحدث الفرص المعلنة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                Text('محدث اليوم', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            if (jobs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.space24),
                child: Center(
                  child: Text('لا توجد فرص مطابقة حاليًا', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ...jobs.map(
                  (job) => _JobCard(
                job: job,
                isSaved: controller.favoriteIds.contains(job['id']),
                isApplied: applied.contains(job['id']),
                onSave: () => controller.toggleFavorite(job['id']),
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                    child: const Icon(Icons.lightbulb_outline, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نصيحة دليل+ المهنية',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          'قم بإرفاق رابط أعمالك على GitHub أو Behance لزيادة فرصة قبولك بنسبة 60%.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }
}

BoxDecoration _cardDecoration({double radius = 20}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Chip({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isSaved;
  final bool isApplied;
  final VoidCallback onSave;

  const _JobCard({required this.job, required this.isSaved, required this.isApplied, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final logo = (job['logoUrl'] ?? '').toString();
    final num reward = job['monthlyReward'] ?? 0;
    final days = JobsController.daysLeft(job['deadline']);
    final workType = (job['workTypeLabel'] ?? '').toString();
    final note = (job['requirementNote'] ?? '').toString();

    return GestureDetector(
      onTap: () => JobDetailsScreen.open(job['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space16),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      errorBuilder: (_, __, ___) => const Icon(Icons.business_outlined, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? '',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(job['companyName'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onSave,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.surfaceSubdued,
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (reward > 0)
                  _Chip(
                    text: 'مكافأة ${JobsController.money(reward)} ₪',
                    color: AppColors.success,
                    icon: Icons.payments_outlined,
                  ),
                if (workType.isNotEmpty) _Chip(text: workType, color: AppColors.primary, icon: Icons.work_outline),
                if (days > 0) _Chip(text: 'متبقي $days أيام', color: AppColors.textSecondary, icon: Icons.schedule),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (note.isNotEmpty) ...[
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ] else
                  const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isApplied ? AppColors.success : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isApplied ? 'تم التقديم ✓' : 'قدم الآن',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}