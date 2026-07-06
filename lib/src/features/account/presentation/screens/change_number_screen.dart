import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/presentation/providers/session_provider.dart';

const _kSubtitleColor = Color(0xFF909090);
const _kKeepLinkColor = Color(0xFF185AC2);

class ChangeNumberScreen extends HookConsumerWidget {
  const ChangeNumberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPhone = ref.watch(sessionProvider).user?.phone ?? '';

    void changeNumber() => context.push(AppRoutes.changeNumberForm);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: ''),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: Column(
                  children: [
                    SizedBox(height: 18.h),

                    // ── Illustration ──────────────────────────────────────────
                    Image.asset(
                      AppAssets.changeNumberIllustration,
                      width: 100.r,
                      height: 100.r,
                    ),
                    SizedBox(height: 52.h),

                    // ── Title ─────────────────────────────────────────────────
                    Text(
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
                    SizedBox(height: 16.h),

                    // ── Subtitle ──────────────────────────────────────────────
                    Text(
                      'You can change your number here. '
                      'Your account and all your media, '
                      'posts will be moved to the new number.',
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
                  ],
                ),
              ),
            ),

            // ── Keep current number ───────────────────────────────────────────
            if (currentPhone.isNotEmpty)
              GestureDetector(
                onTap: () => context.pop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'Keep $currentPhone',
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: AppTypography.regular,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: _kKeepLinkColor,
                      height: 20 / 16,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 24.h),

            // ── Change number ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 24.h),
              child: GestureDetector(
                onTap: changeNumber,
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Change Number',
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
            ),
          ],
        ),
      ),
    );
  }
}
