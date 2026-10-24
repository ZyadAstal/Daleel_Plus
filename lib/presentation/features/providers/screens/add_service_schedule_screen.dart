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
import 'add_service_review_screen.dart';

class AddServiceScheduleScreen extends StatelessWidget {
  const AddServiceScheduleScreen({super.key});

  void _next(AddServiceController controller) {
    final error = controller.validateSchedule();
    if (error != null) {
      Get.snackbar('تنبيه', error);
      return;
    }
    Get.to(() => const AddServiceReviewScreen());
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
          children: [
            AddServiceSteps(
              currentStep: 2,
              title: 'الجدولة والمتطلبات',
              onClose: () => confirmCloseAddService(2),
            ),
            const SizedBox(height: AppSizes.space24),
            _ScheduleSection(controller: controller),
            _LocationSection(controller: controller),
            _RequirementsSection(controller: controller),
            _InstructorSection(controller: controller),
            AppPrimaryButton(
              text: 'المتابعة إلى المعاينة والنشر',
              icon: Icons.arrow_forward,
              onPressed: () => _next(controller),
            ),
            const SizedBox(height: 12),
            AppPrimaryButton(
              text: 'الرجوع للبيانات الأساسية',
              isSecondary: true,
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: AppSizes.space16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_done_outlined, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'بياناتك محفوظة مؤقتًا حتى النشر أو الحفظ كمسودة',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final AddServiceController controller;

  const _ScheduleSection({required this.controller});

  static const List<String> _days = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu'];

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final current = isStart ? controller.startDate.value : controller.endDate.value;
    final first = isStart ? DateTime.now() : (controller.startDate.value ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(first) ? current : first,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;

    if (isStart) {
      controller.startDate.value = picked;
      final end = controller.endDate.value;
      if (end != null && end.isBefore(picked)) controller.endDate.value = null;
    } else {
      controller.endDate.value = picked;
    }
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? controller.startTime.value : controller.endTime.value,
    );
    if (picked == null) return;

    if (isStart) {
      controller.startTime.value = picked;
    } else {
      controller.endTime.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: Icons.calendar_month_outlined,
      title: 'مواعيد وانعقاد الدورة',
      subtitle: 'حدد تاريخ البدء والأيام وساعات اللقاء',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'إلزامي',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
      children: [
        Obx(
              () => Row(
            children: [
              Expanded(
                child: _pickerBox(
                  label: 'تاريخ البدء',
                  value: controller.dateText(controller.startDate.value),
                  icon: Icons.event_outlined,
                  onTap: () => _pickDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickerBox(
                  label: 'تاريخ الانتهاء',
                  value: controller.dateText(controller.endDate.value),
                  icon: Icons.event_available_outlined,
                  onTap: () => _pickDate(context, false),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        const FormLabel('أيام الانعقاد الأسبوعية'),
        Obx(
              () => Column(
            children: [
              _daysRow(_days.sublist(0, 3)),
              const SizedBox(height: 10),
              _daysRow(_days.sublist(3)),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        Obx(
              () => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _pickerBox(
                        label: 'من الساعة',
                        value: controller.timeText(controller.startTime.value),
                        icon: Icons.schedule,
                        onTap: () => _pickTime(context, true),
                        isWhite: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pickerBox(
                        label: 'إلى الساعة',
                        value: controller.timeText(controller.endTime.value),
                        icon: Icons.schedule,
                        onTap: () => _pickTime(context, false),
                        isWhite: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'المجموع الأسبوعي: ${ProviderFormat.number(controller.weeklyHours, decimals: controller.weeklyHours % 1 == 0 ? 0 : 1)} ساعات',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'إجمالي البرنامج: ${controller.totalProgramHours} ساعة',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _daysRow(List<String> days) {
    return Row(
      children: [
        for (final day in days) ...[
          Expanded(
            child: ChoiceButton(
              label: ProviderFormat.dayName(day),
              isSelected: controller.scheduleDays.contains(day),
              onTap: () => controller.toggleDay(day),
            ),
          ),
          if (day != days.last) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _pickerBox({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isWhite = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isWhite ? AppColors.white : AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Text(
                    value,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final AddServiceController controller;

  const _LocationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = controller.attendanceMode.value;
      final city = (controller.provider['city'] ?? '').toString();

      return FormSection(
        icon: Icons.location_on_outlined,
        title: 'موقع تقديم الخدمة',
        subtitle: 'اختر بيئة الحضور والتفاصيل الجغرافية',
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                _segment('in_person', 'وجاهي بالمركز'),
                _segment('online', 'عن بُعد (أونلاين)'),
                _segment('hybrid', 'مختلط (هجين)'),
              ],
            ),
          ),
          if (mode != 'online') ...[
            const SizedBox(height: AppSizes.space16),
            FormLabel(
              'اسم القاعة أو المقر',
              trailing: city.isEmpty
                  ? null
                  : Text(
                'فرع $city',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            FormInput(
              controller: controller.venueController,
              hint: 'قاعة التدريب الذكية A - الطابق الثاني',
              icon: Icons.meeting_room_outlined,
            ),
            const SizedBox(height: AppSizes.space16),
            const FormLabel('العنوان المحدد للملتحقين:'),
            FormInput(
              controller: controller.addressController,
              hint: 'شارع الشهداء، مجمع التقنية الأكاديمي',
              icon: Icons.place_outlined,
            ),
          ],
          if (mode != 'in_person') ...[
            const SizedBox(height: AppSizes.space16),
            FormLabel(
              'رابط منصة البث المساند (اختياري)',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Zoom / Teams',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: FormInput(
                controller: controller.meetingUrlController,
                hint: 'https://zoom.us/j/8834910293',
                icon: Icons.videocam_outlined,
                keyboardType: TextInputType.url,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _segment(String mode, String label) {
    final isSelected = controller.attendanceMode.value == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.attendanceMode.value = mode,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementsSection extends StatelessWidget {
  final AddServiceController controller;

  const _RequirementsSection({required this.controller});

  static const Map<String, IconData> _audienceIcons = {
    'students': Icons.groups_outlined,
    'graduates': Icons.work_outline,
    'employees': Icons.apartment,
  };

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: Icons.school_outlined,
      title: 'المتطلبات والجمهور المستهدف',
      subtitle: 'لتوجيه الطلاب الملائمين لفرصتك الأكاديمية',
      children: [
        const FormLabel('المستوى الأكاديمي / المعرفي'),
        Obx(
              () => Wrap(
            spacing: AppSizes.space8,
            runSpacing: AppSizes.space8,
            children: AddServiceController.levels.entries.map((level) {
              final isSelected = controller.targetLevel.value == level.key;

              return GestureDetector(
                onTap: () => controller.targetLevel.value = level.key,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    level.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        const FormLabel('الفئات الموجه إليها التدريب'),
        Obx(
              () => Column(
            children: AddServiceController.audienceOptions.entries.map((audience) {
              return FormCheckRow(
                label: audience.value,
                icon: _audienceIcons[audience.key]!,
                isChecked: controller.audiences.contains(audience.key),
                onTap: () => controller.toggleAudience(audience.key),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSizes.space8),
        const FormLabel(
          'المتطلبات المسبقة والأجهزة المطلوبة',
          trailing: Text(
            'اختياري',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        FormInput(
          controller: controller.prerequisitesController,
          hint: 'مثال: إحضار كمبيوتر محمول شخصي لا يقل عن 8GB RAM، ومعرفة مسبقة بمبادئ منطق البرمجة أو JavaScript.',
          maxLines: 3,
        ),
      ],
    );
  }
}

class _InstructorSection extends StatelessWidget {
  final AddServiceController controller;

  const _InstructorSection({required this.controller});

  void _showAddInstructor() {
    final nameController = TextEditingController();
    final titleController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إضافة مدرب',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.space16),
              const FormLabel('اسم المدرب', isRequired: true),
              FormInput(controller: nameController, hint: 'أ. محمد عبد الله', icon: Icons.person_outline),
              const SizedBox(height: AppSizes.space16),
              const FormLabel('المسمى أو التخصص'),
              FormInput(
                controller: titleController,
                hint: 'خبير تطوير نظم الويب والذكاء الاصطناعي',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: AppSizes.space24),
              AppPrimaryButton(
                text: 'إضافة',
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    Get.snackbar('تنبيه', 'اكتب اسم المدرب');
                    return;
                  }
                  Get.back();
                  controller.addInstructor(name: name, title: titleController.text.trim());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstructorPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر المدرب المسؤول',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.space16),
              ...controller.instructors.map(
                    (instructor) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceSubdued,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(instructor['name'] ?? ''),
                  subtitle: Text(instructor['title'] ?? ''),
                  onTap: () {
                    controller.selectedInstructor.value = instructor;
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: Icons.assignment_ind_outlined,
      title: 'المدرب أو المشرف المسؤول',
      subtitle: 'سيتم عرض بيانات المحاضر بصفحة الدورة',
      trailing: TextButton.icon(
        onPressed: _showAddInstructor,
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('إضافة مدرب'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      children: [
        Obx(() {
          final instructor = controller.selectedInstructor.value;
          if (instructor == null) {
            return const Text(
              'لم تتم إضافة مدربين بعد، أضف مدربًا ليظهر للطلاب',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            );
          }

          final String avatar = instructor['avatarUrl'] ?? '';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.white,
                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar.isEmpty
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
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
                              instructor['name'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'معتمد',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        instructor['title'] ?? '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (controller.instructors.length > 1)
                  IconButton(
                    onPressed: _showInstructorPicker,
                    style: IconButton.styleFrom(backgroundColor: AppColors.white),
                    icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}