import '../models/auth_models.dart';
import '../models/auth_result.dart';
import 'auth_service.dart';

/// Mock implementation of [AuthService] for local development and testing.
///
/// Stores users and sessions in memory only (data resets when app restarts).
/// In line with security guidelines (SRS NFR-09), this class never logs
/// passwords or tokens.
class MockAuthService implements AuthService {
  /// Sample accounts and triggers for testing.
  static const String testUserEmail = 'student@test.local';
  static const String testUserPassword = 'ValidPass123';
  static const String duplicateEmailTrigger = 'existing@test.local';
  static const String networkErrorEmailTrigger = 'network-error@test.local';

  final Duration simulatedDelay;

  final Map<String, _MockUserRecord> _usersByEmail = {};
  User? _currentUser;

  MockAuthService({this.simulatedDelay = const Duration(milliseconds: 100)}) {
    _seedDefaultFixtures();
  }

  void _seedDefaultFixtures() {
    _usersByEmail.clear();
    _currentUser = null;

    final defaultStudent = _MockUserRecord(
      user: const User(
        id: 'usr-student-001',
        name: 'Test Student',
        email: testUserEmail,
        phoneNumber: '+970599000001',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: UserCategory.universityStudent,
      ),
      password: testUserPassword,
    );

    _usersByEmail[defaultStudent.user.email.toLowerCase()] = defaultStudent;

    _usersByEmail[duplicateEmailTrigger.toLowerCase()] = _MockUserRecord(
      user: const User(
        id: 'usr-existing-002',
        name: 'Existing Account',
        email: duplicateEmailTrigger,
        phoneNumber: '+970599000002',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: UserCategory.graduate,
      ),
      password: 'ExistingPassword123',
    );
  }

  /// Resets test accounts and active session (useful for tests).
  void reset() {
    _seedDefaultFixtures();
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final trimmedEmail = request.email.trim();

    // Simulate network error when using the trigger email
    if (trimmedEmail.toLowerCase() == networkErrorEmailTrigger) {
      return const AuthFailure(
        errorType: AuthErrorType.network,
        message: 'Network connection failed. Please check your connection.',
      );
    }

    // Check required fields
    if (trimmedEmail.isEmpty || request.password.isEmpty) {
      return const AuthFailure(
        errorType: AuthErrorType.invalidCredentials,
        message: 'Invalid email or password.',
      );
    }

    final record = _usersByEmail[trimmedEmail.toLowerCase()];
    if (record == null || record.password != request.password) {
      // Keep error message generic so we don't reveal if the email exists
      return const AuthFailure(
        errorType: AuthErrorType.invalidCredentials,
        message: 'Invalid email or password.',
      );
    }

    _currentUser = record.user;
    return AuthSuccess(
      AuthResponse(token: 'mock-token-${record.user.id}', user: record.user),
    );
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final trimmedEmail = request.email.trim();

    // Simulate network error when using the trigger email
    if (trimmedEmail.toLowerCase() == networkErrorEmailTrigger) {
      return const AuthFailure(
        errorType: AuthErrorType.network,
        message: 'Network connection failed. Please check your connection.',
      );
    }

    // Validate required fields (SRS FR-004 & Milestones US-04)
    final fieldErrors = <String, List<String>>{};

    if (request.name.trim().isEmpty) {
      fieldErrors['name'] = ['Name is required.'];
    }

    if (trimmedEmail.isEmpty) {
      fieldErrors['email'] = ['Email address is required.'];
    } else if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      fieldErrors['email'] = ['Please enter a valid email address.'];
    }

    if (request.phoneNumber.trim().isEmpty) {
      fieldErrors['phoneNumber'] = ['Phone number is required.'];
    }

    if (request.password.isEmpty) {
      fieldErrors['password'] = ['Password is required.'];
    }

    if (request.confirmPassword.isEmpty) {
      fieldErrors['confirmPassword'] = ['Password confirmation is required.'];
    } else if (request.password != request.confirmPassword) {
      fieldErrors['confirmPassword'] = ['Passwords do not match.'];
    }

    // Validate category based on account type
    if (request.primaryType == PrimaryAccountType.individualUser &&
        request.userCategory == null) {
      fieldErrors['userCategory'] = [
        'User category is required for individual accounts.',
      ];
    }

    if (request.primaryType == PrimaryAccountType.serviceProvider &&
        request.providerCategory == null) {
      fieldErrors['providerCategory'] = [
        'Provider category is required for provider accounts.',
      ];
    }

    if (fieldErrors.isNotEmpty) {
      return AuthFailure(
        errorType: AuthErrorType.validation,
        message: 'Validation failed. Please correct the highlighted errors.',
        fieldErrors: fieldErrors,
      );
    }

    // Check if email is already taken
    if (_usersByEmail.containsKey(trimmedEmail.toLowerCase())) {
      return const AuthFailure(
        errorType: AuthErrorType.conflict,
        message: 'An account with this email address already exists.',
        fieldErrors: {
          'email': ['This email address is already registered.'],
        },
      );
    }

    final newUser = User(
      id: 'usr-new-${DateTime.now().millisecondsSinceEpoch}',
      name: request.name.trim(),
      email: trimmedEmail,
      phoneNumber: request.phoneNumber.trim(),
      primaryType: request.primaryType,
      userCategory: request.userCategory,
      providerCategory: request.providerCategory,
    );

    _usersByEmail[trimmedEmail.toLowerCase()] = _MockUserRecord(
      user: newUser,
      password: request.password,
    );

    _currentUser = newUser;
    return AuthSuccess(
      AuthResponse(token: 'mock-token-${newUser.id}', user: newUser),
    );
  }

  @override
  Future<void> logout() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return _currentUser;
  }
}

class _MockUserRecord {
  final User user;
  final String password;

  const _MockUserRecord({required this.user, required this.password});
}
