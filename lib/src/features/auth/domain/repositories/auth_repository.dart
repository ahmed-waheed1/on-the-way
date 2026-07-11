import 'dart:io';
import 'package:on_the_way/src/utils/utils.dart';
import 'package:on_the_way/src/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  /// Emits the current [AppUser] on auth changes, or null when signed out.
  Stream<AppUser?> get onAuthStateChanged;

  /// Registers a new account. The API then emails an OTP to verify.
  FutureEither<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// Confirms the account with the OTP sent by email.
  FutureEither<void> verifyEmail({required String email, required String otp});

  /// Signs in with email + password, persisting the JWT.
  FutureEither<AppUser> login(
      {required String email, required String password});

  /// Signs in with a Google ID token.
  FutureEither<AppUser> googleLogin({required String idToken});

  /// Requests a password-reset OTP by email.
  FutureEither<void> forgetPassword({required String email});

  /// Completes a password reset with the OTP + new password.
  FutureEither<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmNewPassword,
  });

  /// Clears the local session (no server logout endpoint for users).
  FutureEither<void> logout();

  /// Restores the persisted session if a valid token exists.
  FutureEither<AppUser?> checkAuthState();

  /// Persists editable profile fields locally (no profile API exists yet).
  FutureEither<AppUser> updateProfile({
    String? name,
    String? phone,
    String? username,
    String? bio,
    String? photoUrl,
  });

  /// Stores an avatar locally and returns its path (no avatar API yet).
  FutureEither<String> uploadAvatar(File imageFile);
}
