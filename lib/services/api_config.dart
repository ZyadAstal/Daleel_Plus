/// Centralized API configuration for Daleel+.
///
/// Encodes confirmed system-wide constraints from the project requirements.
/// Real base URLs and endpoint paths are not hardcoded or assumed here;
/// an explicit base URL must be supplied when configuring network clients.
///
/// Note on local development:
/// The host `10.0.2.2` is a well-known loopback alias specific to the standard
/// Android emulator to reach the host development machine. It is not a project
/// default and will not work on physical devices or other platforms.
class ApiConfig {
  /// Confirmed performance constraint from DaleelPlus_SRS.md NFR-01:
  /// The system shall complete authentication requests and return a response
  /// within 3 seconds under normal network conditions.
  static const Duration requestTimeout = Duration(seconds: 3);

  /// The explicitly supplied base URL for API requests.
  final String baseUrl;

  /// Creates an [ApiConfig] with an explicitly supplied, non-empty [baseUrl].
  ///
  /// Throws [ArgumentError] if [baseUrl] is empty, not an absolute URI,
  /// or lacks a valid scheme or host. Validation does not depend on debug asserts.
  ApiConfig({required String baseUrl})
    : baseUrl = _validateAndNormalize(baseUrl);

  /// Creates an [ApiConfig] from a compile-time environment variable (`API_BASE_URL`).
  ///
  /// Throws [StateError] if the environment variable was not supplied.
  factory ApiConfig.fromEnvironment() {
    const url = String.fromEnvironment('API_BASE_URL');
    if (url.trim().isEmpty) {
      throw StateError(
        'API_BASE_URL compile-time variable is not set. '
        'An explicit base URL must be provided via --dart-define=API_BASE_URL=...',
      );
    }
    return ApiConfig(baseUrl: url);
  }

  static String _validateAndNormalize(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        rawUrl,
        'baseUrl',
        'Base URL must not be empty.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(
        rawUrl,
        'baseUrl',
        'Base URL must be a valid absolute URI with scheme and host (e.g., https://api.example.com).',
      );
    }

    // Strip trailing slashes for consistent endpoint path joining later
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiConfig && other.baseUrl == baseUrl;
  }

  @override
  int get hashCode => baseUrl.hashCode;

  @override
  String toString() => 'ApiConfig(baseUrl: $baseUrl, timeout: $requestTimeout)';
}
