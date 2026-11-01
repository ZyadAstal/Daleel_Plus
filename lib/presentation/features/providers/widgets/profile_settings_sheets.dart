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
  late bool _accepting;

  @override
  void initState() {
    super.initState();
    _accepting = widget.controller.isAvailable;
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
      acceptingOrders: _accepting,
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
          const SizedBox(height: AppSizes.space16),
          // تلقي الحجوزات: إذا مسكّر، الطلاب ما بيقدروا يبعتوا طلبات جديدة
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _accepting,
            activeColor: AppColors.white,
            title: const Text('استقبال حجوزات جديدة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            subtitle: Text(
              _accepting ? 'الطلاب بيقدروا يحجزوا عندك' : 'لن تصلك طلبات جديدة',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            onChanged: (value) => setState(() => _accepting = value),
          ),
          const SizedBox(height: AppSizes.space8),
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
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
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
// ===================== تعديل الملف =====================

void showEditProfileSheet(ProviderProfileController controller) {
  Get.bottomSheet(_EditProfileSheet(controller: controller), isScrollControlled: true);
}

// حقل نص بسيط للشيتات
class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboard;

  const _SheetField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboard,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final ProviderProfileController controller;

  const _EditProfileSheet({required this.controller});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  // اسم الحقل بـ Firestore : عنوانه بالشاشة
  static const Map<String, String> _labels = {
    'businessName': 'اسم المركز / مقدم الخدمة',
    'headline': 'الوصف المختصر',
    'bioDescription': 'نبذة عن المركز وخدماته',
    'city': 'المدينة',
    'addressDetails': 'العنوان التفصيلي',
    'commercialRegisterOrPortfolio': 'رقم السجل التجاري أو رابط الأعمال',
    'licenseNumber': 'رقم ترخيص التعليم العالي',
    'logoUrl': 'رابط صورة الشعار (https://...)',
    'coverImageUrl': 'رابط صورة الغلاف (https://...)',
  };

  late final Map<String, TextEditingController> _fields = {
    for (final key in _labels.keys) key: TextEditingController(text: widget.controller.field(key)),
  };

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_fields['businessName']!.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'اكتب اسم المركز');
      return;
    }
    final saved = await widget.controller.saveProfile({
      for (final entry in _fields.entries) entry.key: entry.value.text.trim(),
    });
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: _SheetFrame(
        title: 'تعديل الملف',
        child: Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final entry in _labels.entries)
                  _SheetField(
                    label: entry.value,
                    controller: _fields[entry.key]!,
                    maxLines: entry.key == 'bioDescription' ? 4 : 1,
                  ),
                const SizedBox(height: AppSizes.space8),
                Obx(
                  () => AppPrimaryButton(
                    text: 'حفظ التعديلات',
                    isLoading: widget.controller.isSaving.value,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== المدربين =====================

void showAddInstructorSheet(ProviderProfileController controller) {
  Get.bottomSheet(_AddInstructorSheet(controller: controller), isScrollControlled: true);
}

class _AddInstructorSheet extends StatefulWidget {
  final ProviderProfileController controller;

  const _AddInstructorSheet({required this.controller});

  @override
  State<_AddInstructorSheet> createState() => _AddInstructorSheetState();
}

class _AddInstructorSheetState extends State<_AddInstructorSheet> {
  final _name = TextEditingController();
  final _title = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'اكتب اسم المدرب');
      return;
    }
    final saved = await widget.controller.addInstructor(name: _name.text, title: _title.text);
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'إضافة مدرب أو مشرف',
      child: Column(
        children: [
          _SheetField(label: 'اسم المدرب', controller: _name),
          _SheetField(label: 'التخصص أو المسمى (مثال: مدرب برمجة)', controller: _title),
          const SizedBox(height: AppSizes.space8),
          Obx(
            () => AppPrimaryButton(
              text: 'إضافة',
              isLoading: widget.controller.isSaving.value,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

// لما تضغطي على مدرب: إيقاف/تفعيل أو حذف
void showInstructorActions(ProviderProfileController controller, int index) {
  final instructor = controller.instructors[index];
  final bool isActive = instructor['isActive'] ?? false;

  Get.bottomSheet(
    _SheetFrame(
      title: instructor['name'] ?? '',
      child: Column(
        children: [
          ListTile(
            leading: Icon(isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: AppColors.primary),
            title: Text(isActive ? 'إيقاف المدرب مؤقتًا' : 'تفعيل المدرب'),
            onTap: () async {
              Get.back();
              await controller.toggleInstructor(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('حذف المدرب', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Get.back();
              showConfirmDialog(
                title: 'حذف المدرب',
                message: 'هل تريد حذف ${instructor['name'] ?? ''} من قائمة المدربين؟',
                confirmText: 'حذف',
                icon: Icons.delete_outline,
                onConfirm: () => controller.removeInstructor(index),
              );
            },
          ),
        ],
      ),
    ),
  );
}

// ===================== سجل الحركات المالية =====================

void showTransactionsSheet(ProviderProfileController controller) {
  Get.bottomSheet(_TransactionsSheet(controller: controller), isScrollControlled: true);
}

class _TransactionsSheet extends StatelessWidget {
  final ProviderProfileController controller;

  const _TransactionsSheet({required this.controller});

  static String _typeText(dynamic type) {
    switch (type) {
      case 'payment_in_platform':
        return 'دفعة من طالب';
      case 'refund':
        return 'استرداد لطالب';
      case 'payout':
        return 'تحويل للحساب البنكي';
      default:
        return 'حركة مالية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = controller.transactions;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: _SheetFrame(
        title: 'سجل الحركات المالية',
        child: list.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.space24),
                child: Text('لا توجد حركات مالية بعد', style: TextStyle(color: AppColors.textSecondary)),
              )
            : Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: list.map((item) {
                    final isRefund = item['transactionType'] == 'refund';
                    final amount = (item['netProviderAmount'] ?? 0).toDouble();
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_typeText(item['transactionType']),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: Text(ProviderFormat.timeAgo(item['createdAt']),
                          style: const TextStyle(fontSize: 11)),
                      trailing: Text(
                        '${isRefund ? '-' : '+'}${ProviderFormat.number(amount, decimals: 2)} ₪',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isRefund ? AppColors.error : AppColors.success,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
