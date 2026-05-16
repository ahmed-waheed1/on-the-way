import 'dart:io';
import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/domain/entities/user.dart';
import 'package:on_the_way/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;

  AppUser _mapToUser(Map<String, dynamic> data) => AppUser(
        id: data['id']?.toString() ?? '',
        email: data['email'] ?? '',
        name: data['name'],
        photoUrl: data['photoUrl'],
        phone: data['phone'],
        username: data['username'],
        bio: data['bio'],
      );

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return _authService.authStateChanges.map(
      (userData) => userData == null ? null : _mapToUser(userData),
    );
  }

  @override
  FutureEither<AppUser> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    return result.flatMap((userData) {
      if (userData == null) return left(const ServerFailure('Login failed: user record not found'));
      return right(_mapToUser(userData));
    });
  }

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _authService.signUp(name: name, email: email, password: password);
    return result.flatMap((userData) {
      if (userData == null) return left(const ServerFailure('Sign up failed: user record corrupted'));
      return right(_mapToUser(userData));
    });
  }

  @override
  FutureEither<void> forgotPassword({required String email}) {
    return _authService.forgotPassword(email: email);
  }

  @override
  FutureEither<void> logout() {
    return _authService.logout();
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    final result = await _authService.getCurrentUser();
    return result.map((userData) => userData == null ? null : _mapToUser(userData));
  }

  @override
  FutureEither<AppUser> updateProfile({
    String? name,
    String? phone,
    String? username,
    String? bio,
  }) async {
    final result = await _authService.updateProfile(
      name: name,
      phone: phone,
      username: username,
      bio: bio,
    );
    return result.map(_mapToUser);
  }

  @override
  FutureEither<String> uploadAvatar(File imageFile) {
    return _authService.uploadAvatar(imageFile);
  }
}
