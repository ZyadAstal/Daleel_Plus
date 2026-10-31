import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_screen.dart';
import 'package:daleel_plus/presentation/features/onboarding/screens/welcome_screen.dart';
import 'package:daleel_plus/presentation/features/auth/screens/email_verification_screen.dart';
import 'package:daleel_plus/presentation/features/auth/state/auth_gate_controller.dart';

import 'package:daleel_plus/presentation/features/profile/screens/profile_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<AuthGateController>(
    init: AuthGateController(),
    global: false,
    dispose: (state) => state.controller?.onDelete(),
    builder: (c) {
      final service = Get.find<AuthRepository>();
      if (c.sessionError) {
        return MobilePage(
          child: Center(child: Text('تعذّر تحميل الجلسة. أعد فتح التطبيق.')),
        );
      }
      if (c.signedIn) {
        if (service.needsEmailVerification) {
          return EmailVerificationScreen();
        }
        return service.needsPassword
            ? AuthScreen(
                register: true,
                completeProfile: true,
                passwordSetup: true,
              )
            : ProfileScreen(openHome: true);
      }
      if (c.preferencesError) {
        return MobilePage(
          child: Center(
            child: TextButton(
              onPressed: c.loadPreferences,
              child: Text('تعذّر تحميل الإعدادات. إعادة المحاولة'),
            ),
          ),
        );
      }
      if (c.onboardingCompleted == null) {
        return MobilePage(child: Center(child: CircularProgressIndicator()));
      }
      return c.onboardingCompleted! ? AuthScreen() : WelcomeScreen();
    },
  );
}
