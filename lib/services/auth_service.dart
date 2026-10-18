import '../models/auth_models.dart';
import '../models/auth_result.dart';

/// Interface for authentication operations.
///
/// Screens interact with this interface so we can easily swap between
/// [MockAuthService] and the real backend service without changing UI code.
abstract interface class AuthService {
  /// Logs in with email and password.
  Future<AuthResult> login(LoginRequest request);

  /// Registers a new account and logs in upon success.
  Future<AuthResult> register(RegisterRequest request);

  /// Logs out the current user and ends the session.
  Future<void> logout();

  /// Returns the current user, or `null` if not logged in.
  Future<User?> getCurrentUser();
}
