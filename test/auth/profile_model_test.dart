import 'package:daleel_plus/data/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Profile serialization keeps profile fields and excludes credentials/roles',
    () {
      final profile = UserProfile.fromJson({
        'name': 'Student',
        'phone': '+970591234567',
        'countryCode': '+970',
        'accountType': 'individual',
        'password': 'must-not-be-stored',
        'isAdmin': true,
        'uid': 'server-owned',
      });
      final data = profile.toJson();
      expect(data['name'], 'Student');
      expect(data['phone'], '+970591234567');
      expect(data['providerType'], isNull);
      expect(data['university'], isEmpty);
      expect(data.containsKey('password'), isFalse);
      expect(data.containsKey('isAdmin'), isFalse);
      expect(data.containsKey('uid'), isFalse);
    },
  );
}
