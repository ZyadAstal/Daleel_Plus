import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/data/repositories/session_preferences.dart';

class AuthGateController extends GetxController {
  StreamSubscription<User?>? subscription;
  bool signedIn = false;
  bool sessionError = false;
  bool? onboardingCompleted;
  bool preferencesError = false;

  @override
  void onInit() {
    super.onInit();
    final service = Get.find<AuthRepository>();
    signedIn = service.currentUser != null;
    subscription = service.session.listen(
      (user) {
        if (isClosed) return;
        signedIn = user != null;
        sessionError = false;
        update();
      },
      onError: (Object error) {
        if (isClosed) return;
        sessionError = true;
        update();
      },
    );
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    preferencesError = false;
    update();
    try {
      final completed = await SessionPreferences().hasCompletedOnboarding();
      if (isClosed) return;
      onboardingCompleted = completed;
    } catch (_) {
      if (isClosed) return;
      onboardingCompleted = false;
      preferencesError = false;
    } finally {
      if (!isClosed) update();
    }
  }

  @override
  void onClose() {
    subscription?.cancel();
    super.onClose();
  }
}
