/// Authentication and user models for Daleel+.
library;

/// Main account type: individual user or service provider.
enum PrimaryAccountType { individualUser, serviceProvider }

/// Sub-category for individual users.
enum UserCategory { universityStudent, graduate, otherIndividual }

/// Category for service providers.
enum ProviderCategory {
  privateTutor,
  libraryPrinting,
  educationCourse,
  jobTraining,
}

/// An authenticated user in the app.
class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final PrimaryAccountType primaryType;
  final UserCategory? userCategory;
  final ProviderCategory? providerCategory;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.primaryType,
    this.userCategory,
    this.providerCategory,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    PrimaryAccountType? primaryType,
    UserCategory? userCategory,
    ProviderCategory? providerCategory,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      primaryType: primaryType ?? this.primaryType,
      userCategory: userCategory ?? this.userCategory,
      providerCategory: providerCategory ?? this.providerCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.primaryType == primaryType &&
        other.userCategory == userCategory &&
        other.providerCategory == providerCategory;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    phoneNumber,
    primaryType,
    userCategory,
    providerCategory,
  );

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, primaryType: $primaryType, '
        'userCategory: $userCategory, providerCategory: $providerCategory)';
  }
}

/// Data required to log in.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(email, password);

  @override
  String toString() => 'LoginRequest(email: $email, password: [PROTECTED])';
}

/// Data required to register a new account.
class RegisterRequest {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final PrimaryAccountType primaryType;
  final UserCategory? userCategory;
  final ProviderCategory? providerCategory;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.primaryType,
    this.userCategory,
    this.providerCategory,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterRequest &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.password == password &&
        other.confirmPassword == confirmPassword &&
        other.primaryType == primaryType &&
        other.userCategory == userCategory &&
        other.providerCategory == providerCategory;
  }

  @override
  int get hashCode => Object.hash(
    name,
    email,
    phoneNumber,
    password,
    confirmPassword,
    primaryType,
    userCategory,
    providerCategory,
  );

  @override
  String toString() {
    return 'RegisterRequest(name: $name, email: $email, phoneNumber: $phoneNumber, '
        'primaryType: $primaryType, userCategory: $userCategory, '
        'providerCategory: $providerCategory, password: [PROTECTED])';
  }
}

/// Authentication response containing the token and user data.
class AuthResponse {
  final String token;
  final User user;

  const AuthResponse({required this.token, required this.user});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse && other.token == token && other.user == user;
  }

  @override
  int get hashCode => Object.hash(token, user);

  @override
  String toString() => 'AuthResponse(token: [PROTECTED], user: $user)';
}
