import 'package:daleel_plus/presentation/features/auth/state/auth_controller.dart';
import 'package:daleel_plus/data/models/registration_options.dart';
import 'package:daleel_plus/data/repositories/session_preferences.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_token_test.dart' show TokenAuth, TokenStore, TokenUser;
import 'fake_auth_repository.dart';

class SessionCredential extends Fake implements UserCredential {}

class SessionAuth extends TokenAuth {
  SessionAuth(super.user);
  int signOuts = 0;
  @override
  Future<void> signOut() async {
    signOuts++;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => SessionCredential();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerTestAuth();
  for (final remember in [true, false]) {
    test('Session persists independently of remember = $remember', () async {
      SharedPreferences.setMockInitialValues({'remember_session': remember});
      final user = TokenUser();
      final auth = SessionAuth(user);
      final service = FirebaseAuthRepository(
        auth: auth,
        firestore: TokenStore(user.calls),
      );
      await service.restoreSession();
      await service.signIn(
        ' user@example.com ',
        'Secret123!',
        remember: remember,
      );
      expect(auth.signOuts, 0);
      expect(
        await SessionPreferences().rememberedEmail(),
        remember ? 'user@example.com' : null,
      );
      await service.signOut();
      expect(auth.signOuts, 1);
      expect(
        await SessionPreferences().rememberedEmail(),
        remember ? 'user@example.com' : null,
      );
      final stored = await SharedPreferences.getInstance();
      expect(
        stored.getKeys(),
        everyElement(
          isIn(['remember_session', SessionPreferences.rememberedEmailKey]),
        ),
      );
    });
  }
  test('Disabling remember removes the previously saved email', () async {
    await SessionPreferences().setRememberedEmail('previous@example.com');
    final user = TokenUser();
    final service = FirebaseAuthRepository(
      auth: SessionAuth(user),
      firestore: TokenStore(user.calls),
    );
    await service.signIn('new@example.com', 'Secret123!', remember: false);
    expect(await SessionPreferences().rememberedEmail(), isNull);
  });
  test('Login pre-fills saved email but never the password', () async {
    await SessionPreferences().setRememberedEmail('user@example.com');
    final controller = AuthController(
      register: false,
      completeProfile: false,
      passwordSetup: false,
      accountType: AccountType.universityStudent,
      editing: false,
    );
    controller.onStart();
    await Future<void>.delayed(Duration.zero);
    expect(controller.email.text, 'user@example.com');
    expect(controller.password.text, isEmpty);
    expect(controller.remember, isTrue);
    controller.onDelete();
  });
}
