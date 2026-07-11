import 'dart:io';
import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/domain/entities/user.dart';
import 'package:on_the_way/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;

  AppUser _mapToUser(Map<String, dynamic> data) => AppUser(
        id: data['id']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        name: data['name']?.toString(),
        photoUrl: data['photoUrl']?.toString(),
        phone: data['phone']?.toString(),
        username: data['username']?.toString(),
        bio: data['bio']?.toString(),
      );

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return _authService.authStateChanges.map(
      (userData) => userData == null ? null : _mapToUser(userData),
    );
  }

  @override
  FutureEither<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _authService.register(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  @override
  FutureEither<void> verifyEmail({required String email, required String otp}) {
    return _authService.verifyEmail(email: email, otp: otp);
  }

  @override
  FutureEither<AppUser> login(
      {required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Login failed: no user returned.'));
      }
      return right(_mapToUser(userData));
    });
  }

  @override
  FutureEither<AppUser> googleLogin({required String idToken}) async {
    final result = await _authService.googleLogin(idToken: idToken);
    return result.flatMap((userData) {
      if (userData == null) {
        return left(
            const ServerFailure('Google login failed: no user returned.'));
      }
      return right(_mapToUser(userData));
    });
  }

  @override
  FutureEither<void> forgetPassword({required String email}) {
    return _authService.forgetPassword(email: email);
  }

  @override
  FutureEither<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _authService.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }

  @override
  FutureEither<void> logout() {
    return _authService.logout();
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    final result = await _authService.getCurrentUser();
    return result
        .map((userData) => userData == null ? null : _mapToUser(userData));
  }

  @override
  FutureEither<AppUser> updateProfile({
    String? name,
    String? phone,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    final current = await _authService.getCurrentUser();
    return current.fold(
      (f) async => left(f),
      (userData) async {
        final base = userData ?? {};
        final merged = {
          ...base,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (username != null) 'username': username,
          if (bio != null) 'bio': bio,
          if (photoUrl != null) 'photoUrl': photoUrl,
        };
        final saved = await _authService.saveLocalUser(merged);
        return saved.map(_mapToUser);
      },
    );
  }

  @override
  FutureEither<String> uploadAvatar(File imageFile) async {
    // No avatar upload endpoint — persist the local path so it renders locally.
    final updated = await updateProfile(photoUrl: imageFile.path);
    return updated.map((u) => u.photoUrl ?? imageFile.path);
  }
}
