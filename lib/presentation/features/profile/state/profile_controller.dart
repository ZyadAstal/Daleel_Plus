import 'package:daleel_plus/presentation/features/auth/screens/auth_gate.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/data/models/registration_options.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_screen.dart';

class ProfileController extends GetxController {
  Map<String, dynamic>? profile;
  Object? error;
  bool loading = true;
  bool busy = false;
  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    loading = true;
    error = null;
    update();
    try {
      final profile = await Get.find<AuthRepository>().loadProfile();
      if (isClosed) return;
      this.profile = profile?.toJson();
    } catch (e) {
      if (isClosed) return;
      error = e;
    } finally {
      if (!isClosed) {
        loading = false;
        update();
      }
    }
  }

  Future<void> editProfile(
    Map<String, dynamic>? profile, {
    bool editing = false,
  }) async {
    await Get.to<bool>(
      () => AuthScreen(
        register: true,
        completeProfile: true,
        initialProfile: profile,
        editing: editing,
      ),
    );
    if (!isClosed) await loadProfile();
  }

  bool isComplete(Map<String, dynamic>? profile) {
    if (profile == null) return false;
    final code = profile['countryCode'];
    if (!phoneCountryCodes.contains(code)) return false;
    final phone = profile['phone'];
    if (phone is! String ||
        !RegExp('^${RegExp.escape(code as String)}[0-9]{9}\$')
            .hasMatch(phone)) {
      return false;
    }
    final fields = profile['accountType'] == 'provider'
        ? ['name', 'field', 'location']
        : ['name', 'university', 'specialization', 'interests'];
    if (profile['accountType'] == 'provider' &&
        !ProviderType.values.any(
          (type) => type.name == profile['providerType'],
        )) {
      return false;
    }
    if (!['individual', 'provider'].contains(profile['accountType'])) {
      return false;
    }
    return fields.every(
      (key) =>
          profile[key] is String && (profile[key] as String).trim().isNotEmpty,
    );
  }

  Future<void> signOut() async {
    if (busy) return;
    busy = true;
    update();
    try {
      await Get.find<AuthRepository>().signOut();
      if (!isClosed) Get.offAll<void>(() => const AuthGate());
    } catch (e) {
      if (!isClosed) AppSnackbar.show(authErrorMessage(e));
    } finally {
      if (!isClosed) {
        busy = false;
        update();
      }
    }
  }
}
