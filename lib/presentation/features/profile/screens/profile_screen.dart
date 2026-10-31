import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
import 'package:daleel_plus/presentation/shared/theme/app_text_styles.dart';
import 'package:daleel_plus/presentation/shared/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/profile/state/profile_controller.dart';
import 'package:daleel_plus/presentation/features/discovery/screens/student_home_screen.dart';
import 'package:daleel_plus/presentation/features/providers/screens/provider_dashboard_screen.dart';

import 'account_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool openHome;

  const ProfileScreen({super.key, this.openHome = false});
  @override
  Widget build(BuildContext context) => GetBuilder<ProfileController>(
    init: ProfileController(),
    global: false,
    dispose: (state) => state.controller?.onDelete(),
    builder: (c) {
      if (!c.loading && c.error == null && c.isComplete(c.profile)) {
        final isProvider = c.profile!['accountType'] == 'provider';
        if (openHome) {
          return isProvider
              ? const ProviderDashboardScreen()
              : const StudentHomeScreen();
        }
        // من تبويب حسابي: الطالب يشوف شاشة حسابي حسب التصميم
        if (!isProvider) return const AccountScreen();
      }
      return _render(context, c);
    },
  );
  Widget _render(BuildContext context, ProfileController c) => MobilePage(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSizes.space4 * 10),
          Icon(Icons.account_circle_outlined, size: AppSizes.bottomNavHeight),
          SizedBox(height: AppSizes.space16),
          Text(
            'حسابي',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading1.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            Get.find<AuthRepository>().currentUser?.email ?? '',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.space24),
          Builder(
            builder: (context) {
              if (c.loading) {
                return Center(child: CircularProgressIndicator());
              }
              if (c.error != null) {
                return Column(
                  children: [
                    Text(authErrorMessage(c.error!)),
                    TextButton(
                      onPressed: c.loadProfile,
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                );
              }
              if (!c.isComplete(c.profile)) {
                return Column(
                  children: [
                    Text('أكمل بيانات حسابك للاستفادة من خدمات دليل +.'),
                    SizedBox(height: AppSizes.space16),
                    AppPrimaryButton(
                      text: 'إكمال بيانات الحساب',
                      onPressed: () => c.editProfile(c.profile),
                    ),
                  ],
                );
              }
              final profile = c.profile!;
              return Column(
                children: [
                  Text(
                    profile['name'] as String? ?? '',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile['accountType'] == 'provider'
                        ? 'مقدّم خدمة'
                        : 'طالب / خريج',
                  ),
                  Text(
                    profile['phone'] as String? ?? '',
                    textDirection: TextDirection.ltr,
                  ),
                  SizedBox(height: AppSizes.space16),
                  AppPrimaryButton(
                    text: 'تعديل بيانات الحساب',
                    onPressed: () => c.editProfile(profile, editing: true),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppSizes.space4 * 8),
          OutlinedButton(
            onPressed: c.busy ? null : c.signOut,
            child: Text(c.busy ? 'جارٍ تسجيل الخروج...' : 'تسجيل الخروج'),
          ),
        ],
      ),
    ),
  );
}
