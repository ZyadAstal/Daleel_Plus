/// Auth/profile data with separate UI and team Firestore mappings.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.countryCode,
    required this.accountType,
    this.providerType,
    this.university = '',
    this.specialization = '',
    this.interests = '',
    this.field = '',
    this.location = '',
    this.portfolio = '',
  });

  final String name;
  final String phone;
  final String countryCode;
  final String accountType;
  final String? providerType;
  final String university;
  final String specialization;
  final String interests;
  final String field;
  final String location;
  final String portfolio;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    countryCode: json['countryCode'] as String? ?? '',
    accountType: json['accountType'] as String? ?? '',
    providerType: json['providerType'] as String?,
    university: json['university'] as String? ?? '',
    specialization: json['specialization'] as String? ?? '',
    interests: json['interests'] as String? ?? '',
    field: json['field'] as String? ?? '',
    location: json['location'] as String? ?? '',
    portfolio: json['portfolio'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'countryCode': countryCode,
    'accountType': accountType,
    'providerType': providerType,
    'university': university,
    'specialization': specialization,
    'interests': interests,
    'field': field,
    'location': location,
    'portfolio': portfolio,
  };

  static const providerTypes = <String, String>{
    'education': 'training_center',
    'opportunities': 'company_employee',
    'printing': 'print_shop',
    'privateTutor': 'private_tutor',
  };

  Map<String, dynamic> toUserDocument() => {
    'fullname': name,
    'phone_number': phone,
    'user_role': accountType == 'provider' ? 'Provider' : 'Student',
  };

  Map<String, dynamic> toDetailsDocument() => accountType == 'provider'
      ? {
          'provider_type': providerTypes[providerType],
          'business_name': name,
          'headline': field,
          'city': location,
          'commercial_register_or_portfolio': portfolio.isEmpty
              ? null
              : portfolio,
        }
      : {
          'university_name': university,
          'major': specialization,
          'interests': interests,
          'city_location': location,
        };

  factory UserProfile.fromDocuments(
    Map<String, dynamic> user,
    Map<String, dynamic> details,
  ) {
    final phone = user['phone_number'] as String? ?? '';
    final provider = user['user_role'] == 'Provider';
    final storedType = details['provider_type'];
    String? providerType;
    for (final entry in providerTypes.entries) {
      if (entry.value == storedType) providerType = entry.key;
    }
    return UserProfile(
      name: user['fullname'] as String? ?? '',
      phone: phone,
      countryCode: phone.startsWith('+972') ? '+972' : '+970',
      accountType: provider ? 'provider' : 'individual',
      providerType: providerType,
      university: details['university_name'] as String? ?? '',
      specialization: details['major'] as String? ?? '',
      interests: details['interests'] as String? ?? '',
      field: details['headline'] as String? ?? '',
      location: details[provider ? 'city' : 'city_location'] as String? ?? '',
      portfolio: details['commercial_register_or_portfolio'] as String? ?? '',
    );
  }
}
