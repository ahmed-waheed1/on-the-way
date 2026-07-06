import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

const _kCircleBg = Color(0xFFD1F7E2);
const _kCheckColor = Color(0xFF2BB673);
const _kSubtitleColor = Color(0xFF909090);

class ChangeNumberSuccessScreen extends StatelessWidget {
  const ChangeNumberSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 27.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Success badge ─────────────────────────────────────────────
                Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: const BoxDecoration(
                    color: _kCircleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, size: 54.r, color: _kCheckColor),
                ),
                SizedBox(height: 52.h),

                // ── Title ─────────────────────────────────────────────────────
                Text(
                  'Number Changed Correctly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.bold,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                    color: AppColors.titleText,
                    height: 20 / 24,
                  ),
                ),
                SizedBox(height: 32.h),

                // ── Subtitle ──────────────────────────────────────────────────
                Text(
                  'Your phone number has been successfully changed. '
                  'You can now proceed to the next step.',
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
                SizedBox(height: 68.h),

                // ── Continue ──────────────────────────────────────────────────
                GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Continue to Home',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
