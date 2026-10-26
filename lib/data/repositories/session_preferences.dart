import 'package:shared_preferences/shared_preferences.dart';

class SessionPreferences {
  static const onboardingKey = 'onboarding_completed';
  static const rememberedEmailKey = 'remembered_email';

  Future<String?> rememberedEmail() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(rememberedEmailKey);
  }

  Future<void> setRememberedEmail(String? email) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = email == null
        ? await preferences.remove(rememberedEmailKey)
        : await preferences.setString(rememberedEmailKey, email.trim());
    if (!saved) {
      throw StateError('Could not persist remembered email');
    }
  }

  Future<bool> hasCompletedOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(onboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setBool(onboardingKey, true)) {
      throw StateError('Could not persist onboarding completion');
    }
  }
}
