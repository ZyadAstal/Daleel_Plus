import 'package:flutter_test/flutter_test.dart';

import 'package:daleel_plus/models/auth_models.dart';
import 'package:daleel_plus/models/auth_result.dart';
import 'package:daleel_plus/services/auth_service.dart';
import 'package:daleel_plus/services/mock_auth_service.dart';

void main() {
  group('MockAuthService Deterministic Scenarios Tests', () {
    late MockAuthService authService;

    setUp(() {
      // Set delay to zero so tests run immediately
      authService = MockAuthService(simulatedDelay: Duration.zero);
    });

    test('MockAuthService conforms to AuthService interface', () {
      expect(authService, isA<AuthService>());
    });

    test('Scenario 1: Login succeeds with valid credentials', () async {
      const request = LoginRequest(
        email: MockAuthService.testUserEmail,
        password: MockAuthService.testUserPassword,
      );

      final result = await authService.login(request);

      expect(result, isA<AuthSuccess>());
      final success = result as AuthSuccess;
      expect(
        success.response.user.email,
        equals(MockAuthService.testUserEmail),
      );
      expect(success.response.token, isNotEmpty);

      final currentUser = await authService.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser?.email, equals(MockAuthService.testUserEmail));
    });

    test('Scenario 2: Login fails with invalid password', () async {
      const request = LoginRequest(
        email: MockAuthService.testUserEmail,
        password: 'WrongPassword123',
      );

      final result = await authService.login(request);

      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.errorType, equals(AuthErrorType.invalidCredentials));
      expect(failure.message, contains('Invalid email or password'));

      final currentUser = await authService.getCurrentUser();
      expect(currentUser, isNull);
    });

    test('Scenario 3: Login fails with unknown email', () async {
      const request = LoginRequest(
        email: 'unknown@test.local',
        password: 'ValidPass123',
      );

      final result = await authService.login(request);

      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.errorType, equals(AuthErrorType.invalidCredentials));
    });

    test('Scenario 4: Registration succeeds with valid data', () async {
      const request = RegisterRequest(
        name: 'New Registered User',
        email: 'newuser@test.local',
        phoneNumber: '+970599112233',
        password: 'SecurePassword123',
        confirmPassword: 'SecurePassword123',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: UserCategory.graduate,
      );

      final result = await authService.register(request);

      expect(result, isA<AuthSuccess>());
      final success = result as AuthSuccess;
      expect(success.response.user.email, equals('newuser@test.local'));
      expect(success.response.user.userCategory, equals(UserCategory.graduate));

      // Newly registered user is immediately authenticated
      final currentUser = await authService.getCurrentUser();
      expect(currentUser?.email, equals('newuser@test.local'));

      // Newly registered user can now log in
      await authService.logout();
      expect(await authService.getCurrentUser(), isNull);

      final loginResult = await authService.login(
        const LoginRequest(
          email: 'newuser@test.local',
          password: 'SecurePassword123',
        ),
      );
      expect(loginResult, isA<AuthSuccess>());
    });

    test('Scenario 5: Registration fails on password mismatch', () async {
      const request = RegisterRequest(
        name: 'Mismatch User',
        email: 'mismatch@test.local',
        phoneNumber: '+970599112233',
        password: 'SecurePassword123',
        confirmPassword: 'DifferentPassword456',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: UserCategory.universityStudent,
      );

      final result = await authService.register(request);

      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.errorType, equals(AuthErrorType.validation));
      expect(failure.fieldErrors?['confirmPassword'], isNotNull);
      expect(
        failure.fieldErrors!['confirmPassword']!.first,
        contains('do not match'),
      );
    });

    test('Scenario 6: Registration fails on missing required fields', () async {
      const request = RegisterRequest(
        name: '',
        email: 'invalid-email',
        phoneNumber: '',
        password: '',
        confirmPassword: '',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: null,
      );

      final result = await authService.register(request);

      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.errorType, equals(AuthErrorType.validation));
      expect(failure.fieldErrors?['name'], isNotNull);
      expect(failure.fieldErrors?['email'], isNotNull);
      expect(failure.fieldErrors?['phoneNumber'], isNotNull);
      expect(failure.fieldErrors?['password'], isNotNull);
      expect(failure.fieldErrors?['confirmPassword'], isNotNull);
      expect(failure.fieldErrors?['userCategory'], isNotNull);
    });

    test(
      'Scenario 7: Registration fails on duplicate email conflict',
      () async {
        const request = RegisterRequest(
          name: 'Duplicate Registrant',
          email: MockAuthService.duplicateEmailTrigger,
          phoneNumber: '+970599999999',
          password: 'Password123!',
          confirmPassword: 'Password123!',
          primaryType: PrimaryAccountType.serviceProvider,
          providerCategory: ProviderCategory.educationCourse,
        );

        final result = await authService.register(request);

        expect(result, isA<AuthFailure>());
        final failure = result as AuthFailure;
        expect(failure.errorType, equals(AuthErrorType.conflict));
        expect(failure.fieldErrors?['email'], isNotNull);
      },
    );

    test('Scenario 8: Simulated network failure on reserved trigger', () async {
      const loginReq = LoginRequest(
        email: MockAuthService.networkErrorEmailTrigger,
        password: 'AnyPassword',
      );
      final loginResult = await authService.login(loginReq);
      expect(loginResult, isA<AuthFailure>());
      expect(
        (loginResult as AuthFailure).errorType,
        equals(AuthErrorType.network),
      );

      const regReq = RegisterRequest(
        name: 'Network Trigger',
        email: MockAuthService.networkErrorEmailTrigger,
        phoneNumber: '+970599000000',
        password: 'Pass',
        confirmPassword: 'Pass',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: UserCategory.otherIndividual,
      );
      final regResult = await authService.register(regReq);
      expect(regResult, isA<AuthFailure>());
      expect(
        (regResult as AuthFailure).errorType,
        equals(AuthErrorType.network),
      );
    });

    test('Scenario 9: Logout clears in-memory session', () async {
      // Login first
      await authService.login(
        const LoginRequest(
          email: MockAuthService.testUserEmail,
          password: MockAuthService.testUserPassword,
        ),
      );
      expect(await authService.getCurrentUser(), isNotNull);

      // Logout
      await authService.logout();
      expect(await authService.getCurrentUser(), isNull);
    });
  });
}
