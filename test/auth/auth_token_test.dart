import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class TokenUser extends Fake implements User {
  final calls = <String>[];
  bool verified = false;
  @override
  String get uid => 'user-id';
  @override
  bool get emailVerified => verified;
  @override
  Future<void> reload() async {
    calls.add('reload');
    verified = true;
  }

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    calls.add('token:$forceRefresh');
    return 'test-token';
  }
}

class TokenAuth extends Fake implements FirebaseAuth {
  TokenAuth(this.user);
  final TokenUser user;
  @override
  User get currentUser => user;
}

class TokenStore extends Fake implements FirebaseFirestore {
  TokenStore(this.calls);
  final List<String> calls;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    calls.add('firestore:$path');
    throw StateError('Stop before network access');
  }
}

void main() {
  test(
    'Verification refreshes token after reloading the verified user',
    () async {
      final user = TokenUser();
      final service = FirebaseAuthRepository(
        auth: TokenAuth(user),
        firestore: TokenStore(user.calls),
      );
      expect(await service.refreshEmailVerification(), isTrue);
      expect(user.calls, ['reload', 'token:true']);
    },
  );
  test('Profile access refreshes claims before contacting Firestore', () async {
    final user = TokenUser();
    final service = FirebaseAuthRepository(
      auth: TokenAuth(user),
      firestore: TokenStore(user.calls),
    );
    await expectLater(service.loadProfile(), throwsStateError);
    expect(user.calls, ['token:true', 'firestore:users']);
  });
}
