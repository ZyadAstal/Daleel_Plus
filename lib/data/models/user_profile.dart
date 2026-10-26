/// Profile fields owned by auth/profile in users/{Firebase Auth uid}.
/// Provider dashboard data in serviceProviders belongs to the providers feature.
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
}
