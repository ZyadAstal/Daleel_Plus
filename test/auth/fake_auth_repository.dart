import 'package:daleel_plus/data/models/user_profile.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestUser extends Fake implements User {
  @override
  String get uid => 'test-user';
  @override
  String? get email => 'student@example.com';
}

class FakeAuthRepository implements AuthRepository {
  @override
  User? currentUser;
  Map<String, dynamic>? profile;
  String? lastResetEmail;
  String? lastLoginEmail;
  Object? failure;
  @override
  bool needsPassword = false;
  @override
  bool needsEmailVerification = false;
  int verificationEmails = 0;
  int verificationChecks = 0;
  @override
  Future<void> sendEmailVerification() async {
    if (failure != null) throw failure!;
    verificationEmails++;
  }

  @override
  Future<bool> refreshEmailVerification() async {
    verificationChecks++;
    return !needsEmailVerification;
  }

  String? linkedPassword;
  @override
  Future<void> setAccountPassword(String password) async {
    if (failure != null) throw failure!;
    linkedPassword = password;
    needsPassword = false;
  }

  Future<void>? pending;
  @override
  Stream<User?> get session => const Stream.empty();
  @override
  Future<void> register(String email, String password, UserProfile data) async {
    if (pending != null) await pending;
    if (failure != null) throw failure!;
    currentUser = TestUser();
    profile = data.toJson();
  }

  @override
  Future<void> signIn(
    String email,
    String password, {
    required bool remember,
  }) async {
    lastLoginEmail = email;
    if (pending != null) await pending;
    if (failure != null) throw failure!;
    currentUser = TestUser();
    profile = {
      'name': 'طالب',
      'accountType': 'individual',
      'phone': '+970591234567',
    };
  }

  @override
  Future<void> googleSignIn({bool remember = true}) async {
    if (failure != null) throw failure!;
    currentUser = TestUser();
    needsPassword = true;
  }

  @override
  Future<void> resetPassword(String email) async {
    if (failure != null) throw failure!;
    lastResetEmail = email;
  }

  @override
  Future<UserProfile?> loadProfile() async =>
      profile == null ? null : UserProfile.fromJson(profile!);
  @override
  Future<void> saveProfile(UserProfile data) async {
    profile = data.toJson();
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
  }
}

void registerTestAuth() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.put<AuthRepository>(FakeAuthRepository());
  });
  tearDown(() async {
    Get.reset();
  });
}

Future<void> closeTestSnackbars(WidgetTester tester) async {
  while (Get.isSnackbarOpen) {
    final closed = Get.closeCurrentSnackbar();
    await tester.pumpAndSettle();
    await closed;
  }
}
