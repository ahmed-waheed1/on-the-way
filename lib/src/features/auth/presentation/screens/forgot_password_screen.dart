import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

const _kFieldBg = Color(0xFFF0F0F0);
const _kHintColor = Color(0xFFC2C5C2);
const _kSubtitleColor = Color(0xFF6B7280);

class ForgotPasswordScreen extends HookWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();

    void handleSendCode() {
      if (!(formKey.currentState?.validate() ?? false)) return;
      // TODO: trigger the backend send-OTP request for this email.
      context.push(
        AppRoutes.verifyAccount,
        extra: emailController.text.trim(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Forgot Password'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18.h),

                      // ── Illustration ──────────────────────────────────────────
                      Center(
                        child: Image.asset(
                          AppAssets.resetPasswordIllustration,
                          width: 100.r,
                          height: 100.r,
                        ),
                      ),
                      SizedBox(height: 52.h),

                      // ── Subtitle ──────────────────────────────────────────────
                      Center(
                        child: Text(
                          'Enter your email to receive a password reset link',
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
                      ),
                      SizedBox(height: 60.h),

                      // ── Email ─────────────────────────────────────────────────
                      Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: AppTypography.regular,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.titleText,
                          height: 20 / 16,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _EmailField(
                        controller: emailController,
                        enabled: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Send Code ───────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 24.h),
              child: _SendCodeButton(
                isLoading: false,
                onTap: handleSendCode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Email field ─────────────────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      cursorColor: AppColors.primary,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: AppColors.titleText,
      ),
      validator: (v) {
        if (AppUtils.isBlank(v)) return 'Email is required';
        if (!AppUtils.isValidEmail(v!.trim())) return 'Enter a valid email';
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: _kFieldBg,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        prefixIcon: Icon(
          Icons.mail_outline,
          size: 24.r,
          color: AppColors.titleText.withValues(alpha: 0.6),
        ),
        hintText: 'Enter your email',
        hintStyle: TextStyle(
          fontFamily: AppTypography.robotoFlex,
          fontVariations: AppTypography.regular,
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: _kHintColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ── Send Code button ────────────────────────────────────────────────────────────

class _SendCodeButton extends StatelessWidget {
  const _SendCodeButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Send Code',
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
