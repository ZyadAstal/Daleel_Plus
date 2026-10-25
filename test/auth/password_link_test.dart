import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class ProviderInfo extends Fake implements UserInfo {
  ProviderInfo(this.providerId);
  @override
  final String providerId;
}

class LinkedUser extends Fake implements User {
  @override
  String get uid => 'original-google-uid';
  @override
  String? get email => 'student@example.com';
  @override
  List<UserInfo> providerData = [ProviderInfo('google.com')];
  AuthCredential? linkedCredential;
  int reloadCount = 0;
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    linkedCredential = credential;
    providerData.add(ProviderInfo('password'));
    return LinkedCredential();
  }

  @override
  Future<void> reload() async {
    reloadCount++;
  }
}

class LinkedCredential extends Fake implements UserCredential {}

class TestFirebaseAuth extends Fake implements FirebaseAuth {
  TestFirebaseAuth(this.currentUser);
  @override
  final User? currentUser;
}

class TestFirestore extends Fake implements FirebaseFirestore {}

void main() {
  test('Password credential links to the existing Google user', () async {
    final user = LinkedUser();
    final service = FirebaseAuthRepository(
      auth: TestFirebaseAuth(user),
      firestore: TestFirestore(),
    );
    expect(service.needsPassword, isTrue);
    await service.setAccountPassword('Password123!');
    final credential = user.linkedCredential! as EmailAuthCredential;
    expect(credential.email, 'student@example.com');
    expect(credential.password, 'Password123!');
    expect(service.currentUser!.uid, 'original-google-uid');
    expect(user.reloadCount, 1);
    expect(service.needsPassword, isFalse);
  });
  test('Password setup rejects a signed-out session', () async {
    final service = FirebaseAuthRepository(
      auth: TestFirebaseAuth(null),
      firestore: TestFirestore(),
    );
    await expectLater(
      service.setAccountPassword('Password123!'),
      throwsA(
        isA<FirebaseAuthException>().having(
          (e) => e.code,
          'code',
          'requires-recent-login',
        ),
      ),
    );
  });
}
