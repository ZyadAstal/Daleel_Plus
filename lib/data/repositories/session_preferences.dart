import 'dart:convert';

import '../models/user_profile.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SessionPreferences {
  static const onboardingKey = 'onboarding_completed';
  static const rememberedEmailKey = 'remembered_email';

  Future<void> savePendingProfile(String uid, UserProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(
      'pending_profile_$uid',
      jsonEncode(profile.toJson()),
    )) {
      throw StateError('Could not persist pending profile');
    }
  }

  Future<UserProfile?> pendingProfile(String uid) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString('pending_profile_$uid');
    return value == null
        ? null
        : UserProfile.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> clearPendingProfile(String uid) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('pending_profile_$uid');
  }

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
