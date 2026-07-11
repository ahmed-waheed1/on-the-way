import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/report_accident/presentation/providers/accident_report_provider.dart';

const _kIconCircleBg = Color(0xFF9FD3EB);
const _kBackCircleBg = Color(0xFFD1E8F2);

class ReportSentScreen extends ConsumerWidget {
  const ReportSentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void goHome() {
      ref.read(accidentReportProvider.notifier).reset();
      context.go(AppRoutes.home);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(11.w, 12.h, 11.w, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: 36.r,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: goHome,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 36.r,
                              height: 36.r,
                              decoration: const BoxDecoration(
                                color: _kBackCircleBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: 20.r,
                                color: AppColors.titleText,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Request Sent',
                          style: TextStyle(
                            fontFamily: AppTypography.robotoFlex,
                            fontVariations: AppTypography.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.sp,
                            color: AppColors.titleText,
                            height: 20 / 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  const _StepDots(total: 4, current: 3),
                ],
              ),
            ),

            // ── Success content ────────────────────────────────────────────────
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
                      'Your Report has been\nsent!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 24.sp,
                        color: AppColors.titleText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Back to home ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 28.h),
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: goHome,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Center(
                      child: Text(
                        'Back to Home',
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step dots ───────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 18.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
