import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/add_review_controller.dart';
import '../../app_status/screens/system_error_screen.dart';
import '../../app_status/screens/not_found_screen.dart';

class AddReviewScreen extends StatelessWidget {
  final String orderId;

  const AddReviewScreen({super.key, required this.orderId});

  static void open(String orderId) {
    Get.delete<AddReviewController>(force: true);
    Get.to(() => AddReviewScreen(orderId: orderId));
  }

  void _addImageDialog(AddReviewController controller) {
    final linkController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'إضافة صورة',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: linkController,
          decoration: const InputDecoration(hintText: 'رابط الصورة (https://...)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              controller.addImage(linkController.text);
              Get.back();
            },
            child: const Text('إضافة', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(AddReviewController controller) async {
    final success = await controller.submit();
    if (!success) return;
    Get.back();
    Get.snackbar('شكرًا لك', 'تم نشر تقييمك بنجاح');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddReviewController(orderId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'إضافة تقييم و مراجعة'),
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

        if (controller.order.isEmpty) {
          return const NotFoundScreen();
        }

        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: [
            _OrderCard(controller: controller),
            if (!controller.isCompleted || controller.isReviewed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  controller.isReviewed
                      ? 'شكرًا لك! لقد قمت بتقييم هذا الطلب مسبقًا.'
                      : 'يمكنك تقييم الطلب بعد أن يصبح مكتملًا.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.space16),
            _OverallRating(controller: controller),
            const SizedBox(height: AppSizes.space16),
            _Card(
              title: 'معايير التقييم التفصيلية',
              hint: 'مقياس من 1 إلى 5',
              child: Column(
                children: AddReviewController.criteriaNames.entries.map((entry) {
                  final value = controller.criteria[entry.key] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(AddReviewController.criteriaIcons[entry.key], size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              value.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => controller.changeCriteria(entry.key, index + 1),
                              child: Icon(
                                index < value ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 26,
                                color: index < value ? AppColors.secondary : AppColors.textHint,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _Card(
              title: 'وسوم التميز السريعة',
              hint: 'اختر ما يناسب تجربتك',
              child: Wrap(
                spacing: AppSizes.space8,
                runSpacing: AppSizes.space8,
                children: AddReviewController.tags.map((tag) {
                  final isSelected = controller.selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => controller.toggleTag(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _Card(
              title: 'المراجعة النصية للطالب',
              hint: '${controller.commentLength.value} حرف',
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: controller.commentController,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 500,
                      style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'اكتب تجربتك مع الدورة والمدرب والقاعة...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'المراجعات الصادقة تساعد زملاءك في اختيار المسار الأكاديمي والمهني الأمثل.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _Card(
              title: 'إرفاق صور إثبات أو إنجاز',
              subtitle: 'شهادة الدورة، لقطات من المشروع، أو نموذج الطباعة',
              badge: 'اختياري',
              child: SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () => _addImageDialog(controller),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                            SizedBox(height: 4),
                            Text(
                              'إضافة صورة',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...controller.images.map(
                          (url) => Padding(
                        padding: const EdgeInsetsDirectional.only(start: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                url,
                                width: 100,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  color: AppColors.surfaceSubdued,
                                  child: const Icon(Icons.broken_image_outlined, color: AppColors.textHint),
                                ),
                              ),
                            ),
                            PositionedDirectional(
                              top: 4,
                              start: 4,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(url),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: AppColors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _Card(
              title: 'طريقة نشر التقييم',
              child: Column(
                children: [
                  _PublishOption(
                    icon: Icons.badge_outlined,
                    title: 'نشر باسم الطالب الموثق',
                    subtitle: controller.studentInfo,
                    isSelected: !controller.isAnonymous.value,
                    onTap: () => controller.isAnonymous.value = false,
                  ),
                  const SizedBox(height: 10),
                  _PublishOption(
                    icon: Icons.visibility_off_outlined,
                    title: 'نشر كمجهول (طالب جامعي)',
                    subtitle: 'لن يظهر اسمك أو صورتك الشخصية للعامة',
                    isSelected: controller.isAnonymous.value,
                    onTap: () => controller.isAnonymous.value = true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            GestureDetector(
              onTap: controller.canSubmit ? () => _submit(controller) : null,
              child: Container(
                height: AppSizes.buttonHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.canSubmit ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: controller.isSending.value
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'إرسال التقييم واعتماده',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.white),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.send_outlined, size: 18, color: AppColors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            const Center(
              child: Text(
                'يخضع تقييمك لميثاق النزاهة الأكاديمية والشفافية في منصة دليل+',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
      BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );
}

class _Card extends StatelessWidget {
  final String title;
  final String? hint;
  final String? subtitle;
  final String? badge;
  final Widget child;

  const _Card({required this.title, required this.child, this.hint, this.subtitle, this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              if (hint != null) Text(hint!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AddReviewController controller;

  const _OrderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final image = controller.courseImage.value;
      final isPaid = controller.text('paymentStatus') == 'paid';

      return Container(
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (controller.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified, size: 14, color: AppColors.success),
                                  SizedBox(width: 4),
                                  Text(
                                    'طلب مكتمل وموثق',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          Text(
                            '#${controller.text('orderNumber')}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space8),
                      Text(
                        controller.text('itemTitle'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      if (controller.providerName.value.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                controller.providerName.value,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (image.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(width: 64, height: 64),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.surfaceSubdued, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'تاريخ الإنجاز: ${controller.completedDate}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  if (isPaid) ...[
                    const Icon(Icons.receipt_long_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text(
                      'إيصال مدفوع',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _OverallRating extends StatelessWidget {
  final AddReviewController controller;

  const _OverallRating({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rating = controller.rating.value;

      return Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            const Text(
              'التقييم العام المباشر',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            const Text(
              'كيف كانت تجربتك التعليمية؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'اضغط على النجوم للتعبير عن انطباعك الإجمالي',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.space16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => controller.changeRating(index + 1),
                  child: Icon(
                    index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 48,
                    color: index < rating ? AppColors.secondary : AppColors.textHint,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🌟 ${AddReviewController.ratingLabels[rating]} ($rating / 5)',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PublishOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PublishOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.textHint.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: isSelected ? AppColors.white : AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}