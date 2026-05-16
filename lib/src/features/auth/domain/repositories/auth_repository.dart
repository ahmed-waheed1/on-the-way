import 'dart:io';
import 'package:on_the_way/src/utils/utils.dart';
import 'package:on_the_way/src/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get onAuthStateChanged;

  FutureEither<AppUser> login({required String email, required String password});

  FutureEither<AppUser> signUp({required String name, required String email, required String password});

  FutureEither<void> forgotPassword({required String email});

  FutureEither<void> logout();

  FutureEither<AppUser?> checkAuthState();

  /// Updates editable profile fields. Null values are left unchanged.
  FutureEither<AppUser> updateProfile({
    String? name,
    String? phone,
    String? username,
    String? bio,
  });

  /// Uploads [imageFile] to storage and returns the public URL.
  FutureEither<String> uploadAvatar(File imageFile);
}

