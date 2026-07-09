import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/token_store.dart';
import '../utils/failure.dart';
import '../utils/typedefs.dart';
import 'secure_storage_service.dart';

/// REST-backed auth service for the On The Way API.
///
/// Auth state is a simple `Map<String, dynamic>?` (user fields) so the rest of
/// the app (repository, providers) stays framework-agnostic. On login/register
/// the JWT is persisted via [TokenStore] and the user profile via secure
/// storage (the API exposes no "get current user" endpoint).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _userKey = 'auth_user_json';

  final ApiClient _api = ApiClient.instance;

  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<Map<String, dynamic>?> get authStateChanges => _authStateController.stream;

  // ── Registration & verification ─────────────────────────────────────────

  FutureEither<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _api.post<void>(ApiEndpoints.register, data: {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
  }

  FutureEither<void> verifyEmail({required String email, required String otp}) {
    return _api.post<void>(ApiEndpoints.verifyEmail, data: {
      'email': email,
      'otp': otp,
    });
  }

  // ── Login ───────────────────────────────────────────────────────────────

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final result = await _api.post<dynamic>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return result.fold(
      (failure) async => left(failure),
      (data) async => await _handleAuthSuccess(data, fallbackEmail: email),
    );
  }

  FutureEither<Map<String, dynamic>?> googleLogin({required String idToken}) async {
    final result = await _api.post<dynamic>(
      ApiEndpoints.googleLogin,
      data: {'idToken': idToken},
    );
    return result.fold(
      (failure) async => left(failure),
      (data) async => await _handleAuthSuccess(data),
    );
  }

  // ── Password recovery ─────────────────────────────────────────────────────

  FutureEither<void> forgetPassword({required String email}) {
    return _api.post<void>(ApiEndpoints.forgetPassword, data: {'email': email});
  }

  FutureEither<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _api.post<void>(ApiEndpoints.resetPassword, data: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    });
  }

  // ── Session ───────────────────────────────────────────────────────────────

  /// Local logout — the API has no user logout endpoint, so we just clear the
  /// stored token and user.
  FutureEither<void> logout() async {
    await TokenStore.instance.clear();
    await SecureStorageService.instance.delete(_userKey);
    _authStateController.add(null);
    return right(null);
  }

  /// Restores the persisted user if a token is present.
  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    if (!TokenStore.instance.hasToken) return right(null);
    final result = await SecureStorageService.instance.read(_userKey);
    return result.map((json) {
      if (json == null || json.isEmpty) return null;
      try {
        return jsonDecode(json) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    });
  }

  /// Persists profile edits locally (no profile API exists) and re-emits state.
  FutureEither<Map<String, dynamic>> saveLocalUser(Map<String, dynamic> user) async {
    await SecureStorageService.instance.write(_userKey, jsonEncode(user));
    _authStateController.add(user);
    return right(user);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Either<Failure, Map<String, dynamic>?>> _handleAuthSuccess(
    dynamic data, {
    String? fallbackEmail,
  }) async {
    final token = _extractToken(data);
    if (token == null || token.isEmpty) {
      return left(const ServerFailure('Login succeeded but no token was returned.'));
    }
    await TokenStore.instance.save(token);

    final user = _extractUser(data, token, fallbackEmail: fallbackEmail);
    await SecureStorageService.instance.write(_userKey, jsonEncode(user));
    _authStateController.add(user);
    return right(user);
  }

  /// Pulls the JWT out of the auth payload, whatever shape the API returns.
  String? _extractToken(dynamic data) {
    if (data is String) return data;
    if (data is Map) {
      for (final key in ['token', 'accessToken', 'access_token', 'jwt', 'jwtToken']) {
        final v = data[key];
        if (v is String && v.isNotEmpty) return v;
      }
      // Sometimes nested under "data" or "token" object.
      final nested = data['token'] ?? data['data'];
      if (nested is Map) return _extractToken(nested);
    }
    return null;
  }

  /// Builds a user map from the payload, falling back to JWT claims.
  Map<String, dynamic> _extractUser(dynamic data, String token, {String? fallbackEmail}) {
    Map<String, dynamic>? raw;
    if (data is Map) {
      final u = data['user'];
      raw = (u is Map ? u : data).cast<String, dynamic>();
    }

    final claims = _decodeJwt(token);

    String? pick(Map<String, dynamic>? m, List<String> keys) {
      if (m == null) return null;
      for (final k in keys) {
        final v = m[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    return {
      'id': pick(raw, ['id', 'userId', 'sub']) ??
          pick(claims, ['sub', 'nameid',
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']) ??
          '',
      'email': pick(raw, ['email']) ??
          pick(claims, ['email',
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']) ??
          fallbackEmail ??
          '',
      'name': pick(raw, ['fullName', 'name', 'userName']) ??
          pick(claims, ['FullName', 'name', 'unique_name',
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']),
      'phone': pick(raw, ['phoneNumber', 'phone']),
      'username': pick(raw, ['userName', 'username']),
      'bio': pick(raw, ['bio']),
      'photoUrl': pick(raw, ['photoUrl', 'profileImage', 'imageUrl', 'avatar']),
    };
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);
      return map is Map ? map.cast<String, dynamic>() : null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
