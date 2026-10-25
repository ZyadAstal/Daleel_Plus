import 'package:daleel_plus/data/models/user_profile.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/data/repositories/session_preferences.dart';
import 'package:daleel_plus/data/models/registration_options.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_screen.dart';
import 'package:daleel_plus/presentation/features/auth/screens/forgot_password_screen.dart';

class AuthController extends GetxController {
  AuthController({
    required this.register,
    required this.completeProfile,
    required this.passwordSetup,
    required this.accountType,
    this.providerType,
    this.initialProfile,
    required this.editing,
  }) : provider = accountType == AccountType.provider;

  final bool register;
  final bool completeProfile;
  final bool passwordSetup;
  final AccountType accountType;
  final Map<String, dynamic>? initialProfile;
  final bool editing;
  void change(VoidCallback action) {
    if (isClosed) return;
    action();
    update();
  }

  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  final email = TextEditingController();
  final fields = {
    for (final name in [
      'name',
      'phone',
      'field',
      'location',
      'portfolio',
      'university',
      'specialization',
      'interests',
    ])
      name: TextEditingController(),
  };
  bool busy = false;
  AuthRepository get service => Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    password.addListener(update);
    if (!register) _restoreRememberedEmail();
    if (completeProfile) email.text = service.currentUser?.email ?? '';
    final profile = initialProfile;
    if (profile != null) {
      for (final entry in fields.entries) {
        entry.value.text = profile[entry.key] as String? ?? '';
      }
      final code = profile['countryCode'] as String?;
      if (phoneCountryCodes.contains(code)) countryCode = code!;
      final phone = fields['phone']!.text;
      if (phone.startsWith(countryCode)) {
        fields['phone']!.text = phone.substring(countryCode.length);
      }
      provider = profile['accountType'] == 'provider';
      for (final type in ProviderType.values) {
        if (type.name == profile['providerType']) providerType = type;
      }
    }
  }

  bool provider;
  Future<void> _restoreRememberedEmail() async {
    try {
      final saved = await SessionPreferences().rememberedEmail();
      if (isClosed || email.text.isNotEmpty || saved == null) return;
      email.text = saved;
      remember = true;
      update();
    } catch (_) {
      // A saved email is optional; login remains available if storage fails.
    }
  }

  ProviderType? providerType;
  bool agreed = false;
  bool remember = false;
  String countryCode = '+970';
  bool get academic => accountType != AccountType.otherIndividual;

  @override
  void onClose() {
    email.dispose();
    for (final controller in fields.values) {
      controller.dispose();
    }
    password.dispose();
    super.onClose();
  }

  void notice(String message) => AppSnackbar.show(message);
  void finishAuthentication() => Get.offAll<void>(() => const AuthGate());
  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    if (register && !editing && !agreed) {
      notice('يرجى الموافقة على الشروط وسياسة الخصوصية أولًا.');
      return;
    }
    change(() => busy = true);
    try {
      if (register) {
        final dial = countryCode;
        final localPhone = fields['phone']!.text.replaceAll(
          RegExp(r'[\s-]'),
          '',
        );
        final profile = <String, dynamic>{
          for (final entry in fields.entries)
            entry.key: entry.value.text.trim(),
          'phone': '$dial$localPhone',
          'countryCode': dial,
          'accountType': provider ? 'provider' : 'individual',
          'providerType': provider ? providerType?.name : null,
        };
        if (provider) {
          profile['university'] = '';
          profile['specialization'] = '';
          profile['interests'] = '';
        } else {
          profile['field'] = '';
          profile['location'] = '';
          profile['portfolio'] = '';
        }
        if (completeProfile) {
          await service.saveProfile(UserProfile.fromJson(profile));
          if (passwordSetup && service.needsPassword) {
            await service.setAccountPassword(password.text);
          }
        } else {
          await service.register(
            email.text,
            password.text,
            UserProfile.fromJson(profile),
          );
        }
      } else {
        await service.signIn(email.text, password.text, remember: remember);
      }
      if (!isClosed) {
        notice(register ? 'تم حفظ حسابك بنجاح.' : 'تم تسجيل الدخول بنجاح.');
        if (editing) {
          Get.back(result: true, closeOverlays: true);
        } else {
          finishAuthentication();
        }
      }
    } catch (e) {
      if (!isClosed) {
        notice(authErrorMessage(e));
        if (e is ProfileSaveFailure) {
          finishAuthentication();
        }
      }
    } finally {
      if (!isClosed) change(() => busy = false);
    }
  }

  Future<void> googleSignIn() async {
    if (busy) return;
    change(() => busy = true);
    try {
      await service.googleSignIn(remember: remember);
      if (!isClosed) finishAuthentication();
    } catch (e) {
      if (!isClosed) notice(authErrorMessage(e));
    } finally {
      if (!isClosed) change(() => busy = false);
    }
  }

  void switchMode() => Get.off<void>(
    () => AuthScreen(register: !register),
    preventDuplicates: false,
  );

  void changeAccount(bool provider) {
    if (busy || this.provider == provider) return;
    Get.focusScope?.unfocus();
    form.currentState?.reset();
    password.clear();
    change(() {
      this.provider = provider;
      providerType = null;
      agreed = false;
    });
  }

  String providerLabel(ProviderType type) => switch (type) {
    ProviderType.education => 'مركز تدريب / أكاديمية',
    ProviderType.privateTutor => 'مدرس خصوصي معتمد',
    ProviderType.printing => 'مكتبة وخدمات طباعة',
    ProviderType.opportunities => 'شركة / جهة توظيف ومنح',
  };
  IconData providerIcon(ProviderType type) => switch (type) {
    ProviderType.education => Icons.school_outlined,
    ProviderType.privateTutor => Icons.people_outline,
    ProviderType.printing => Icons.menu_book_outlined,
    ProviderType.opportunities => Icons.work_outline,
  };

  void resetPassword() => Get.to<void>(() => const ForgotPasswordScreen());
}
