import 'package:flutter_test/flutter_test.dart';

import 'package:daleel_plus/models/auth_models.dart';
import 'package:daleel_plus/models/auth_result.dart';
import 'package:daleel_plus/services/api_config.dart';

void main() {
  group('Auth Models & Provisional Entities Tests', () {
    test('User model supports value equality and copyWith', () {
      const user1 = User(
        id: 'usr-1',
        name: 'Ahmad Ali',
        email: 'ahmad@example.com',
        phoneNumber: '+970599123456',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: UserCategory.universityStudent,
      );

      const user2 = User(
        id: 'usr-1',
        name: 'Ahmad Ali',
        email: 'ahmad@example.com',
        phoneNumber: '+970599123456',
        primaryType: PrimaryAccountType.individualUser,
        userCategory: UserCategory.universityStudent,
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));

      final updated = user1.copyWith(name: 'Ahmad K. Ali');
      expect(updated.name, equals('Ahmad K. Ali'));
      expect(updated.id, equals('usr-1'));
      expect(updated, isNot(equals(user1)));
    });

    test(
      'LoginRequest protects password in toString and supports equality',
      () {
        const req1 = LoginRequest(
          email: 'user@example.com',
          password: 'SecretPassword123',
        );
        const req2 = LoginRequest(
          email: 'user@example.com',
          password: 'SecretPassword123',
        );

        expect(req1, equals(req2));
        expect(req1.toString(), contains('[PROTECTED]'));
        expect(req1.toString(), isNot(contains('SecretPassword123')));
      },
    );

    test(
      'RegisterRequest protects password in toString and supports equality',
      () {
        const reg1 = RegisterRequest(
          name: 'Sara Nour',
          email: 'sara@example.com',
          phoneNumber: '+970599789012',
          password: 'SecretPassword123',
          confirmPassword: 'SecretPassword123',
          primaryType: PrimaryAccountType.serviceProvider,
          providerCategory: ProviderCategory.privateTutor,
        );
        const reg2 = RegisterRequest(
          name: 'Sara Nour',
          email: 'sara@example.com',
          phoneNumber: '+970599789012',
          password: 'SecretPassword123',
          confirmPassword: 'SecretPassword123',
          primaryType: PrimaryAccountType.serviceProvider,
          providerCategory: ProviderCategory.privateTutor,
        );

        expect(reg1, equals(reg2));
        expect(reg1.toString(), contains('[PROTECTED]'));
        expect(reg1.toString(), isNot(contains('SecretPassword123')));
      },
    );

    test('AuthResponse protects token in toString and supports equality', () {
      const user = User(
        id: 'usr-1',
        name: 'Sara',
        email: 'sara@example.com',
        primaryType: PrimaryAccountType.individualUser,
      );
      const res1 = AuthResponse(token: 'jwt-super-secret-token', user: user);
      const res2 = AuthResponse(token: 'jwt-super-secret-token', user: user);

      expect(res1, equals(res2));
      expect(res1.toString(), contains('[PROTECTED]'));
      expect(res1.toString(), isNot(contains('jwt-super-secret-token')));
    });
  });

  group('AuthResult Sealed Class Tests', () {
    test('AuthSuccess behaves correctly and supports pattern matching', () {
      const user = User(
        id: 'usr-1',
        name: 'User',
        email: 'user@example.com',
        primaryType: PrimaryAccountType.individualUser,
      );
      const success = AuthSuccess(AuthResponse(token: 'token-123', user: user));

      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);

      final matched = switch (success as AuthResult) {
        AuthSuccess(:final response) => response.user.name,
        AuthFailure() => 'failed',
      };
      expect(matched, equals('User'));
    });

    test('AuthFailure holds errorType, message, fieldErrors and tests map equality', () {
      const failure1 = AuthFailure(
        errorType: AuthErrorType.validation,
        message: 'Invalid input',
        fieldErrors: {
          'email': ['Required'],
        },
      );

      const failure2 = AuthFailure(
        errorType: AuthErrorType.validation,
        message: 'Invalid input',
        fieldErrors: {
          'email': ['Required'],
        },
      );

      expect(failure1.isSuccess, isFalse);
      expect(failure1.isFailure, isTrue);
      expect(failure1, equals(failure2));
    });
  });

  group('ApiConfig Tests', () {
    test(
      'Constructs with valid absolute URI and normalizes trailing slash',
      () {
        final config = ApiConfig(baseUrl: 'https://api.daleelplus.ps/');
        expect(config.baseUrl, equals('https://api.daleelplus.ps'));
        expect(ApiConfig.requestTimeout, equals(const Duration(seconds: 3)));
      },
    );

    test(
      'Throws ArgumentError on empty or invalid URI without relying on assert',
      () {
        expect(() => ApiConfig(baseUrl: '   '), throwsA(isA<ArgumentError>()));

        expect(
          () => ApiConfig(baseUrl: 'not-a-valid-url'),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => ApiConfig(baseUrl: 'http:///missing-host'),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('fromEnvironment throws StateError when variable not supplied', () {
      expect(() => ApiConfig.fromEnvironment(), throwsA(isA<StateError>()));
    });
  });
}
