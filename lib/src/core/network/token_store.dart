import 'package:on_the_way/src/services/secure_storage_service.dart';

/// Holds the current JWT access token in memory (for fast, synchronous access
/// from the Dio interceptor) and mirrors it to secure storage for persistence.
class TokenStore {
  TokenStore._();
  static final TokenStore instance = TokenStore._();

  static const _tokenKey = 'auth_access_token';

  String? _token;

  /// The current access token, or null when unauthenticated.
  String? get token => _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Loads the persisted token into memory. Call once at app startup.
  Future<void> load() async {
    final result = await SecureStorageService.instance.read(_tokenKey);
    result.fold((_) => _token = null, (value) => _token = value);
  }

  /// Persists a new token and keeps it in memory.
  Future<void> save(String token) async {
    _token = token;
    await SecureStorageService.instance.write(_tokenKey, token);
  }

  /// Clears the token from memory and storage (logout / 401).
  Future<void> clear() async {
    _token = null;
    await SecureStorageService.instance.delete(_tokenKey);
  }
}
