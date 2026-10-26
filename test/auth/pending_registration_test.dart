import 'package:daleel_plus/data/models/user_profile.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/data/repositories/profile_repository.dart';
import 'package:daleel_plus/data/repositories/session_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingUser extends Fake implements User {
  bool verified = false;
  @override
  String get uid => 'pending-user';
  @override
  bool get emailVerified => verified;
}

class PendingAuth extends Fake implements FirebaseAuth {
  final user = PendingUser();
  @override
  User get currentUser => user;
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async => PendingCredential();
}

class PendingCredential extends Fake implements UserCredential {}

class RecordingProfiles implements ProfileRepository {
  UserProfile? profile;
  int saves = 0;
  @override
  Future<void> save(UserProfile value) async {
    saves++;
    profile = value;
  }

  @override
  Future<UserProfile?> load() async => profile;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Registration waits for verification and survives repository recreation',
    () async {
      final auth = PendingAuth();
      final profiles = RecordingProfiles();
      final service = FirebaseAuthRepository(auth: auth, profiles: profiles);
      const profile = UserProfile(
        name: 'Student',
        phone: '+970591234567',
        countryCode: '+970',
        accountType: 'individual',
      );
      await service.register('student@example.com', 'Password123!', profile);
      expect(profiles.saves, 0);
      expect(await service.loadProfile(), isNull);
      expect(profiles.saves, 0);
      expect(
        (await SessionPreferences().pendingProfile(auth.user.uid))?.name,
        'Student',
      );
      auth.user.verified = true;
      final restored = FirebaseAuthRepository(auth: auth, profiles: profiles);
      expect((await restored.loadProfile())?.name, 'Student');
      expect(profiles.saves, 1);
      expect(await SessionPreferences().pendingProfile(auth.user.uid), isNull);
      await restored.loadProfile();
      expect(profiles.saves, 1);
    },
  );
}
