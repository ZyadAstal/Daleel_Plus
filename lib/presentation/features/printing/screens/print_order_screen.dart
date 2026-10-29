import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import '../../providers/state/provider_helpers.dart';
import '../../providers/widgets/provider_top_bar.dart';
import '../state/print_order_controller.dart';
import '../widgets/order_status_dialog.dart';

class PrintOrderScreen extends StatelessWidget {
  final Map<String, dynamic> center;

  const PrintOrderScreen({super.key, required this.center});

  static void open(Map<String, dynamic> center) {
    Get.delete<PrintOrderController>(force: true);
    Get.to(() => PrintOrderScreen(center: center));
  }

  Future<void> _submit(PrintOrderController controller) async {
    final orderId = await controller.submit();
    if (orderId == null) return;

    await Get.dialog(OrderStatusDialog(orderId: orderId), barrierDismissible: false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrintOrderController(center: center));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const ProviderTopBar(title: 'تفاصيل خدمة الطباعة والتكلفة'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CenterInfo(center: center),
            const SizedBox(height: AppSizes.space16),
            _FileCard(controller: controller),
            const SizedBox(height: AppSizes.space24),
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primary, size: 22),
                const SizedBox(width: AppSizes.space8),
                const Expanded(
                  child: Text(
                    'تخصيص مواصفات الطباعة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                _chip('حساب فوري', AppColors.primary),
              ],
            ),
            const SizedBox(height: 12),
            _SpecsCards(controller: controller),
            const SizedBox(height: AppSizes.space16),
            _CostCard(controller: controller),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(controller: controller, onSubmit: () => _submit(controller)),
    );
  }

  static Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final String? title;

  const _Card({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _CenterInfo extends StatelessWidget {
  final Map<String, dynamic> center;

  const _CenterInfo({required this.center});

  @override
  Widget build(BuildContext context) {
    final rating = (center['averageRating'] ?? 0).toDouble();
    final isVerified = center['verificationStatus'] == 'verified';
    final String closing = center['closingTime'] ?? '';

    return _Card(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.print_outlined, color: AppColors.primary, size: 26),
                  ),
                  if (isVerified)
                    const PositionedDirectional(
                      bottom: -4,
                      start: -4,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.white,
                        child: Icon(Icons.verified, size: 16, color: AppColors.success),
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
                      center['businessName'] ?? '',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.3),
                    ),
                    Text(
                      center['headline'] ?? '',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.space8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (rating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  if (isVerified) ...[
                    const SizedBox(height: 6),
                    PrintOrderScreen._chip('معتمد', AppColors.secondary),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.primary),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  center['addressDetails'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              if (closing.isNotEmpty) ...[
                const Icon(Icons.schedule, size: 15, color: AppColors.success),
                const SizedBox(width: 2),
                Text(
                  'مفتوح حتى ${ProviderFormat.time12h(closing)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.success),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final PrintOrderController controller;

  const _FileCard({required this.controller});

  void _showFileDialog() {
    final nameController = TextEditingController(text: controller.fileName.value);
    final urlController = TextEditingController(text: controller.fileUrl.value);
    final pagesController = TextEditingController(
      text: controller.pages.value == 0 ? '' : '${controller.pages.value}',
    );

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
                'الملف المراد طباعته',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.space16),
              _input(nameController, 'اسم الملف', 'مشروع_تخرج_هندسة_البرمجيات', Icons.description_outlined),
              const SizedBox(height: 12),
              _input(
                urlController,
                'رابط الملف (Google Drive...)',
                'https://drive.google.com/...',
                Icons.link,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              _input(
                pagesController,
                'عدد الصفحات',
                '74',
                Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSizes.space24),
              AppPrimaryButton(
                text: 'حفظ',
                onPressed: () {
                  final pages = int.tryParse(pagesController.text) ?? 0;
                  if (nameController.text.trim().isEmpty || pages <= 0) {
                    Get.snackbar('تنبيه', 'اكتب اسم الملف وعدد صفحاته');
                    return;
                  }
                  controller.setFile(
                    name: nameController.text.trim(),
                    url: urlController.text.trim(),
                    pageCount: pages,
                  );
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
      TextEditingController textController,
      String label,
      String hint,
      IconData icon, {
        TextInputType? keyboardType,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: textController,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceSubdued,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Obx(() {
        final hasFile = controller.fileName.value.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSizes.space8),
                const Expanded(
                  child: Text(
                    'الملف المراد طباعته',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                if (hasFile) PrintOrderScreen._chip('جاهز للمعالجة', AppColors.success),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showFileDialog,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.error),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasFile ? controller.fileName.value : 'اضغط لإضافة الملف',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            hasFile ? '${controller.pages.value} صفحة' : 'اسم الملف وعدد صفحاته',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.white,
                      child: Icon(
                        hasFile ? Icons.sync : Icons.add,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SpecsCards extends StatelessWidget {
  final PrintOrderController controller;

  const _SpecsCards({required this.controller});

  @override
  Widget build(BuildContext context) {
    final money = PrintOrderController.money;

    return Obx(
          () => Column(
        children: [
          _Card(
            title: 'نوع الورق والوزن',
            child: Row(
              children: [
                _option(
                  isSelected: controller.paper.value == 'normal',
                  title: 'ورق عادي',
                  subtitle: '80 غرام A4',
                  footer: 'افتراضي',
                  onTap: () => controller.paper.value = 'normal',
                ),
                const SizedBox(width: 10),
                _option(
                  isSelected: controller.paper.value == 'thick',
                  title: 'ورق سميك',
                  subtitle: '120 غرام',
                  footer: '+${money(controller.thickExtra)}',
                  onTap: () => controller.paper.value = 'thick',
                ),
                const SizedBox(width: 10),
                _option(
                  isSelected: controller.paper.value == 'glossy',
                  title: 'كوشيه لامع',
                  subtitle: '150 غرام فاخر',
                  footer: '+${money(controller.glossyExtra)}',
                  onTap: () => controller.paper.value = 'glossy',
                ),
              ],
            ),
          ),
          _Card(
            title: 'نمط الطباعة والألوان',
            child: Row(
              children: [
                _colorOption(
                  isSelected: controller.colorMode.value == 'bw',
                  icon: Icons.contrast,
                  title: 'أبيض وأسود',
                  subtitle: 'واضح ونقي',
                  price: money(controller.bwPrice),
                  onTap: () => controller.colorMode.value = 'bw',
                ),
                const SizedBox(width: 10),
                _colorOption(
                  isSelected: controller.colorMode.value == 'color',
                  icon: Icons.palette_outlined,
                  title: 'ألوان ليزرية',
                  subtitle: 'دقة رسومات عالية',
                  price: money(controller.colorPrice),
                  onTap: () => controller.colorMode.value = 'color',
                ),
              ],
            ),
          ),
          _Card(
            title: 'خيارات التجليد والإخراج الأكاديمي',
            child: Column(
              children: [
                _bindingOption('none', 'بدون تجليد', 'تدبيس زاوي مجاني', 0),
                _bindingOption('spiral', 'سلك معدني حلزوني', 'غلاف شفاف أمامي وأسود خلفي', controller.spiralPrice),
                _bindingOption('thermal', 'تجليد حراري مقوى', 'كعب حراري احترافي للبحوث', controller.thermalPrice),
                _bindingOption(
                  'hardcover',
                  'كرتون مقوى فاخر (هاردكفر)',
                  'طباعة ذهبية منقوشة بالاسم',
                  controller.hardCoverPrice,
                  badge: 'مشاريع تخرج',
                ),
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _copiesCard()),
                const SizedBox(width: 12),
                Expanded(child: _pickupCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _option({
    required bool isSelected,
    required String title,
    required String subtitle,
    required String footer,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSubdued,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(
                footer,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorOption({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSubdued,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: isSelected ? AppColors.primary : AppColors.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bindingOption(String value, String title, String subtitle, double price, {String? badge}) {
    final isSelected = controller.binding.value == value;

    return GestureDetector(
      onTap: () => controller.binding.value = value,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (badge != null) ...[
              PrintOrderScreen._chip(badge, AppColors.secondary),
              const SizedBox(width: AppSizes.space8),
            ],
            Text(
              price == 0 ? PrintOrderController.money(0) : '+${PrintOrderController.money(price)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: price == 0
                    ? AppColors.textPrimary
                    : (isSelected ? AppColors.primary : AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _copiesCard() {
    return _Card(
      title: 'عدد النسخ المطلوبة',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _stepButton(Icons.add, controller.increaseCopies),
            Expanded(
              child: Text(
                '${controller.copies.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            _stepButton(Icons.remove, controller.decreaseCopies),
          ],
        ),
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _pickupCard() {
    return _Card(
      title: 'طريقة الاستلام',
      child: Column(
        children: [
          _pickupOption('store', 'استلام من المكتبة', 'مجانًا'),
          if (controller.offersDelivery) ...[
            const SizedBox(height: AppSizes.space8),
            _pickupOption(
              'delivery',
              'بوابة الجامعة / السكن',
              controller.deliveryFee == 0 ? 'مجانًا' : '+${PrintOrderController.money(controller.deliveryFee)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _pickupOption(String value, String title, String price) {
    final isSelected = controller.pickup.value == value;

    return GestureDetector(
      onTap: () => controller.pickup.value = value,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            Text(price, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final PrintOrderController controller;

  const _CostCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final money = PrintOrderController.money;

    return Obx(
          () => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: AppSizes.space8),
                const Expanded(
                  child: Text(
                    'تفاصيل التكلفة المحسوبة',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                if (controller.discountPercent > 0)
                  PrintOrderScreen._chip('خصم خطوتي الجامعي مفعّل', AppColors.success),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            _line(
              'طباعة ${controller.pages.value} صفحة (${controller.colorLabel}):',
              money(controller.printingCost),
            ),
            if (controller.bindingCost > 0)
              _line(
                '${controller.bindingLabel} (${controller.copies.value} نسخ):',
                money(controller.bindingCost),
              ),
            if (controller.deliveryCost > 0)
              _line('توصيل لبوابة الجامعة / السكن:', money(controller.deliveryCost)),
            if (controller.discountPercent > 0)
              _line(
                'خصم الطالب الجامعي (${controller.discountPercent}%):',
                '-${money(controller.discountAmount)}',
                color: AppColors.success,
                icon: Icons.sell_outlined,
              ),
            const Divider(height: 28, color: AppColors.border),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإجمالي النهائي المستحق:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'شامل الضريبة والطباعة الفورية',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  ProviderFormat.number(controller.total, decimals: 2),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  ' شيكل',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value, {Color color = AppColors.textPrimary, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: AppSizes.space4),
          ],
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: color))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final PrintOrderController controller;
  final VoidCallback onSubmit;

  const _BottomBar({required this.controller, required this.onSubmit});

  void _showPaymentSheet(PrintOrderController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.space24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر طريقة الدفع',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSizes.space16),
                ...PrintOrderController.paymentMethods.entries.map((method) {
                  final isEnabled = PrintOrderController.enabledPaymentMethods.contains(method.key);
                  final isSelected = controller.paymentMethod.value == method.key;

                  return Opacity(
                    opacity: isEnabled ? 1 : 0.5,
                    child: GestureDetector(
                      onTap: isEnabled
                          ? () {
                        controller.paymentMethod.value = method.key;
                        Get.back();
                      }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                method.value,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (!isEnabled) PrintOrderScreen._chip('قريبًا', AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSizes.space4),
                const Text(
                  'الدفع الإلكتروني عبر المحافظ والتحويل البنكي سيتوفر قريبًا.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.space24, 12, AppSizes.space24, 12),
      color: AppColors.scaffoldBg,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showPaymentSheet(controller),
              child: Obx(
                    () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'طريقة الدفع:',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Row(
                      children: [
                        Icon(
                          controller.paymentMethod.value == 'cash'
                              ? Icons.payments_outlined
                              : Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSizes.space4),
                        Text(
                          controller.paymentLabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                    () => AppPrimaryButton(
                  text: 'تأكيد طلب الطباعة الفوري',
                  icon: Icons.add_shopping_cart,
                  isLoading: controller.isSubmitting.value,
                  onPressed: onSubmit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}