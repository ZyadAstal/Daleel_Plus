import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/provider_helpers.dart';
import '../state/provider_profile_controller.dart';
import 'confirm_dialog.dart';

void showWorkingHoursSheet(ProviderProfileController controller) {
  Get.bottomSheet(_WorkingHoursSheet(controller: controller), isScrollControlled: true);
}

void showCancellationSheet(ProviderProfileController controller) {
  Get.bottomSheet(_CancellationSheet(controller: controller), isScrollControlled: true);
}

void showWhatsappSheet(ProviderProfileController controller) {
  Get.bottomSheet(_WhatsappSheet(controller: controller), isScrollControlled: true);
}

void showLogoutDialog(ProviderProfileController controller) {
  showConfirmDialog(
    title: 'تسجيل الخروج',
    message: 'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
    confirmText: 'تسجيل الخروج',
    icon: Icons.logout,
    onConfirm: controller.logout,
  );
}

class _SheetFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.space24,
        12,
        AppSizes.space24,
        AppSizes.space24 + MediaQuery.of(context).viewInsets.bottom,
      ),
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.space16),
            child,
          ],
        ),
      ),
    );
  }
}

class _WorkingHoursSheet extends StatefulWidget {
  final ProviderProfileController controller;

  const _WorkingHoursSheet({required this.controller});

  @override
  State<_WorkingHoursSheet> createState() => _WorkingHoursSheetState();
}

class _WorkingHoursSheetState extends State<_WorkingHoursSheet> {
  late final Set<String> _days;
  late TimeOfDay _opening;
  late TimeOfDay _closing;

  @override
  void initState() {
    super.initState();
    final List savedDays = widget.controller.provider['workingDays'] ?? [];
    _days = savedDays.map((day) => day.toString()).toSet();
    _opening = _parse(widget.controller.field('openingTime'), 9);
    _closing = _parse(widget.controller.field('closingTime'), 18);
  }

  TimeOfDay _parse(String time, int defaultHour) {
    final parts = time.split(':');
    if (parts.length < 2) return TimeOfDay(hour: defaultHour, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? defaultHour,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _opening : _closing,
    );
    if (picked == null) return;
    setState(() {
      if (isOpening) {
        _opening = picked;
      } else {
        _closing = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_days.isEmpty) {
      Get.snackbar('تنبيه', 'اختر يوم عمل واحد على الأقل');
      return;
    }

    final orderedDays =
    ProviderFormat.dayNames.keys.where((day) => _days.contains(day)).toList();

    final saved = await widget.controller.saveWorkingHours(
      days: orderedDays,
      openingTime: _format(_opening),
      closingTime: _format(_closing),
    );
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'ساعات العمل وتلقي الحجوزات',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('أيام العمل', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.space8),
          Wrap(
            spacing: AppSizes.space8,
            runSpacing: AppSizes.space8,
            children: ProviderFormat.dayNames.entries.map((day) {
              final isSelected = _days.contains(day.key);
              return FilterChip(
                label: Text(day.value),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceSubdued,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.primary,
                ),
                onSelected: (value) => setState(() {
                  if (value) {
                    _days.add(day.key);
                  } else {
                    _days.remove(day.key);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.space16),
          Row(
            children: [
              Expanded(child: _timeBox('من', _opening, () => _pickTime(true))),
              const SizedBox(width: 12),
              Expanded(child: _timeBox('إلى', _closing, () => _pickTime(false))),
            ],
          ),
          const SizedBox(height: AppSizes.space24),
          Obx(
                () => AppPrimaryButton(
              text: 'حفظ',
              isLoading: widget.controller.isSaving.value,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String label, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSizes.space8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            Text(
              ProviderFormat.time12h(_format(time)),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancellationSheet extends StatefulWidget {
  final ProviderProfileController controller;

  const _CancellationSheet({required this.controller});

  @override
  State<_CancellationSheet> createState() => _CancellationSheetState();
}

class _CancellationSheetState extends State<_CancellationSheet> {
  late String _policy;

  @override
  void initState() {
    super.initState();
    final saved = widget.controller.field('defaultCancellationPolicy');
    _policy = ProviderFormat.cancellationPolicies.contains(saved)
        ? saved
        : ProviderFormat.cancellationPolicies.first;
  }

  Future<void> _save() async {
    final saved = await widget.controller.saveCancellationPolicy(_policy);
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'سياسة الإلغاء واسترداد الرسوم',
      child: Column(
        children: [
          ...ProviderFormat.cancellationPolicies.map((policy) {
            final isSelected = _policy == policy;
            return GestureDetector(
              onTap: () => setState(() => _policy = policy),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSizes.space8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surfaceSubdued : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ProviderFormat.cancellationPolicy(policy),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSizes.space16),
          Obx(
                () => AppPrimaryButton(
              text: 'حفظ',
              isLoading: widget.controller.isSaving.value,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsappSheet extends StatefulWidget {
  final ProviderProfileController controller;

  const _WhatsappSheet({required this.controller});

  @override
  State<_WhatsappSheet> createState() => _WhatsappSheetState();
}

class _WhatsappSheetState extends State<_WhatsappSheet> {
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.controller.field('whatsappNumber'));
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final number = _numberController.text.trim();
    if (number.isNotEmpty && number.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      Get.snackbar('تنبيه', 'رقم الواتساب غير صحيح');
      return;
    }

    final saved = await widget.controller.saveWhatsapp(number);
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'ربط الواتساب للدعم الفوري للطلبة',
      child: Column(
        children: [
          Container(
            height: AppSizes.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: '+970 59 000 0000',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space8),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'اتركه فارغًا لإلغاء الربط',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          Obx(
                () => AppPrimaryButton(
              text: 'حفظ',
              isLoading: widget.controller.isSaving.value,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}