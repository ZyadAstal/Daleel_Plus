import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/student_account_controller.dart';
import '../../app_status/screens/system_error_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _pickSheet({
    required String title,
    required Map<String, String> options,
    required String selected,
    required ValueChanged<String> onPick,
    List<String> disabled = const [],
  }) {
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
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...options.entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value),
                subtitle: disabled.contains(entry.key)
                    ? const Text('قريبًا')
                    : null,
                enabled: !disabled.contains(entry.key),
                trailing: selected == entry.key
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  onPick(entry.key);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text(
              'تأكيد',
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
      appBar: const StudentTopBar(title: 'الإعدادات و الخصوصية'),
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
        final branch = (controller.settings['defaultBranch'] ?? 'gaza')
            .toString();

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            _Card(
              padding: const EdgeInsets.all(AppSizes.space16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.surfaceSubdued,
                      backgroundImage: avatar.isEmpty
                          ? null
                          : NetworkImage(avatar),
                      child: avatar.isEmpty
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.text('name'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            [
                              controller.major,
                              'طالب',
                            ].where((t) => t.isNotEmpty).join(' • '),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            controller.email,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const _Title(icon: Icons.tune, title: 'تفضيلات الحساب والمظهر'),
            _Card(
              children: [
                _Row(
                  icon: Icons.language,
                  title: 'اللغة (Language)',
                  subtitle: 'تخصيص واجهة التطبيق والتنبيهات',
                  trailing: const _Chip(text: 'العربية'),
                  onTap: () => _pickSheet(
                    title: 'اللغة',
                    options: const {'ar': 'العربية', 'en': 'English'},
                    selected: 'ar',
                    disabled: const ['en'],
                    onPick: (_) {},
                  ),
                ),
                _Row(
                  icon: Icons.light_mode_outlined,
                  iconColor: AppColors.secondary,
                  title: 'المظهر والشاشة',
                  subtitle: 'الوضع الليلي سيتوفر في تحديث قادم',
                  trailing: Switch(
                    value: controller.setting('darkMode', fallback: false),
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) =>
                        controller.updateSetting('darkMode', value),
                  ),
                ),
                _Row(
                  icon: Icons.account_balance_outlined,
                  iconColor: AppColors.success,
                  title: 'الجامعة والفرع الافتراضي',
                  subtitle: 'تخصيص العروض بناءً على جامعتك',
                  trailing: Text(
                    StudentAccountController.branches[branch] ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  onTap: () => _pickSheet(
                    title: 'الفرع الافتراضي',
                    options: StudentAccountController.branches,
                    selected: branch,
                    onPick: (value) =>
                        controller.updateSetting('defaultBranch', value),
                  ),
                ),
              ],
            ),
            const _Title(
              icon: Icons.notifications_active_outlined,
              title: 'الإشعارات والتنبيهات',
              color: AppColors.secondary,
            ),
            _Card(
              children: [
                _SwitchRow(
                  controller: controller,
                  keyName: 'notifyPrinting',
                  icon: Icons.print_outlined,
                  color: AppColors.secondary,
                  title: 'جاهزية طلبات الطباعة والملازم',
                  subtitle: 'إشعار فوري عند اكتمال طباعة ملخصاتك',
                  activeColor: AppColors.success,
                ),
                _SwitchRow(
                  controller: controller,
                  keyName: 'notifyOffers',
                  icon: Icons.local_offer_outlined,
                  color: AppColors.primary,
                  title: 'عروض وتخفيضات الدورات الجديدة',
                  subtitle: 'تخفيضات مراكز التدريب والورش المتخصصة',
                ),
                _SwitchRow(
                  controller: controller,
                  keyName: 'notifySms',
                  icon: Icons.sms_outlined,
                  color: AppColors.primary,
                  title: 'تذكير المواعيد عبر رسائل SMS',
                  subtitle: 'تذكير بمواعيد الدروس الخصوصية قبل ساعتين',
                ),
                _SwitchRow(
                  controller: controller,
                  keyName: 'notifyJobs',
                  icon: Icons.work_outline,
                  color: AppColors.success,
                  title: 'فرص العمل والتدريب الشاغرة',
                  subtitle: 'مطابقات التدريب العملي والمنح لطلاب غزة',
                ),
              ],
            ),
            const _Title(
              icon: Icons.shield_outlined,
              title: 'الخصوصية والأمان',
            ),
            _Card(
              children: [
                _Row(
                  icon: Icons.lock_reset,
                  title: 'تغيير كلمة المرور',
                  subtitle: 'سنرسل رابط التغيير إلى بريدك',
                  onTap: controller.resetPassword,
                ),
                _SwitchRow(
                  controller: controller,
                  keyName: 'twoFactor',
                  icon: Icons.mark_chat_read_outlined,
                  color: AppColors.success,
                  title: 'التحقق بخطوتين عبر الواتساب',
                  subtitle: 'رمز أمان فوري إلى رقم جوالك',
                  fallback: false,
                  activeColor: AppColors.success,
                ),
                _Row(
                  icon: Icons.devices_outlined,
                  title: 'إدارة الأجهزة النشطة والجلسات',
                  subtitle: 'هذا الجهاز (نشط الآن)',
                  trailing: const _Chip(text: '● 1 جهاز'),
                  onTap: () => Get.snackbar(
                    'الأجهزة النشطة',
                    'أنت مسجل الدخول من هذا الجهاز فقط حاليًا',
                  ),
                ),
                _SwitchRow(
                  controller: controller,
                  keyName: 'profileVisible',
                  icon: Icons.visibility_outlined,
                  color: AppColors.primary,
                  title: 'إظهار الملف الأكاديمي للشركات والمدرسين',
                  subtitle: 'السماح بتلقي عروض عمل أكاديمية وتوصيات',
                ),
              ],
            ),
            const _Title(
              icon: Icons.storage_outlined,
              title: 'النظام والبيانات',
            ),
            _Card(
              children: [
                _Row(
                  icon: Icons.cleaning_services_outlined,
                  title: 'مسح الذاكرة المؤقتة',
                  subtitle: 'تشمل الصور والمعاينات المحفوظة مؤقتًا',
                  trailing: const _Chip(text: 'مسح الآن'),
                  onTap: () {
                    PaintingBinding.instance.imageCache.clear();
                    Get.snackbar('تم', 'تم مسح الذاكرة المؤقتة للصور');
                  },
                ),
                _Row(
                  icon: Icons.download_outlined,
                  title: 'تنزيل نسخة من البيانات والملفات',
                  subtitle: 'تصدير تاريخ الطلبات والملازم الأكاديمية',
                  // TODO: تصدير البيانات بعد إضافة باكج pdf أو csv
                  onTap: () =>
                      Get.snackbar('قريبًا', 'تصدير البيانات سيتوفر قريبًا'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.success,
                    child: Icon(Icons.verified_user, color: AppColors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حسابك الأكاديمي محمي بالكامل',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'بياناتك وجلساتك مشفرة ومحفوظة بأمان.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            GestureDetector(
              onTap: () => _confirm(
                title: 'تسجيل الخروج',
                message: 'هل تريد تسجيل الخروج من حسابك؟',
                onConfirm: controller.logout,
              ),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تسجيل الخروج من الحساب',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.logout, color: AppColors.error),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _confirm(
                  title: 'حذف الحساب',
                  message: 'سيتم إرسال طلب لحذف حسابك وكل بياناتك نهائيًا. هل أنت متأكد؟',
                  onConfirm: controller.requestAccountDeletion,
                ),
                child: Text(
                  controller.student['deletionRequested'] == true
                      ? 'تم إرسال طلب حذف الحساب'
                      : 'تعطيل أو حذف الحساب نهائيًا',
                  style: const TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ),
            ),
            const Center(
              child: Text(
                'v2.4.0 • خوادم مؤمنة',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const _Card({
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
      child: Column(children: children),
    );
  }
}

class _Title extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _Title({
    required this.icon,
    required this.title,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.space24, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.primary,
    this.trailing,
    this.onTap,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final StudentAccountController controller;
  final String keyName;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool fallback;
  final Color activeColor;

  const _SwitchRow({
    required this.controller,
    required this.keyName,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.fallback = true,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return _Row(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: controller.setting(keyName, fallback: fallback),
        activeColor: AppColors.white,
        activeTrackColor: activeColor,
        onChanged: (value) => controller.updateSetting(keyName, value),
      ),
    );
  }
}
