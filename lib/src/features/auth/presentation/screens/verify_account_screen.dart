import 'dart:async';

import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:on_the_way/src/features/account/presentation/widgets/edit_field_sheet.dart';

const _kSubtitleColor = Color(0xFF909090);
const _kTimerColor = Color(0xFF185AC2);
const _kOtpLength = 5;
const _kResendSeconds = 60;

/// What the OTP screen should do once a valid code is entered.
enum VerifyPurpose { verifyEmail, resetPassword }

class VerifyAccountArgs {
  const VerifyAccountArgs({required this.email, this.purpose = VerifyPurpose.verifyEmail});
  final String email;
  final VerifyPurpose purpose;
}

class VerifyAccountScreen extends HookConsumerWidget {
  const VerifyAccountScreen({super.key, this.args});

  final VerifyAccountArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = args?.email ?? '';
    final purpose = args?.purpose ?? VerifyPurpose.verifyEmail;
    final isLoading = ref.watch(authControllerProvider);
    final controllers = useMemoized(
      () => List.generate(_kOtpLength, (_) => TextEditingController()),
      const [],
    );
    final focusNodes = useMemoized(
      () => List.generate(_kOtpLength, (_) => FocusNode()),
      const [],
    );
    final digits = useState(List.filled(_kOtpLength, ''));
    final secondsLeft = useState(_kResendSeconds);

    // Dispose controllers / focus nodes.
    useEffect(() {
      return () {
        for (final c in controllers) {
          c.dispose();
        }
        for (final f in focusNodes) {
          f.dispose();
        }
      };
    }, const []);

    // Resend countdown.
    useEffect(() {
      if (secondsLeft.value <= 0) return null;
      final timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (secondsLeft.value <= 1) {
          secondsLeft.value = 0;
          t.cancel();
        } else {
          secondsLeft.value = secondsLeft.value - 1;
        }
      });
      return timer.cancel;
    }, [secondsLeft.value == 0]);

    void onDigitChanged(int index, String value) {
      final ch = value.isEmpty ? '' : value.characters.last;
      controllers[index].text = ch;
      controllers[index].selection =
          TextSelection.collapsed(offset: ch.length);

      final next = [...digits.value];
      next[index] = ch;
      digits.value = next;

      if (ch.isNotEmpty && index < _kOtpLength - 1) {
        focusNodes[index + 1].requestFocus();
      } else if (ch.isEmpty && index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }

    Future<void> resend() async {
      if (secondsLeft.value != 0) return;
      final controller = ref.read(authControllerProvider.notifier);
      if (purpose == VerifyPurpose.resetPassword) {
        await controller.forgetPassword(context: context, email: email);
      } else {
        // Re-trigger by asking the user to register again is not ideal; the API
        // resends automatically on register. Just restart the timer for now.
      }
      secondsLeft.value = _kResendSeconds;
      if (context.mounted) {
        showToast(context, message: 'A new code has been sent', status: 'info');
      }
    }

    final isComplete = !digits.value.contains('');
    final code = digits.value.join();

    Future<void> verify() async {
      final controller = ref.read(authControllerProvider.notifier);
      if (purpose == VerifyPurpose.verifyEmail) {
        await controller.verifyEmail(context: context, email: email, otp: code);
        return;
      }
      // Password reset: collect a new password, then call reset-password.
      final newPassword = await showEditFieldSheet(
        context,
        title: 'New Password',
        currentValue: '',
        hint: 'Enter a new password',
        obscure: true,
      );
      if (newPassword == null || newPassword.length < 6) {
        if (context.mounted && newPassword != null) {
          showToast(context, message: 'Password must be at least 6 characters', status: 'error');
        }
        return;
      }
      if (!context.mounted) return;
      await controller.resetPassword(
        context: context,
        email: email,
        otp: code,
        newPassword: newPassword,
        confirmNewPassword: newPassword,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Verify Your Account'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 27.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter code',
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: AppTypography.bold,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: Colors.black,
                          height: 20 / 20,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'check your email to dictate the code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: AppTypography.regular,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: _kSubtitleColor,
                          height: 20 / 16,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── OTP boxes ─────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_kOtpLength, (i) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: _OtpBox(
                              controller: controllers[i],
                              focusNode: focusNodes[i],
                              onChanged: (v) => onDigitChanged(i, v),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 24.h),

                      // ── Resend timer ──────────────────────────────────────
                      GestureDetector(
                        onTap: resend,
                        behavior: HitTestBehavior.opaque,
                        child: secondsLeft.value > 0
                            ? Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(text: 'Re- send code via '),
                                    TextSpan(
                                      text: '${secondsLeft.value}',
                                      style: const TextStyle(color: _kTimerColor),
                                    ),
                                    const TextSpan(text: ' second'),
                                  ],
                                ),
                                style: TextStyle(
                                  fontFamily: AppTypography.robotoFlex,
                                  fontVariations: AppTypography.regular,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                  color: _kSubtitleColor,
                                  height: 20 / 12,
                                ),
                              )
                            : Text(
                                'Resend code',
                                style: TextStyle(
                                  fontFamily: AppTypography.robotoFlex,
                                  fontVariations: AppTypography.bold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                  color: _kTimerColor,
                                  height: 20 / 12,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Verify button ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 24.h),
              child: _VerifyButton(
                enabled: isComplete && !isLoading,
                onTap: verify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── OTP box ─────────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 56.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: AppColors.primary,
        style: TextStyle(
          fontFamily: AppTypography.robotoFlex,
          fontVariations: AppTypography.bold,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
          color: AppColors.titleText,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ── Verify button ───────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'Verify',
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.black,
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            color: Colors.white,
            height: 20 / 16,
          ),
        ),
      ),
    );
  }
}
