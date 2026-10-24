import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/add_service_controller.dart';
import '../state/provider_helpers.dart';
import '../widgets/add_service_form.dart';
import '../widgets/add_service_steps.dart';
import '../widgets/provider_top_bar.dart';
import 'add_service_schedule_screen.dart';

class AddServiceBasicScreen extends StatelessWidget {
  const AddServiceBasicScreen({super.key});

  static void open({Map<String, dynamic>? course}) {
    Get.delete<AddServiceController>(force: true);
    Get.put(AddServiceController(editingCourse: course));
    Get.to(() => const AddServiceBasicScreen());
  }

  void _next(AddServiceController controller) {
    final error = controller.validateBasicInfo();
    if (error != null) {
      Get.snackbar('تنبيه', error);
      return;
    }
    Get.to(() => const AddServiceScheduleScreen());
  }

  Future<void> _saveDraft(AddServiceController controller) async {
    if (controller.titleController.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'اكتب عنوان الخدمة على الأقل لحفظها كمسودة');
      return;
    }
    final saved = await controller.save(publish: false);
    if (saved) Get.close(1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddServiceController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: ProviderTopBar(
        title: controller.isEditing ? 'تعديل الخدمة' : 'إضافة خدمة جديدة',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddServiceSteps(
              currentStep: 1,
              title: 'البيانات الأساسية',
              onClose: () => confirmCloseAddService(1),
            ),
            const SizedBox(height: AppSizes.space24),
            const Text(
              'إضافة خدمة أو دورة جديدة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSizes.space4),
            const Text(
              'املأ تفاصيل الخدمة لتظهر فورًا لآلاف الطلبة في قطاع غزة والضفة',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.space24),
            _ServiceTypeGrid(controller: controller),
            const SizedBox(height: AppSizes.space24),
            _ContentSection(controller: controller),
            _PricingSection(controller: controller),
            _AttendanceSection(controller: controller),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 16, color: AppColors.success),
                SizedBox(width: AppSizes.space8),
                Flexible(
                  child: Text(
                    'سيتم تدقيق ومراجعة البيانات خلال ساعتين لضمان معايير الجودة',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            AppPrimaryButton(
              text: 'حفظ ومتابعة للخطوة التالية',
              icon: Icons.arrow_forward,
              onPressed: () => _next(controller),
            ),
            const SizedBox(height: AppSizes.space8),
            Center(
              child: Obx(
                    () => TextButton(
                  onPressed: controller.isSaving.value ? null : () => _saveDraft(controller),
                  child: Text(
                    controller.isSaving.value ? 'جاري الحفظ...' : 'حفظ كمسودة والرجوع لاحقًا',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTypeGrid extends StatelessWidget {
  final AddServiceController controller;

  const _ServiceTypeGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormLabel(
          'نوع الخدمة والمسار الأكاديمي',
          isRequired: true,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'ركائز خطوتي',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.space8),
        Obx(
              () => Column(
            children: [
              Row(
                children: [
                  _typeCard(
                    type: 'course',
                    title: 'دورات وتعليم',
                    subtitle: 'معسكرات، دبلومات وكورسات',
                    icon: Icons.school_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _typeCard(
                    type: 'job',
                    title: 'وظائف وتدريب',
                    subtitle: 'فرص تدريب عملي وشواغر',
                    icon: Icons.work_outline,
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _typeCard(
                    type: 'printing',
                    title: 'خدمات طباعة',
                    subtitle: 'تصوير، أبحاث وملازم',
                    icon: Icons.print_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  _typeCard(
                    type: 'private_lesson',
                    title: 'دروس خصوصية',
                    subtitle: 'مساقات جامعية فردية وجماعية',
                    icon: Icons.record_voice_over_outlined,
                    color: AppColors.primary,
                    isLight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isLight = false,
  }) {
    final isSelected = controller.serviceType.value == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.serviceType.value = type,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.space16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceSubdued : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLight ? color.withValues(alpha: 0.12) : color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: isLight ? color : AppColors.white),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: AppColors.white)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final AddServiceController controller;

  const _ContentSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: Icons.edit_note,
      title: 'بيانات ومحتوى الخدمة',
      children: [
        const FormLabel('عنوان الخدمة أو الدورة', isRequired: true),
        FormInput(
          controller: controller.titleController,
          hint: 'مثلًا: دبلوم تطوير تطبيقات الهاتف باستخدام Flutter',
          icon: Icons.title,
        ),
        const SizedBox(height: AppSizes.space16),
        const FormLabel('التصنيف التخصصي الدقيق', isRequired: true),
        Obx(
              () => Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.category.value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                items: AddServiceController.categories.keys
                    .map(
                      (name) => DropdownMenuItem(
                    value: name,
                    child: Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(name),
                      ],
                    ),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) controller.category.value = value;
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        const FormLabel(
          'وصف المحتوى ومخرجات الدورة',
          isRequired: true,
          trailing: Text(
            'الحد الأدنى 4 أسطر',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ),
        FormInput(
          controller: controller.descriptionController,
          hint: 'اكتب ما سيتعلمه الطالب، المهارات المكتسبة، والمشاريع العملية المطبقة خلال فترة البرنامج التدريبي بالتفصيل...',
          maxLines: 4,
        ),
        const SizedBox(height: AppSizes.space16),
        const FormLabel('صورة غلاف الخدمة أو المعاينة (اختياري)'),
        _CoverPicker(controller: controller),
      ],
    );
  }
}

class _CoverPicker extends StatelessWidget {
  final AddServiceController controller;

  const _CoverPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = controller.coverImageUrl.value;

      return GestureDetector(
        onTap: () => showUrlDialog(
          title: 'رابط صورة الغلاف',
          hint: 'https://images.unsplash.com/...',
          initialValue: url,
          onSave: (value) => controller.coverImageUrl.value = value,
        ),
        child: Container(
          width: double.infinity,
          height: 140,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubdued,
            borderRadius: BorderRadius.circular(16),
          ),
          child: url.isNotEmpty
              ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Text(
                'تعذر تحميل الصورة، تأكد من الرابط',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          )
              : const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.white,
                child: Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
              ),
              SizedBox(height: AppSizes.space8),
              Text(
                'انقر لإضافة صورة الغلاف',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                'رابط صورة PNG أو JPG بنسبة 16:9',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PricingSection extends StatelessWidget {
  final AddServiceController controller;

  const _PricingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: Icons.payments_outlined,
      title: 'التسعير ودعم الطلبة',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'خصم تحفيزي للشباب',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
        ),
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const FormLabel('السعر الأساسي (₪)', isRequired: true),
                  FormInput(
                    controller: controller.priceController,
                    hint: '250',
                    suffixText: '₪',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  const FormLabel('سعر طلاب خطوتي (₪)'),
                  FormInput(
                    controller: controller.studentPriceController,
                    hint: '200',
                    suffixText: '₪',
                    keyboardType: TextInputType.number,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        Obx(() {
          if (controller.discountAmount <= 0) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(top: AppSizes.space16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: AppColors.success, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 12, height: 1.6),
                      children: [
                        const TextSpan(text: 'وفرت خصمًا قدره '),
                        TextSpan(
                          text:
                          '${ProviderFormat.number(controller.discountAmount)} ₪ (${controller.discountPercent}%)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        const TextSpan(text: ' لحاملي بطاقة طالب خطوتي المعتمدة.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSizes.space16),
        Obx(
              () => GestureDetector(
            onTap: () => controller.supportInstallments.toggle(),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.supportInstallments.value
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفعيل نظام الأقساط الميسرة للطلبة الجامعيين',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'الدفع على دفعتين أو ثلاث دفعات شهرية ميسرة',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  final AddServiceController controller;

  const _AttendanceSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: Icons.tune,
      title: 'طبيعة الحضور والسعة',
      children: [
        const FormLabel('نمط تقديم الدورة أو الخدمة', isRequired: true),
        Obx(
              () => Row(
            children: [
              Expanded(child: _modeButton('in_person', 'وجاهي بالمركز', Icons.apartment)),
              const SizedBox(width: 10),
              Expanded(child: _modeButton('online', 'عن بُعد أونلاين', Icons.laptop)),
              const SizedBox(width: 10),
              Expanded(child: _modeButton('hybrid', 'مختلط (Hybrid)', Icons.swap_horiz)),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const FormLabel('عدد المقاعد المتاحة'),
                  FormInput(
                    controller: controller.seatsController,
                    hint: '20',
                    suffixText: 'مقعد',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  const FormLabel('إجمالي الساعات التدريبية'),
                  FormInput(
                    controller: controller.hoursController,
                    hint: '40',
                    suffixText: 'ساعة',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        Obx(
              () => FormToggleCard(
            icon: Icons.workspace_premium_outlined,
            iconColor: AppColors.secondary,
            title: 'شهادة تدريبية معتمدة',
            subtitle: 'تصدر للطالب فور استيفاء متطلبات التخرج والتقييم',
            value: controller.hasCertificate.value,
            onChanged: (value) => controller.hasCertificate.value = value,
          ),
        ),
      ],
    );
  }

  Widget _modeButton(String mode, String label, IconData icon) {
    return ChoiceButton(
      label: label,
      icon: icon,
      isSelected: controller.attendanceMode.value == mode,
      onTap: () => controller.attendanceMode.value = mode,
    );
  }
}