import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_bottom_nav.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../../bookings/screens/my_orders_screen.dart';
import '../../bookings/screens/saved_screen.dart';
import '../../bookings/state/my_orders_controller.dart';
import '../../support/screens/help_center_screen.dart';
import '../state/student_account_controller.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../../app_status/screens/system_error_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _showPoints(StudentAccountController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars_rounded,
              size: 48,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            Text(
              'رصيدك: ${controller.student['points'] ?? 0} نقطة',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'تجمع النقاط مع كل طلب مكتمل وتقييم، واستبدالها بخصومات سيتوفر قريبًا.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerms() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الشروط وسياسة الخصوصية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12),
            Text(
              '• تُستخدم بياناتك فقط لتقديم الخدمات الأكاديمية داخل دليل+.\n'
              '• لا تتم مشاركة بياناتك مع أي طرف دون موافقتك.\n'
              '• يمكنك طلب حذف حسابك وبياناتك في أي وقت من الإعدادات.\n'
              '• تخضع الحجوزات لسياسة الإلغاء الخاصة بكل مزود خدمة.',
              style: TextStyle(
                fontSize: 13,
                height: 1.8,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(StudentAccountController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = StudentAccountController.instance;

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

        final avatar = controller.text('avatarUrl');
        final points = controller.student['points'] ?? 0;

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 72,
                              height: 72,
                              color: AppColors.surfaceSubdued,
                              child: avatar.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 36,
                                      color: AppColors.primary,
                                    )
                                  : Image.network(
                                      avatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 36,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                          if (controller.student['isVerified'] == true)
                            const PositionedDirectional(
                              bottom: 0,
                              end: 0,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.success,
                                child: Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.text('name'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (controller.student['isVerified'] == true)
                              const Text(
                                '🎓 حساب طالب موثق',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            if (controller.text('city').isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    controller.text('city'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: EditProfileScreen.open,
                        icon: const Icon(
                          Icons.edit_note,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (controller.text('university').isNotEmpty) ...[
                    const SizedBox(height: AppSizes.space16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.space16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.apartment,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.text('university'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.major,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (controller.text('studyYear').isNotEmpty)
                                Expanded(
                                  child: Text(
                                    '● ${controller.text('studyYear')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              if (controller.text('gpa').isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'معدل ${controller.text('gpa')}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            Row(
              children: [
                _StatCard(
                  icon: Icons.task_alt,
                  color: AppColors.primary,
                  value: '${controller.completedOrders.value}',
                  label: 'طلب وحجز مكتمل',
                  onTap: () => Get.to(
                    () => const MyOrdersScreen(initialTab: OrdersTab.completed),
                  ),
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.stars_rounded,
                  color: AppColors.secondary,
                  value: '$points',
                  label: 'نقطة تفوق وخصم',
                  onTap: () => _showPoints(controller),
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.favorite,
                  color: AppColors.error,
                  value: '${controller.favoritesCount.value}',
                  label: 'عنصر بالمفضلة',
                  onTap: () => Get.off(() => const SavedScreen()),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            _SectionTitle(
              title: 'الحساب والأكاديميا',
              hint: 'الملف الطلابي',
              color: AppColors.primary,
            ),
            _MenuCard(
              children: [
                _MenuRow(
                  icon: Icons.manage_accounts_outlined,
                  title: 'تعديل البيانات الشخصية والأكاديمية',
                  subtitle: 'الاسم، الجامعة، التخصص، وسنة التخرج',
                  onTap: EditProfileScreen.open,
                ),
                _MenuRow(
                  icon: Icons.terminal,
                  title: 'تعديل الاهتمامات و المهارات',
                  subtitle: 'مشاريع هندسة البرمجيات، تصميم، GitHub',
                  onTap: EditProfileScreen.open,
                ),
                _MenuRow(
                  icon: Icons.workspace_premium_outlined,
                  title: 'شهاداتي والدورات المعتمدة',
                  subtitle: 'سجل الشهادات الأكاديمية والمهنية الموثقة',
                  onTap: () => Get.to(
                    () => const MyOrdersScreen(initialTab: OrdersTab.completed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            _SectionTitle(
              title: 'المعاملات والمحفظة',
              hint: 'المدفوعات والمكافآت',
              color: AppColors.secondary,
            ),
            _MenuCard(
              children: [
                _MenuRow(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.secondary,
                  title: 'محفظة الطالب ونقاط الخصم',
                  subtitle: 'استبدل النقاط بخصومات للمكتبات والدورات',
                  badge: '$points نقطة',
                  onTap: () => _showPoints(controller),
                ),
                _MenuRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'سجل الفواتير والدفعات',
                  subtitle: 'إيصالات حجز الدروس، السكن، وخدمات الطباعة',
                  onTap: () => Get.to(
                    () => const MyOrdersScreen(initialTab: OrdersTab.completed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            _SectionTitle(
              title: 'الإعدادات والدعم',
              hint: 'الخصوصية والمساعدة',
              color: AppColors.success,
            ),
            _MenuCard(
              children: [
                _MenuRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'تنبيهات وإشعارات التطبيق',
                  subtitle: 'إشعارات الحجوزات، العروض، وأخبار الجامعة',
                  onTap: () => Get.to(() => const SettingsScreen()),
                ),
                _MenuRow(
                  icon: Icons.lock_reset,
                  title: 'الأمان وكلمة المرور',
                  subtitle: 'تحديث كلمة السر والتحقق بخطوتين',
                  onTap: () => Get.to(() => const SettingsScreen()),
                ),
                _MenuRow(
                  icon: Icons.support_agent,
                  iconColor: AppColors.success,
                  title: 'مساعدة ودعم الطلاب',
                  subtitle: 'مساعدة فورية طوال أيام الأسبوع',
                  badge: 'WhatsApp',
                  onTap: () => Get.to(() => const HelpCenterScreen()),
                ),
                _MenuRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'الشروط وسياسة الخصوصية',
                  subtitle: 'اتفاقية استخدام منصة دليل+',
                  onTap: _showTerms,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            Center(
              child: TextButton.icon(
                onPressed: () => _confirmLogout(controller),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'تسجيل الخروج من الحساب',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            const Center(
              child: Text(
                'إصدار التطبيق 2.4.0',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const Center(
              child: Text(
                'جميع الحقوق محفوظة لمنصة دليل+ © 2026',
                style: TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 4),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color == AppColors.secondary
                      ? AppColors.textPrimary
                      : color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String hint;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: _cardDecoration(),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor == AppColors.secondary
                    ? AppColors.textPrimary
                    : iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                margin: const EdgeInsetsDirectional.only(start: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
