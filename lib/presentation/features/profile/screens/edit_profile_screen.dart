import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/student_account_controller.dart';
import '../../app_status/screens/system_error_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  static void open() {
    final controller = StudentAccountController.instance;
    Get.to(() => const EditProfileScreen());
  }

  void _textDialog({
    required String title,
    required String hint,
    required ValueChanged<String> onDone,
  }) {
    final field = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: field,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              onDone(field.text);
              Get.back();
            },
            child: const Text(
              'إضافة',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(StudentAccountController controller) async {
    final success = await controller.saveProfile();
    if (!success) return;
    Get.back();
    Get.snackbar('تم الحفظ', 'تم تحديث بياناتك بنجاح');
  }

  @override
  Widget build(BuildContext context) {
    final controller = StudentAccountController.instance;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'تعديل الحساب'),
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

        final avatar = controller.avatarUrl.value;
        final completion = controller.completion;

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'اكتمال الملف الشخصي',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$completion%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          completion == 100
                              ? 'الملف موثق ومطابق لمنظومة الجامعة الإلكترونية'
                              : 'أكمل بياناتك للحصول على توصيات أدق',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: completion == 100
                        ? AppColors.success
                        : AppColors.surfaceSubdued,
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: completion == 100
                          ? AppColors.white
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child: Container(
                      width: 110,
                      height: 110,
                      color: AppColors.surfaceSubdued,
                      child: avatar.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 56,
                              color: AppColors.primary,
                            )
                          : Image.network(
                              avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 56,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: GestureDetector(
                      onTap: () => _textDialog(
                        title: 'تغيير الصورة الشخصية',
                        hint: 'رابط الصورة (https://...)',
                        onDone: controller.changeAvatar,
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.student['isVerified'] == true) ...[
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🎓 حساب طالب موثق',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            if (controller.lastUpdateText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Center(
                  child: Text(
                    controller.lastUpdateText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSizes.space16),
            _Section(
              icon: Icons.person_outline,
              title: 'البيانات الأساسية والشخصية',
              hint: 'عام ورسمي',
              children: [
                _Field(
                  label: 'الاسم الكامل',
                  controller: controller.nameController,
                  icon: Icons.badge_outlined,
                ),
                _Field(
                  label: 'البريد الإلكتروني الشخصي/ الجامعي',
                  value: controller.email,
                  icon: Icons.lock_outline,
                ),
                _Field(
                  label: 'رقم الجوال والواتساب',
                  controller: controller.phoneController,
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),
                _Field(
                  label: 'المدينة والمنطقة',
                  controller: controller.cityController,
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            _Section(
              icon: Icons.school_outlined,
              title: 'البيانات الأكاديمية والجامعية',
              hint: 'الجامعة والكلية',
              color: AppColors.secondary,
              children: [
                _Field(
                  label: 'الجامعة أو المؤسسة الأكاديمية',
                  controller: controller.universityController,
                  icon: Icons.account_balance_outlined,
                ),
                _Field(
                  label: 'الكلية والتخصص الأكاديمي',
                  controller: controller.majorController,
                  icon: Icons.apartment_outlined,
                ),
                _Field(
                  label: 'المستوى الدراسي وفصل التخرج',
                  controller: controller.yearController,
                  icon: Icons.calendar_month_outlined,
                ),
                _Field(
                  label: 'الرقم الجامعي الأكاديمي',
                  controller: controller.studentNumberController,
                  icon: Icons.pin_outlined,
                  keyboard: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            _Section(
              icon: Icons.hub_outlined,
              title: 'الروابط المهنية والاهتمامات',
              hint: 'فرص وتدريب',
              children: [
                _Field(
                  label: 'رابط معرض الأعمال أو GitHub',
                  controller: controller.portfolioController,
                  icon: Icons.code,
                  keyboard: TextInputType.url,
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'الاهتمامات الأكاديمية والمهنية',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'انقر للإزالة',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space8),
                Wrap(
                  spacing: AppSizes.space8,
                  runSpacing: AppSizes.space8,
                  children: [
                    ...controller.interests.asMap().entries.map((entry) {
                      final colors = [
                        AppColors.primary,
                        AppColors.secondary,
                        AppColors.success,
                        AppColors.textSecondary,
                      ];
                      final color = colors[entry.key % colors.length];
                      return GestureDetector(
                        onTap: () => controller.removeInterest(entry.value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.close,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () => _textDialog(
                        title: 'إضافة اهتمام',
                        hint: 'مثال: تطوير الويب',
                        onDone: controller.addInterest,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '+ إضافة اهتمام',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تحديث معلوماتك الأكاديمية يمكنك من استلام توصيات مخصصة للوظائف، التدريبات، والمنح الدراسية الشاغرة المتوافقة مع ملفك فور صدورها.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.space24,
          12,
          AppSizes.space24,
          AppSizes.space24,
        ),
        color: AppColors.white,
        child: Obx(
          () => GestureDetector(
            onTap: controller.isSaving.value ? null : () => _save(controller),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: controller.isSaving.value
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'حفظ التعديلات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.save_outlined, color: AppColors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final Color color;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.hint,
    required this.children,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                  icon,
                  size: 20,
                  color: color == AppColors.secondary
                      ? AppColors.textPrimary
                      : color,
                ),
              ),
              const SizedBox(width: 10),
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
                style: TextStyle(
                  fontSize: 11,
                  color: color == AppColors.secondary
                      ? AppColors.textPrimary
                      : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? value;
  final TextInputType keyboard;

  const _Field({
    required this.label,
    required this.icon,
    this.controller,
    this.value,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = controller == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: AppSizes.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isLocked
                      ? Text(
                          value ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : TextField(
                          controller: controller,
                          keyboardType: keyboard,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                ),
                Icon(icon, size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
