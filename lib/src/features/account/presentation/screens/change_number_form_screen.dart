import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/presentation/providers/session_provider.dart';

const _kFieldBg = Color(0xFFF0F0F0);
const _kHintColor = Color(0xFFC2C5C2);
const _kSubtitleColor = Color(0xFF909090);

class ChangeNumberFormScreen extends HookConsumerWidget {
  const ChangeNumberFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).user;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController(text: user?.email ?? '');
    final phoneController = useTextEditingController();
    final isSubmitting = useState(false);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      isSubmitting.value = true;
      // TODO: a real flow should verify the new number via OTP *before*
      // committing it. For now we update and then show the confirmation step.
      final ok = await ref
          .read(sessionProvider.notifier)
          .updateProfile(phone: phoneController.text.trim());
      isSubmitting.value = false;

      if (!context.mounted) return;
      if (ok) {
        context.push(AppRoutes.changeNumberOtp);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: ''),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 18.h),

                    // ── Illustration ──────────────────────────────────────────
                    Center(
                      child: Image.asset(
                        AppAssets.changeNumberFormIllustration,
                        width: 100.r,
                        height: 100.r,
                      ),
                    ),
                    SizedBox(height: 52.h),

                    // ── Title ─────────────────────────────────────────────────
                    Center(
                      child: Text(
                        'Change Number',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: AppTypography.bold,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: Colors.black,
                          height: 20 / 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Subtitle ──────────────────────────────────────────────
                    Center(
                      child: Text(
                        'Your new number will receive a confirmation code via email.',
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
                    SizedBox(height: 42.h),

                    // ── Email ─────────────────────────────────────────────────
                    const _FieldLabel('Email'),
                    SizedBox(height: 12.h),
                    _FilledField(
                      controller: emailController,
                      hint: 'Enter your email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (AppUtils.isBlank(v)) return 'Email is required';
                        if (!AppUtils.isValidEmail(v!.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 35.h),

                    // ── Phone ─────────────────────────────────────────────────
                    const _FieldLabel('Phone Number'),
                    SizedBox(height: 12.h),
                    _FilledField(
                      controller: phoneController,
                      hint: 'Enter new number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (AppUtils.isBlank(v)) return 'Phone number is required';
                        if (v!.trim().length < 7) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Submit FAB ────────────────────────────────────────────────────
            Positioned(
              right: 20.w,
              bottom: 24.h,
              child: GestureDetector(
                onTap: isSubmitting.value ? null : submit,
                child: Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isSubmitting.value
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.arrow_forward, size: 24.r, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field label ─────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: AppColors.titleText,
        height: 20 / 16,
      ),
    );
  }
}

// ── Filled field ────────────────────────────────────────────────────────────────

class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: AppColors.primary,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: AppColors.titleText,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: _kFieldBg,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        prefixIcon: Icon(
          icon,
          size: 24.r,
          color: AppColors.titleText.withValues(alpha: 0.6),
        ),
        hintText: hint,
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
