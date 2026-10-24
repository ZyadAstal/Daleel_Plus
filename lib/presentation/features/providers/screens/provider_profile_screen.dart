import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../state/provider_helpers.dart';
import '../state/provider_profile_controller.dart';
import '../widgets/provider_bottom_nav.dart';
import '../widgets/profile_settings_sheets.dart';
import '../widgets/provider_top_bar.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderProfileController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.topBarHeight),
        child: Obx(
              () => ProviderTopBar(
            title: 'الملف الشخصي',
            showBack: false,
            isVerified: controller.isVerified,
            isAvailable: controller.isAvailable,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // إذا صار خطأ: بعد تجهيز شاشة 42 من app_status استبدلي السطر الحالي بـ:
        // if (controller.errorMessage.value.isNotEmpty) {
        //   return const UnexpectedErrorScreen(); // شاشة 42 من app_status
        // }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(controller: controller),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.space24),
                    const _ActionButtons(),
                    const SizedBox(height: AppSizes.space24),
                    _StatsRow(controller: controller),
                    const SizedBox(height: AppSizes.space24),
                    _CenterInfoCard(controller: controller),
                    const SizedBox(height: AppSizes.space24),
                    _PublishedServices(controller: controller),
                    const SizedBox(height: AppSizes.space24),
                    _InstructorsCard(controller: controller),
                    const SizedBox(height: AppSizes.space24),
                    _WalletCard(controller: controller),
                    const SizedBox(height: AppSizes.space24),
                    _SettingsCard(controller: controller),
                    const SizedBox(height: AppSizes.space24),
                    const Center(
                      child: Text(
                        'منظومة دليل+ للخدمات الأكاديمية والمهنية • إصدار النسخة المعتمدة v1.0.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: AppColors.textHint),
                      ),
                    ),
                    const SizedBox(height: AppSizes.bottomNavGap),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 3),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProviderProfileController controller;

  const _ProfileHeader({required this.controller});

  static const double _coverHeight = 220;
  static const double _logoSize = 112;

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: _coverHeight + _logoSize / 2,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _coverHeight,
                  child: _cover(controller.field('coverImageUrl')),
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _coverHeight + 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x00FAF9FF), Color(0x80FAF9FF), AppColors.scaffoldBg],
                        stops: [0.7, 0.88, 0.99],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                _logo(controller.field('logoUrl')),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            controller.field('businessName'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.space4),
          Text(
            controller.field('headline'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.space4),
              Text(
                controller.location,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          _ratingChip(),
        ],
      ),
    );
  }

  Widget _cover(String url) {
    const placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B4FD8), Color(0xFFB9A8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _logo(String url) {
    return Stack(
      children: [
        Container(
          width: _logoSize,
          height: _logoSize,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.surfaceSubdued,
            backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
            child: url.isEmpty
                ? const Icon(Icons.school, size: 44, color: AppColors.primary)
                : null,
          ),
        ),
        if (controller.isVerified)
          const PositionedDirectional(
            bottom: 2,
            end: 2,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.success,
                child: Icon(Icons.verified, color: AppColors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _ratingChip() {
    final hasReviews = controller.reviewsCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
          const SizedBox(width: AppSizes.space4),
          if (hasReviews)
            Text(
              '${controller.rating.toStringAsFixed(1)} ',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          Text(
            controller.ratingText,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.circle, size: 5, color: AppColors.textHint),
          ),
          const Icon(Icons.auto_stories_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSizes.space4),
          Text(
            '${controller.publishedCourses.length} خدمات ودورات نشطة',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _button(
            text: 'تعديل الملف',
            icon: Icons.edit_note,
            background: AppColors.primary,
            foreground: AppColors.white,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: AppSizes.space16),
        Expanded(
          child: _button(
            text: 'مشاركة الرابط',
            icon: Icons.share_outlined,
            background: AppColors.white,
            foreground: AppColors.textPrimary,
            iconColor: AppColors.primary,
            shadowColor: AppColors.primary.withValues(alpha: 0.08),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _button({
    required String text,
    required IconData icon,
    required Color background,
    required Color foreground,
    required Color shadowColor,
    Color? iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: iconColor ?? foreground),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ProviderProfileController controller;

  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Row(
        children: [
          _statBox(
            icon: Icons.school_outlined,
            iconColor: AppColors.primary,
            background: AppColors.surfaceSubdued,
            value: ProviderFormat.number(controller.studentsCount.value),
            label: 'طالب مسجل',
          ),
          const SizedBox(width: 12),
          _statBox(
            icon: Icons.task_alt,
            iconColor: AppColors.secondary,
            background: AppColors.secondary.withValues(alpha: 0.2),
            value: ProviderFormat.number(controller.completedOrders.value),
            label: 'حجز مكتمل',
          ),
          const SizedBox(width: 12),
          _statBox(
            icon: Icons.sentiment_satisfied_alt,
            iconColor: AppColors.success,
            background: AppColors.success.withValues(alpha: 0.15),
            value: controller.satisfactionText,
            label: 'نسبة الرضا',
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required Color iconColor,
    required Color background,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: background,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CenterInfoCard extends StatelessWidget {
  final ProviderProfileController controller;

  const _CenterInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bio = controller.field('bioDescription');
      final address = controller.field('addressDetails');

      return _ProfileCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionIcon(icon: Icons.verified_user_outlined),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'بيانات المركز والاعتماد الأكاديمي',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSizes.space8),
                controller.isVerified
                    ? _Badge(
                  text: 'ساري المفعول',
                  color: AppColors.success,
                  background: AppColors.success.withValues(alpha: 0.15),
                )
                    : _Badge(
                  text: 'بانتظار التوثيق',
                  color: AppColors.secondary,
                  background: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              bio.isEmpty ? 'لم تتم إضافة نبذة عن المركز بعد.' : bio,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.7),
            ),
            const SizedBox(height: AppSizes.space16),
            Row(
              children: [
                _infoBox('رقم السجل التجاري:', controller.field('commercialRegisterOrPortfolio')),
                const SizedBox(width: 12),
                _infoBox('ترخيص التعليم العالي:', controller.field('licenseNumber')),
              ],
            ),
            const SizedBox(height: AppSizes.space16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.location_on_outlined, size: 18, color: AppColors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.isEmpty ? 'لم يُضف العنوان التفصيلي بعد' : address,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${controller.field('city')}، فلسطين',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _infoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.space4),
            Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishedServices extends StatelessWidget {
  final ProviderProfileController controller;

  const _PublishedServices({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final courses = controller.publishedCourses;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSizes.space8),
              const Expanded(
                child: Text(
                  'الخدمات والدورات المنشورة',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'عرض الكل (${courses.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          _ProfileCard(
            child: courses.isEmpty
                ? const Text(
              'لا توجد خدمات منشورة بعد',
              style: TextStyle(color: AppColors.textSecondary),
            )
                : _courseItem(courses.first),
          ),
        ],
      );
    });
  }

  Widget _courseItem(Map<String, dynamic> course) {
    final String image = course['coverImageUrl'] ?? '';
    final String category = course['categorySubtag'] ?? '';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image.isEmpty
                  ? Container(
                width: 80,
                height: 80,
                color: AppColors.surfaceSubdued,
                child: const Icon(Icons.image_outlined, color: AppColors.textHint),
              )
                  : Image.network(image, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (category.isNotEmpty)
                        _Badge(
                          text: category,
                          color: AppColors.primary,
                          background: AppColors.surfaceSubdued,
                        ),
                      const Spacer(),
                      const Icon(Icons.circle, size: 7, color: AppColors.success),
                      const SizedBox(width: AppSizes.space4),
                      const Text(
                        'متاح للتسجيل',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course['title'] ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    course['description'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'رسوم التسجيل:',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          ProviderFormat.price(
                            course['discountedPrice'] ?? course['originalPrice'],
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space16),
        Row(
          children: [
            Expanded(
              child: _softButton(
                text: 'معاينة للطلبة',
                icon: Icons.visibility_outlined,
                background: AppColors.surfaceSubdued,
                foreground: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _softButton(
                text: 'إدارة الحصص',
                icon: Icons.tune,
                background: AppColors.surfaceSubdued,
                foreground: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _softButton({
    required String text,
    required IconData icon,
    required Color background,
    required Color foreground,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InstructorsCard extends StatelessWidget {
  final ProviderProfileController controller;

  const _InstructorsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final instructors = controller.instructors;

      return _ProfileCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _SectionIcon(icon: Icons.groups_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'إدارة المدربين والمشرفين (${instructors.length})',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceSubdued,
                    child: Icon(Icons.person_add_alt, color: AppColors.primary, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space8),
            if (instructors.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppSizes.space8),
                child: Text(
                  'لم تتم إضافة مدربين بعد',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ...instructors.map(_instructorTile),
          ],
        ),
      );
    });
  }

  Widget _instructorTile(Map<String, dynamic> instructor) {
    final String avatar = instructor['avatarUrl'] ?? '';
    final bool isActive = instructor['isActive'] ?? false;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.white,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructor['name'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                Text(
                  instructor['title'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          isActive
              ? _Badge(
            text: 'نشط',
            color: AppColors.success,
            background: AppColors.success.withValues(alpha: 0.15),
          )
              : const _Badge(
            text: 'متوقف',
            color: AppColors.textSecondary,
            background: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final ProviderProfileController controller;

  const _WalletCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bank = controller.field('payoutBankName');

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4826C5), Color(0xFF5A3ED7), Color(0xFF1E0665)],
            stops: [0.0, 0.45, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.white,
                        size: 22,
                      ),
                      const SizedBox(width: AppSizes.space8),
                      const Expanded(
                        child: Text(
                          'المحفظة والأرباح المتاحة',
                          style: TextStyle(fontSize: 16, color: AppColors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          bank.isEmpty ? 'لم يُربط حساب بنكي' : 'حساب $bank',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الرصيد القابل للسحب الفوري:',
                              style: TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                            const SizedBox(height: AppSizes.space4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${ProviderFormat.number(controller.availableBalance.value, decimals: 2)} ₪',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: const Text('سحب الأرباح'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 6,
                          shadowColor: AppColors.secondary.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                border: Border(
                  top: BorderSide(color: AppColors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.lastPayoutText,
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'سجل الحركات المالية',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SettingsCard extends StatelessWidget {
  final ProviderProfileController controller;

  const _SettingsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final whatsapp = controller.field('whatsappNumber');

      return _ProfileCard(
        child: Column(
          children: [
            const Row(
              children: [
                _SectionIcon(icon: Icons.settings_suggest_outlined),
                SizedBox(width: 12),
                Text(
                  'إعدادات الحساب وسياسات المركز',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space8),
            _settingRow(
              icon: Icons.schedule,
              title: 'ساعات العمل وتلقي الحجوزات',
              subtitle: controller.workingHoursText,
              onTap: () => showWorkingHoursSheet(controller),
            ),
            _settingRow(
              icon: Icons.policy_outlined,
              title: 'سياسة الإلغاء واسترداد الرسوم',
              subtitle: controller.cancellationText,
              onTap: () => showCancellationSheet(controller),
            ),
            _settingRow(
              icon: Icons.support_agent,
              iconColor: whatsapp.isEmpty ? AppColors.textPrimary : AppColors.success,
              title: 'ربط الواتساب للدعم الفوري للطلبة',
              subtitle: whatsapp.isEmpty ? 'غير مربوط' : '$whatsapp (متصل)',
              subtitleColor: whatsapp.isEmpty ? AppColors.textSecondary : AppColors.success,
              onTap: () => showWhatsappSheet(controller),
            ),
            const SizedBox(height: AppSizes.space8),
            Material(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => showLogoutDialog(controller),
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تسجيل الخروج من الحساب',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.error),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppColors.textPrimary,
    Color subtitleColor = AppColors.textSecondary,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: subtitleColor)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Widget child;

  const _ProfileCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _SectionIcon extends StatelessWidget {
  final IconData icon;

  const _SectionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.surfaceSubdued,
      child: Icon(icon, color: AppColors.primary, size: 18),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;

  const _Badge({required this.text, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}