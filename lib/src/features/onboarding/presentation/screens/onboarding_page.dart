import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

const _kSosIconPath = 'assets/icons/onboarding1-1.svg';
const _kRoadIconPath = 'assets/icons/onboarding1-2.svg';

const _kPrimaryBlue = Color(0xFF025D8C);
const _kSubtitleGray = Color(0xFFA8ABB3);
const _kDotInactive = Color(0xFFC4C6CE);
const _kSosShadow = Color(0x4DB81D17); // rgba(184,29,23,0.3)

class OnboardingPage extends HookWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final currentIndex = useState(0);

    void onNext() {
      if (currentIndex.value < 2) {
        pageController.nextPage(
          duration: AppDurations.normal,
          curve: AppCurves.standard,
        );
      } else {
        context.go(AppRoutes.login);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (i) => currentIndex.value = i,
            children: const [
              _OnboardingPage1(),
              _OnboardingPage2(),
              _OnboardingPage3(),
            ],
          ),
          _BottomNav(controller: pageController, onNext: onNext),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.controller, required this.onNext});

  final PageController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: WormEffect(
                  dotColor: _kDotInactive,
                  activeDotColor: _kPrimaryBlue,
                  dotHeight: 8.r,
                  dotWidth: 8.r,
                  spacing: 4.r,
                ),
              ),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: const BoxDecoration(
                    color: _kPrimaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 1 ────────────────────────────────────────────────────────────────────

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 104.h),
          SizedBox(
            height: 240.h,
            child: const Center(child: _SosButton()),
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                _kRoadIconPath,
                width: 40.r,
                height: 40.r,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              Text(
                'On The Way',
                style: AppTextStyles.onboardingHero.copyWith(color: _kPrimaryBlue),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Start your journey with real-time\nhazard detection and smart routing',
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingSubtitle.copyWith(color: _kSubtitleGray),
          ),
          const Spacer(),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton();

  @override
  Widget build(BuildContext context) {
    final buttonSize = 192.r;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPrimaryBlue, Colors.white],
        ),
        border: Border.all(color: Colors.white, width: 8),
        boxShadow: [
          // Red drop shadow (matches Figma drop-shadow)
          const BoxShadow(
            color: _kSosShadow,
            blurRadius: 25,
            offset: Offset(0, 20),
          ),
          // Outer white pulse glow
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 48,
            spreadRadius: 24,
          ),
          // Inner reddish aura
          BoxShadow(
            color: const Color(0xFFB81D17).withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            _kSosIconPath,
            width: 50.r,
            height: 50.r,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 2.h),
          Text('SOS', style: AppTextStyles.sosLabel),
          SizedBox(height: 8.h),
          Text('HOLD TO TRIGGER', style: AppTextStyles.sosTriggerHint),
        ],
      ),
    );
  }
}

// ── Page 2 ────────────────────────────────────────────────────────────────────

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 140.h),
          SizedBox(
            height: 240.h,
            child: SvgPicture.asset(
              'assets/icons/onboarding2.svg',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Ready to Go?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.bold,
              fontWeight: FontWeight.w700,
              fontSize: 40.sp,
              color: _kPrimaryBlue,
              letterSpacing: -1.2,
              height: 48 / 40,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Start your journey with real-time\nhazard detection and smart routing',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: _kSubtitleGray,
              height: 30 / 16,
            ),
          ),
          const Spacer(),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }
}

// ── Page 3 ────────────────────────────────────────────────────────────────────

const _kDecorBlue = Color(0xFF9FD3EB);

class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Decorative large blobs
        Positioned(
          left: -32.r,
          top: 580.h,
          child: Container(
            width: 63.r,
            height: 63.r,
            decoration: const BoxDecoration(
              color: _kDecorBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -16.r,
          top: 390.h,
          child: Container(
            width: 63.r,
            height: 63.r,
            decoration: const BoxDecoration(
              color: _kDecorBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Decorative small dots
        Positioned(
          right: 28.r,
          top: 125.h,
          child: Container(
            width: 12.r,
            height: 12.r,
            decoration: const BoxDecoration(
              color: _kDecorBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 170.r,
          top: 138.h,
          child: Container(
            width: 12.r,
            height: 12.r,
            decoration: const BoxDecoration(
              color: _kDecorBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Main content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 104.h),
              SizedBox(
                height: 240.h,
                child: SvgPicture.asset(
                  'assets/icons/onboarding3.svg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Best Fit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.bold,
                  fontWeight: FontWeight.w700,
                  fontSize: 40.sp,
                  color: _kPrimaryBlue,
                  height: 48 / 40,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Start your journey with real-time\nhazard detection and smart routing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: _kSubtitleGray,
                  height: 30 / 16,
                ),
              ),
              const Spacer(),
              SizedBox(height: 90.h),
            ],
          ),
        ),
      ],
    );
  }
}
