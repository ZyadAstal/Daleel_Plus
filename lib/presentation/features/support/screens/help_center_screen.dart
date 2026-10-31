import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/support_controller.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  void _attachDialog(SupportController controller) {
    final field = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'إرفاق لقطة شاشة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: field,
          decoration: const InputDecoration(
            hintText: 'رابط الصورة (https://...)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              controller.setAttachment(field.text);
              Get.back();
            },
            child: const Text(
              'إرفاق',
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'مركز المساعدة و الدعم'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final faqs = controller.visibleFaqs;

        return ListView(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '● فريق الدعم الطلابي متواجد لخدمتك',
                      style: TextStyle(fontSize: 11, color: AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'كيف يمكننا مساعدتك اليوم؟',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'إجابات فورية، مساندة أكاديمية لحجوزاتك، وحلول سريعة لخدمات الطباعة والدورات الجامعية.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            onChanged: controller.changeSearch,
                            decoration: const InputDecoration(
                              hintText:
                                  'ابحث عن مشكلة، استرداد، خصم، أو حجز...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: AppColors.textHint,
                              ),
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
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'قنوات الدعم الفوري المباشر',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _Badge(text: 'استجابة فائقة', color: AppColors.success),
              ],
            ),
            const SizedBox(height: 12),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.chat_outlined,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'محادثة واتساب الفورية',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'تواصل مباشرة مع المشرف الأكاديمي المناوب لحل إشكاليات البطاقات والطباعة.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Badge(
                        text: '● 24/7 متاح الآن',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '+${controller.whatsapp}',
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _Button(
                        text: 'بدء المحادثة',
                        color: AppColors.success,
                        onTap: controller.openWhatsapp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ChannelCard(
                    icon: Icons.phone_outlined,
                    title: 'الاتصال الهاتفي',
                    subtitle: 'مخصص للطلبة ومزودي الخدمات من 8 ص حتى 8 م',
                    buttonText: 'اتصل الآن',
                    isPrimary: false,
                    onTap: controller.callSupport,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChannelCard(
                    icon: Icons.confirmation_number_outlined,
                    iconColor: AppColors.secondary,
                    title: 'تذاكر الدعم',
                    subtitle: 'متابعة البلاغات الرسمية واسترداد الرسوم',
                    badge: controller.openTickets.value > 0
                        ? '${controller.openTickets.value} نشطة'
                        : null,
                    buttonText: 'فتح تذكرة',
                    isPrimary: true,
                    onTap: controller.scrollToForm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأسئلة الشائعة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'إجابات سريعة لأهم تساؤلات طلاب غزة والضفة',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.help_outline, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            // لا توجد نتائج للبحث: بعد تجهيز شاشة 41 من app_status استبدلي النص بـ:
            // EmptyStateScreen(searchTerm: ..., onClearSearch: ...) // شاشة 41 من app_status
            if (faqs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.space16),
                child: Center(
                  child: Text(
                    'لا توجد أسئلة مطابقة',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ...faqs.asMap().entries.map((entry) {
              final isOpen = controller.expandedIndex.value == entry.key;
              return GestureDetector(
                onTap: () => controller.toggleFaq(entry.key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(AppSizes.space16),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.value['question'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 8),
                        Text(
                          entry.value['answer'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSizes.space16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إرسال استفسار أو بلاغ أكاديمي',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'سيتم تعيين مشرف مختص لمتابعة حالتك فورا!',
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
                  const SizedBox(height: AppSizes.space16),
                  const Text(
                    'نوع المشكلة أو الطلب',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3.4,
                    children: SupportController.ticketTypes.entries.map((
                      entry,
                    ) {
                      final isSelected =
                          controller.ticketType.value == entry.key;
                      return GestureDetector(
                        onTap: () => controller.changeType(entry.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surfaceSubdued,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                SupportController.ticketIcons[entry.key],
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  const Text(
                    'تفاصيل الاستفسار أو المشكلة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: controller.detailsController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'يرجى كتابة رقم الطلب واسم المركز أو الدورة مع تفاصيل ما حدث...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  const Text(
                    'إرفاق لقطة شاشة أو وصل دفع (اختياري)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  GestureDetector(
                    onTap: () => _attachDialog(controller),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              controller.attachmentUrl.value.isEmpty
                                  ? 'اضغط لإرفاق رابط صورة المشكلة'
                                  : 'تم إرفاق الصورة ✓',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Text(
                            'استعراض',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  GestureDetector(
                    onTap: controller.isSending.value
                        ? null
                        : controller.sendTicket,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.isSending.value
                                ? 'جارٍ الإرسال...'
                                : 'إرسال التذكرة لفريق الدعم',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.send_outlined,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _Button({required this.text, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.send_outlined, size: 16, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final String buttonText;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ChannelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.isPrimary,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor == AppColors.secondary
                  ? AppColors.textPrimary
                  : iconColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (badge != null) _Badge(text: badge!, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isPrimary ? AppColors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
