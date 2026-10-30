import '../models/user_profile.dart';
import 'profile_repository.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:daleel_plus/data/repositories/session_preferences.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get session;
  bool get needsPassword;
  bool get needsEmailVerification;
  Future<void> sendEmailVerification();
  Future<bool> refreshEmailVerification();
  Future<void> setAccountPassword(String password);
  Future<void> signIn(String email, String password, {required bool remember});
  Future<void> register(String email, String password, UserProfile profile);
  Future<void> googleSignIn({bool remember = true});
  Future<void> resetPassword(String email);
  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> signOut();
}

class ProfileSaveFailure implements Exception {}

class FirebaseAuthRepository extends GetxService implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    ProfileRepository? profiles,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _profiles =
           profiles ??
           FirebaseProfileRepository(auth: auth, firestore: firestore);
  final FirebaseAuth _auth;
  final ProfileRepository _profiles;
  Future<void>? _googleInitialization;

  Future<void> restoreSession() async {
    if (kIsWeb) await _auth.setPersistence(Persistence.LOCAL);
  }

  Future<void> _rememberEmail(String? email, bool remember) =>
      SessionPreferences().setRememberedEmail(remember ? email : null);

  @override
  User? get currentUser => _auth.currentUser;
  @override
  Stream<User?> get session => _auth.userChanges();

  @override
  bool get needsPassword {
    final providers =
        currentUser?.providerData
            .map((provider) => provider.providerId)
            .toSet() ??
        <String>{};
    return providers.contains('google.com') && !providers.contains('password');
  }

  @override
  bool get needsEmailVerification =>
      currentUser != null && !currentUser!.emailVerified;

  @override
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    await user.sendEmailVerification();
  }

  @override
  Future<bool> refreshEmailVerification() async {
    final user = currentUser;
    if (user == null) return false;
    await user.reload();
    if (currentUser?.emailVerified == true) {
      await currentUser!.getIdToken(true);
    }
    return currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> setAccountPassword(String password) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    await user.linkWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    await user.reload();
  }

  @override
  Future<void> signIn(
    String email,
    String password, {
    required bool remember,
  }) async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _rememberEmail(email, remember);
  }

  @override
  Future<void> register(
    String email,
    String password,
    UserProfile profile,
  ) async {
    if (kIsWeb) await _auth.setPersistence(Persistence.LOCAL);
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await SessionPreferences().savePendingProfile(currentUser!.uid, profile);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _profiles.save(profile);
    await SessionPreferences().clearPendingProfile(currentUser!.uid);
  }

  @override
  Future<UserProfile?> loadProfile() async {
    final user = currentUser;
    if (user == null || !user.emailVerified) return null;
    final pending = await SessionPreferences().pendingProfile(user.uid);
    if (pending != null) await saveProfile(pending);
    return _profiles.load();
  }

  @override
  Future<void> googleSignIn({bool remember = true}) async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
      await _auth.signInWithPopup(
        GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'}),
      );
    } else {
      _googleInitialization ??= GoogleSignIn.instance.initialize();
      await _googleInitialization;
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) {
        throw FirebaseAuthException(code: 'invalid-credential');
      }
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: token),
      );
    }
    await _rememberEmail(currentUser?.email, remember);
  }

  @override
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb && _googleInitialization != null) {
      await GoogleSignIn.instance.signOut();
    }
  }
}

String authErrorMessage(Object error) {
  if (error is ProfileSaveFailure) {
    return 'تم إنشاء الحساب، لكن تعذّر حفظ الملف. يمكنك إكمال بياناتك من صفحة الحساب.';
  }
  if (error is PlatformException) {
    if (error.code == 'canceled' || error.code == 'sign_in_canceled') {
      return 'تم إلغاء تسجيل الدخول بجوجل.';
    }
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'email-already-in-use' =>
        'هذا البريد مسجل بالفعل. سجّل الدخول أو استعد كلمة المرور.',
      'invalid-email' => 'البريد الإلكتروني غير صحيح.',
      'weak-password' => 'كلمة المرور ضعيفة. استخدم كلمة أقوى.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'user-disabled' => 'هذا الحساب معطّل.',
      'requires-recent-login' => 'انتهت صلاحية جلسة التحقق. سجّل دخولك بجوجل مجددًا ثم عيّن كلمة المرور.',
      'credential-already-in-use' => 'هذا البريد مرتبط بحساب آخر. استخدم استعادة كلمة المرور أو سجّل الدخول بالحساب الصحيح.',
      'too-many-requests' => 'محاولات كثيرة. حاول لاحقًا.',
      'network-request-failed' ||
      'unavailable' => 'تعذّر الاتصال. تحقق من الإنترنت وحاول مجددًا.',
      'operation-not-allowed' => 'طريقة الدخول غير مفعّلة في Firebase.',
      'popup-closed-by-user' ||
      'cancelled-popup-request' => 'تم إلغاء تسجيل الدخول بجوجل.',
      'popup-blocked' => 'اسمح بالنافذة المنبثقة لتسجيل الدخول بجوجل.',
      'unauthorized-domain' =>
        'عنوان الويب الحالي غير مسموح في إعدادات Firebase.',
      'permission-denied' =>
        'تعذّر الوصول إلى بيانات الحساب. راجع صلاحيات Firestore.',
      _ => 'تعذّر تنفيذ الطلب. حاول مجددًا.',
    };
  }
  return 'تعذّر تنفيذ الطلب. تحقق من الاتصال وحاول مجددًا.';
}
