import 'package:hooks_riverpod/legacy.dart';
import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:on_the_way/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:on_the_way/src/features/auth/presentation/screens/verify_account_screen.dart';

/// Single shared instance of the auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Loading flag for auth actions.
final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(repository: ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthController({required AuthRepository repository})
      : _repository = repository,
        super(false); // false = not loading

  /// Login → home.
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = true;
    final result = await _repository.login(email: email, password: password);
    state = false;
    result.fold(
      (failure) => showToast(context, message: failure.message, status: 'error'),
      (_) {
        if (context.mounted) context.go(AppRoutes.home);
      },
    );
  }

  /// Register → verify-email OTP screen (passing the email along).
  Future<void> register({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = true;
    final result = await _repository.register(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    state = false;
    result.fold(
      (failure) => showToast(context, message: failure.message, status: 'error'),
      (_) {
        showToast(context, message: 'Verification code sent to your email', status: 'success');
        if (context.mounted) {
          context.push(
            AppRoutes.verifyAccount,
            extra: VerifyAccountArgs(email: email, purpose: VerifyPurpose.verifyEmail),
          );
        }
      },
    );
  }

  /// Verify email OTP → login screen.
  Future<void> verifyEmail({
    required BuildContext context,
    required String email,
    required String otp,
  }) async {
    state = true;
    final result = await _repository.verifyEmail(email: email, otp: otp);
    state = false;
    result.fold(
      (failure) => showToast(context, message: failure.message, status: 'error'),
      (_) {
        if (context.mounted) context.go(AppRoutes.emailVerified);
      },
    );
  }

  /// Request a password-reset OTP → reset-password screen.
  Future<void> forgetPassword({
    required BuildContext context,
    required String email,
  }) async {
    state = true;
    final result = await _repository.forgetPassword(email: email);
    state = false;
    result.fold(
      (failure) => showToast(context, message: failure.message, status: 'error'),
      (_) {
        showToast(context, message: 'If the email exists, a reset code was sent', status: 'success');
        if (context.mounted) {
          context.push(
            AppRoutes.verifyAccount,
            extra: VerifyAccountArgs(email: email, purpose: VerifyPurpose.resetPassword),
          );
        }
      },
    );
  }

  /// Complete a password reset with OTP + new password → login.
  Future<void> resetPassword({
    required BuildContext context,
    required String email,
    required String otp,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = true;
    final result = await _repository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
    state = false;
    result.fold(
      (failure) => showToast(context, message: failure.message, status: 'error'),
      (_) {
        showToast(context, message: 'Password reset successfully', status: 'success');
        if (context.mounted) context.go(AppRoutes.login);
      },
    );
  }

  /// Sign in with a Google ID token → home.
  Future<void> googleLogin({
    required BuildContext context,
    required String idToken,
  }) async {
    state = true;
    final result = await _repository.googleLogin(idToken: idToken);
    state = false;
    result.fold(
      (failure) => showToast(context, message: failure.message, status: 'error'),
      (_) {
        if (context.mounted) context.go(AppRoutes.home);
      },
    );
  }
}
