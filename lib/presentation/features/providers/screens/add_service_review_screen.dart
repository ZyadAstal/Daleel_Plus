import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/add_service_controller.dart';
import '../state/provider_helpers.dart';
import '../widgets/add_service_form.dart';
import '../widgets/add_service_steps.dart';
import '../widgets/provider_top_bar.dart';

class AddServiceReviewScreen extends StatelessWidget {
  const AddServiceReviewScreen({super.key});

  Future<void> _save(AddServiceController controller, {required bool publish}) async {
    final saved = await controller.save(publish: publish);
    if (saved) Get.close(3);
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
              currentStep: 3,
              title: 'المعاينة والنشر النهائي',
              onClose: () => confirmCloseAddService(3),
            ),
            const SizedBox(height: AppSizes.space24),
            const _PreviewHeader(),
            const SizedBox(height: AppSizes.space16),
            _PreviewCard(controller: controller),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'هذا الشكل النهائي الذي سيراه الطالب في دليل الدورات والخدمات الأكاديمية',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            _CancellationPolicies(controller: controller),
            const SizedBox(height: AppSizes.space24),
            _Attachments(controller: controller),
            const SizedBox(height: AppSizes.space24),
            _LaunchSettings(controller: controller),
            const SizedBox(height: AppSizes.space24),
            const _QualityNote(),
            const SizedBox(height: AppSizes.space24),
            Obx(
                  () => AppPrimaryButton(
                text: controller.isEditing ? 'حفظ التعديلات ونشرها' : 'نشر الخدمة الآن واعتمادها',
                icon: Icons.rocket_launch_outlined,
                isLoading: controller.isSaving.value,
                onPressed: () => _save(controller, publish: true),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    text: 'حفظ كمسودة',
                    icon: Icons.bookmark_border,
                    isSecondary: true,
                    onPressed: () => _save(controller, publish: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                      label: const Text('تعديل الجدولة'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 22),
        const SizedBox(width: AppSizes.space8),
        const Expanded(
          child: Text(
            'معاينة بطاقة الخدمة كما ستظهر للطلاب',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 7, color: AppColors.primary),
              SizedBox(width: AppSizes.space4),
              Text(
                'معاينة حية',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final AddServiceController controller;

  const _PreviewCard({required this.controller});

  static const Map<String, String> _modes = {
    'in_person': 'وجاهي',
    'online': 'أونلاين',
    'hybrid': 'مختلط',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final provider = controller.provider;
      final providerName = (provider['businessName'] ?? '').toString();
      final city = (provider['city'] ?? '').toString();
      final isVerified = provider['verificationStatus'] == 'verified';
      final start = controller.startDate.value;
      final hours = int.tryParse(controller.hoursController.text) ?? controller.totalProgramHours;
      final hasDiscount = controller.discountAmount > 0;

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _cover(controller.coverImageUrl.value),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0x99000000)],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: _overlayChip(
                      AddServiceController.categories[controller.category.value] ?? '',
                      Icons.school_outlined,
                      background: AppColors.primary,
                    ),
                  ),
                  if (controller.hasCertificate.value)
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: _overlayChip(
                        'شهادة معتمدة',
                        Icons.verified,
                        background: AppColors.white,
                        foreground: AppColors.textPrimary,
                        iconColor: AppColors.secondary,
                      ),
                    ),
                  PositionedDirectional(
                    bottom: 12,
                    start: 12,
                    end: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (start != null)
                          _infoText('يبدأ ${start.day} ${_monthName(start.month)}', Icons.calendar_today_outlined),
                        if (hours > 0) _infoText('$hours ساعة تدريبية', Icons.schedule),
                        _infoText(_modes[controller.attendanceMode.value] ?? '', Icons.place_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.titleController.text.trim().isEmpty
                        ? 'عنوان الخدمة'
                        : controller.titleController.text.trim(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.surfaceSubdued,
                        child: Text(
                          providerName.isEmpty ? '' : providerName.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.space8),
                      Flexible(
                        child: Text(
                          city.isEmpty ? providerName : '$providerName - $city',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: AppSizes.space4),
                        const Icon(Icons.verified, size: 16, color: AppColors.primary),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubdued,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'شريك موثق',
                            style: TextStyle(fontSize: 10, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 28, color: AppColors.border),
                  Row(
                    children: [
                      Text(
                        '${ProviderFormat.number(hasDiscount ? controller.studentPrice.value : controller.price.value)} شيكل',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: AppSizes.space8),
                        Text(
                          '${ProviderFormat.number(controller.price.value)} شيكل',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sell_outlined, size: 12),
                              const SizedBox(width: AppSizes.space4),
                              Text(
                                'وفر ${controller.discountPercent}% للطلاب',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _monthName(int month) => ProviderFormat.date(DateTime(2000, month)).split(' ')[1];

  Widget _cover(String url) {
    const placeholder = const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B4FD8), Color(0xFFB9A8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
  }

  Widget _overlayChip(
      String text,
      IconData icon, {
        required Color background,
        Color foreground = AppColors.white,
        Color? iconColor,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor ?? foreground),
          const SizedBox(width: AppSizes.space4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: foreground)),
        ],
      ),
    );
  }

  Widget _infoText(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.white),
        const SizedBox(width: AppSizes.space4),
        Text(text, style: const TextStyle(fontSize: 10, color: AppColors.white)),
      ],
    );
  }
}

class _CancellationPolicies extends StatelessWidget {
  final AddServiceController controller;

  const _CancellationPolicies({required this.controller});

  static const Map<String, String> _descriptions = {
    'full_refund_48h':
    'يمنح الطالب مرونة الانسحاب واستعادة المبلغ كاملًا، مما يرفع معدل التسجيل بنسبة 35% حسب إحصائيات خطوتي.',
    'half_refund_first_session':
    'إذا رغب الطالب في الانسحاب بعد تجربة المحاضرة الأولى، يتم استرداد نصف المبلغ المدفوع.',
    'custom': 'تطبيق بنود اللائحة الداخلية لمركز التدريب والتنسيق المباشر مع شؤون الطلاب.',
  };

  static const Map<String, String> _titles = {
    'full_refund_48h': 'استرداد كامل حتى 48 ساعة قبل بدء الدورة',
    'half_refund_first_session': 'استرداد 50% بعد حضور الجلسة الأولى',
    'custom': 'سياسة مخصصة للمركز',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.policy_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: AppSizes.space8),
            Expanded(
              child: Text(
                'سياسة الحجز والإلغاء',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Text('مطلوب', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
              () => Column(
            children: _titles.keys.map((policy) {
              final isSelected = controller.cancellationPolicy.value == policy;

              return GestureDetector(
                onTap: () => controller.cancellationPolicy.value = policy,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(AppSizes.space16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : AppColors.surfaceSubdued,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _titles[policy]!,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (policy == 'full_refund_48h')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'موصى به للطلاب',
                                      style: TextStyle(fontSize: 9, color: AppColors.white),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.space4),
                            Text(
                              _descriptions[policy]!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Attachments extends StatelessWidget {
  final AddServiceController controller;

  const _Attachments({required this.controller});

  void _editLink(RxString link, String title) {
    showUrlDialog(
      title: title,
      hint: 'https://drive.google.com/...',
      initialValue: link.value,
      onSave: (value) => link.value = value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = [controller.syllabusUrl.value, controller.brochureUrl.value]
          .where((url) => url.isNotEmpty)
          .length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSizes.space8),
              const Expanded(
                child: Text(
                  'خطة التدريب والمرفقات الأكاديمية',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'مرفق $count من 2',
                style: const TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _attachment(
            link: controller.syllabusUrl,
            name: 'خطة_المسار_التدريبي.pdf',
            addText: 'إرفاق خطة التدريب (PDF)',
          ),
          const SizedBox(height: 12),
          _attachment(
            link: controller.brochureUrl,
            name: 'بروشور_المتطلبات.pdf',
            addText: 'إرفاق بروشور المتطلبات والشروط المسبقة (اختياري)',
          ),
        ],
      );
    });
  }

  Widget _attachment({required RxString link, required String name, required String addText}) {
    if (link.value.isEmpty) {
      return GestureDetector(
        onTap: () => _editLink(link, addText),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.space16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubdued,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Text(
                  addText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const Row(
                  children: [
                    Icon(Icons.check, size: 12, color: AppColors.success),
                    SizedBox(width: 2),
                    Text('جاهز للتنزيل', style: TextStyle(fontSize: 10, color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => launchUrl(Uri.parse(link.value), mode: LaunchMode.externalApplication),
            style: IconButton.styleFrom(backgroundColor: AppColors.surfaceSubdued),
            icon: const Icon(Icons.visibility_outlined, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () => link.value = '',
            style: IconButton.styleFrom(backgroundColor: AppColors.error.withValues(alpha: 0.12)),
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _LaunchSettings extends StatelessWidget {
  final AddServiceController controller;

  const _LaunchSettings({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.tune, color: AppColors.primary, size: 22),
            SizedBox(width: AppSizes.space8),
            Text(
              'إعدادات الإطلاق والتسجيل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSizes.space16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Obx(
                () => Column(
              children: [
                _settingRow(
                  icon: Icons.campaign_outlined,
                  title: 'نشر فوري وإشعار الطلاب المهتمين في غزة',
                  subtitle: 'إرسال إشعار فوري للطلاب المهتمين بنفس المجال عبر التطبيق.',
                  value: controller.notifyStudents.value,
                  onChanged: (value) => controller.notifyStudents.value = value,
                ),
                const Divider(height: 28, color: AppColors.border),
                _settingRow(
                  icon: Icons.payments_outlined,
                  title: 'السماح بالدفع الجزئي وتقسيط الرسوم',
                  subtitle: 'تمكين خيار دفع 50% عند تثبيت المقعد والباقي مع بداية الأسبوع الثاني.',
                  value: controller.allowPartialPayment.value,
                  onChanged: (value) => controller.allowPartialPayment.value = value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSizes.space4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.6),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primary),
      ],
    );
  }
}

class _QualityNote extends StatelessWidget {
  const _QualityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.verified_user_outlined, color: AppColors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ضمان جودة البيئة التعليمية',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                Text(
                  'تخضع كافة الخدمات المنشورة لمراجعة فريق الجودة في خطوتي لضمان حقوق الطلاب والمراكز على حد سواء.',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}