import 'package:daleel_plus/data/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Team documents use exact field names and provider values', () {
    const profile = UserProfile(
      name: 'Provider',
      phone: '+972591234567',
      countryCode: '+972',
      accountType: 'provider',
      providerType: 'printing',
      field: 'Printing',
      location: 'City',
    );
    expect(profile.toUserDocument(), {
      'fullname': 'Provider',
      'phone_number': '+972591234567',
      'user_role': 'Provider',
    });
    final details = profile.toDetailsDocument();
    expect(details['provider_type'], 'print_shop');
    expect(details.containsKey('providerType'), isFalse);
    final restored = UserProfile.fromDocuments(
      profile.toUserDocument(),
      details,
    );
    expect(restored.providerType, 'printing');
    expect(restored.countryCode, '+972');
    expect(restored.location, 'City');
    for (final type in UserProfile.providerTypes.entries) {
      final restored = UserProfile.fromDocuments(
        {'user_role': 'Provider'},
        {'provider_type': type.value},
      );
      expect(restored.providerType, type.key);
    }
  });
  test('Student document uses university_name and major', () {
    const profile = UserProfile(
      name: 'Student',
      phone: '+970591234567',
      countryCode: '+970',
      accountType: 'individual',
      university: 'University',
      specialization: 'CS',
    );
    expect(profile.toUserDocument()['user_role'], 'Student');
    expect(profile.toDetailsDocument()['university_name'], 'University');
    expect(profile.toDetailsDocument()['major'], 'CS');
    final restored = UserProfile.fromDocuments(
      profile.toUserDocument(),
      profile.toDetailsDocument(),
    );
    expect(restored.university, 'University');
    expect(restored.specialization, 'CS');
  });

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
