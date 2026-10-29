import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../state/user_profile_controller.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            'دليل+',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {},
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSizes.space8),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space24,
              vertical: AppSizes.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Header Card
                _buildUserHeaderCard(controller),
                const SizedBox(height: AppSizes.space16),

                // 2. University / Academic Card
                _buildUniversityCard(controller),
                const SizedBox(height: AppSizes.space16),

                // 3. 3 Stats Cards Row
                _buildStatsRow(controller),
                const SizedBox(height: AppSizes.space24),

                // 4. Section 1: "الحساب والأكاديمية"
                _buildSectionHeader('الحساب والأكاديمية', 'الملف الطلابي'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _buildMenuItem(
                    icon: Icons.manage_accounts_outlined,
                    iconBg: const Color(0xFFEDE9FE),
                    iconColor: AppColors.primary,
                    title: 'تعديل البيانات الشخصية والأكاديمية',
                    subtitle: 'الاسم، الجامعة، التخصص، وسنة التخرج',
                    onTap: controller.navigateToEditProfile,
                  ),
                  _buildMenuItem(
                    icon: Icons.psychology_outlined,
                    iconBg: const Color(0xFFEDE9FE),
                    iconColor: AppColors.primary,
                    title: 'تعديل الإهتمامات والمهارات',
                    subtitle: 'مشاريع هندسة البرمجيات، تصميم، عرافة GitHub',
                    onTap: controller.navigateToEditProfile,
                  ),
                  _buildMenuItem(
                    icon: Icons.card_membership_outlined,
                    iconBg: const Color(0xFFEDE9FE),
                    iconColor: AppColors.primary,
                    title: 'شهاداتي والدورات المعتمدة',
                    subtitle: 'سجل الشهادات الأكاديمية والمهنية الموثقة',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: AppSizes.space24),

                // 5. Section 2: "المعاملات والمحفظة"
                _buildSectionHeader('المعاملات والمحفظة', 'المدفوعات والمكافآت'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFB45309),
                    title: 'محفظة الطالب ونقاط الخصم...',
                    subtitle: 'استبدل النقاط بخصومات للمكتبات والدورات',
                    trailingWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '340 نقطة',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                      ),
                    ),
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'سجل الفواتير والدفعات',
                    subtitle: 'إيصالات حجز الدروس، السكن، وخدمات الطباعة',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: AppSizes.space24),

                // 6. Section 3: "الإعدادات والدعم"
                _buildSectionHeader('الإعدادات والدعم', 'الخصوصية والمساعدة'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _buildMenuItem(
                    icon: Icons.notifications_active_outlined,
                    iconBg: const Color(0xFFEDE9FE),
                    iconColor: AppColors.primary,
                    title: 'تنبيهات وإشعارات التطبيق',
                    subtitle: 'إشعارات الحجزات، العروض، وأخبار الجامعة',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'الأمان وكلمة المرور',
                    subtitle: 'تحديث كلمة السر والتحقق بخطوتين',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.headset_mic_outlined,
                    iconBg: const Color(0xFFDCFCE7),
                    iconColor: const Color(0xFF15803D),
                    title: 'مساعدة ودعم الطلاب...',
                    subtitle: 'مساعدة فورية طوال أيام الأسبوع',
                    trailingWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'مباشر',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                          ),
                          SizedBox(width: 3),
                          Text(
                            'WhatsApp',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.policy_outlined,
                    iconBg: const Color(0xFFF3F4F6),
                    iconColor: AppColors.textSecondary,
                    title: 'الشروط وسياسة الخصوصية',
                    subtitle: 'اتفاقية استخدام منصة دليل+',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: AppSizes.space24),

                // 7. Logout Button
                Center(
                  child: TextButton.icon(
                    onPressed: controller.logout,
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                    label: const Text(
                      'تسجيل الخروج من حسابك',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Footer App Version
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'إصدار التطبيق 2.4.0',
                        style: TextStyle(fontSize: 11, color: AppColors.textHint),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'جميع الحقوق محفوظة لمنصة دليل+ ® 2026',
                        style: TextStyle(fontSize: 10, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserHeaderCard(UserProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Right Side (Leading in RTL): Avatar with Verified Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceSubdued,
                      child: const Icon(Icons.person, size: 32, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // 2. Center: Name + Student Badge + Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎓 حساب طالب موثق', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 3),
                    Text('غزة - الرمال', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),

          // 3. Left Side (Trailing in RTL): Edit Profile Icon Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubdued,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: controller.navigateToEditProfile,
              tooltip: 'تعديل الحساب',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityCard(UserProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  controller.university.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: Obx(
              () => Text(
                controller.faculty.value,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(
                    () => Text(
                      controller.academicLevel.value,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(
                    () => Text(
                      controller.gpaText.value,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProfileController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            value: '${controller.completedOrdersCount.value}',
            label: 'طلب وحجز مكتمل',
            icon: Icons.verified_outlined,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(
            value: '${controller.pointsCount.value}',
            label: 'نقطة تفوق وخصم',
            icon: Icons.star_rounded,
            iconColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(
            value: '${controller.favoritesCount.value}',
            label: 'عنصر بالمفضلة',
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.heading2),
          ],
        ),
        Text(subtitle, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trailingWidget != null) ...[
                          const SizedBox(width: 8),
                          trailingWidget,
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
