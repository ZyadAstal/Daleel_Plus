import 'auth_models.dart';

/// Types of errors that can occur during authentication.
enum AuthErrorType {
  /// Wrong email or password.
  invalidCredentials,

  /// Form validation error (e.g. missing fields or mismatched passwords).
  validation,

  /// Account or resource already exists.
  conflict,

  /// Network or connection issue.
  network,

  /// Unexpected server or system error.
  unexpected,
}

/// Result of an authentication request (either success or failure).
sealed class AuthResult {
  const AuthResult();

  bool get isSuccess => this is AuthSuccess;
  bool get isFailure => this is AuthFailure;
}

/// Returned when authentication succeeds.
final class AuthSuccess extends AuthResult {
  final AuthResponse response;

  const AuthSuccess(this.response);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthSuccess && other.response == response;
  }

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'AuthSuccess(response: $response)';
}

/// Returned when authentication fails.
final class AuthFailure extends AuthResult {
  final AuthErrorType errorType;
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const AuthFailure({
    required this.errorType,
    required this.message,
    this.fieldErrors,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthFailure &&
        other.errorType == errorType &&
        other.message == message &&
        _mapsEqual(other.fieldErrors, fieldErrors);
  }

  @override
  int get hashCode => Object.hash(
    errorType,
    message,
    fieldErrors == null ? null : Object.hashAll(fieldErrors!.entries),
  );

  @override
  String toString() {
    return 'AuthFailure(errorType: $errorType, message: $message, fieldErrors: $fieldErrors)';
  }

  static bool _mapsEqual(
    Map<String, List<String>>? a,
    Map<String, List<String>>? b,
  ) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final listA = a[key]!;
      final listB = b[key]!;
      if (listA.length != listB.length) return false;
      for (int i = 0; i < listA.length; i++) {
        if (listA[i] != listB[i]) return false;
      }
    }
    return true;
  }
}
