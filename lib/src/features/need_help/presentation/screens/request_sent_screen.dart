import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

const _kStepTextColor = Color(0xFF6B7280);
const _kProgressTrack = Color(0xFFD9D9D9);
const _kIconCircleBg = Color(0xFF9FD3EB);

class RequestSentScreen extends StatelessWidget {
  const RequestSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: const BoxDecoration(
                        color: _kIconCircleBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 42.r,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'Your Assistance Request\nhas been sent!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 24.sp,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
              child: _BackToHomeButton(
                onTap: () => context.go(AppRoutes.home),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header: back arrow + step progress ───────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.arrow_back,
              size: 22.r,
              color: AppColors.titleText,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Step 4 of 4',
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: _kStepTextColor,
            ),
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              height: 6.h,
              child: Stack(
                children: [
                  Container(color: _kProgressTrack),
                  // 100% filled — step 4 of 4
                  Container(color: AppColors.primary),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          const Center(child: _StepDots(total: 4, current: 3)),
        ],
      ),
    );
  }
}

// ── Step dots ─────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 18.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : _kProgressTrack,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

// ── Back to home button ───────────────────────────────────────────────────────

class _BackToHomeButton extends StatelessWidget {
  const _BackToHomeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 57.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'Back To Home',
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.black,
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            color: const Color(0xFFEEEEEE),
            height: 20 / 16,
          ),
        ),
      ),
    );
  }
}
