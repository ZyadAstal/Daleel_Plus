# Daleel+ Authentication Integration Guide

This guide explains how to use the authentication service in your screens and how the mock service works during development.

---

## 1. Overview

The authentication layer uses a shared interface:

- **Interface**: `lib/services/auth_service.dart` (`AuthService`)
- **Mock Service**: `lib/services/mock_auth_service.dart` (`MockAuthService`)
- **Models**: `lib/models/auth_models.dart` (`User`, `LoginRequest`, `RegisterRequest`, `AuthResponse`)
- **Results**: `lib/models/auth_result.dart` (`AuthResult`, `AuthSuccess`, `AuthFailure`, `AuthErrorType`)
- **Configuration**: `lib/services/api_config.dart` (`ApiConfig`)

---

## 2. Using `AuthService` in Screens

Screens should always call `AuthService` rather than making HTTP calls directly. This keeps the UI decoupled from networking details.

### Example: Handling Login

```dart
import 'package:flutter/material.dart';
import 'package:daleel_plus/models/auth_models.dart';
import 'package:daleel_plus/models/auth_result.dart';
import 'package:daleel_plus/services/auth_service.dart';

class LoginController {
  final AuthService _authService;

  LoginController(this._authService);

  Future<void> submitLogin(String email, String password) async {
    final result = await _authService.login(
      LoginRequest(email: email, password: password),
    );

    switch (result) {
      case AuthSuccess(:final response):
        // Navigate to home or profile setup
        break;

      case AuthFailure(:final errorType, :final message, :final fieldErrors):
        // Show user-friendly error message or form field errors
        switch (errorType) {
          case AuthErrorType.invalidCredentials:
            // Show invalid email/password message
            break;
          case AuthErrorType.validation:
            // Show field validation errors using fieldErrors map
            break;
          case AuthErrorType.network:
            // Show network / offline error
            break;
          case AuthErrorType.conflict:
          case AuthErrorType.unexpected:
            // Show general error message
            break;
        }
        break;
    }
  }
}
```

---

## 3. Mock Authentication Behavior

`MockAuthService` is an **in-memory mock** for frontend development:

> [!NOTE]
> Sessions and newly registered accounts exist in memory only. They reset when the application restarts. Persistent login will be added when real backend integration is introduced.

### Test Fixtures
- **Default Login**:
  - Email: `student@test.local`
  - Password: `ValidPass123`
- **Duplicate Email Trigger**:
  - Email: `existing@test.local` (returns `AuthErrorType.conflict`)
- **Simulated Network Error Trigger**:
  - Email: `network-error@test.local` (returns `AuthErrorType.network`)

---

## 4. Security Rules (SRS NFR-09)

- **Never log passwords, credentials, or tokens** to the console or logs.
- `LoginRequest`, `RegisterRequest`, and `AuthResponse` hide passwords and tokens in their `toString()` methods.
- Form password fields should always use `obscureText: true`.

---

## 5. Future Real Backend Integration

When the ASP.NET Core backend is ready, a real service class (`ApiAuthService`) will implement the same `AuthService` interface:

```dart
class ApiAuthService implements AuthService {
  final ApiConfig _config;

  ApiAuthService(this._config);

  @override
  Future<AuthResult> login(LoginRequest request) async {
    // Send actual HTTP POST to confirmed endpoint
  }

  // ...
}
```

Because screens only depend on `AuthService`, swapping the mock for the real service will require **zero changes to screen code**.

### Backend Contract Details Needed Before Real Integration
1. Endpoint paths and HTTP methods (e.g. `/api/auth/login`).
2. JSON property naming conventions (camelCase vs. PascalCase).
3. Response format (direct DTO vs. wrapper envelope).
4. Validation error response format.
5. Token structure, expiration, and refresh handling.
6. Serialized values for account and provider types.
