import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen highway background
          Image.asset('assets/images/splash.png', fit: BoxFit.cover),

          // 70% white overlay — Figma rgba(255,255,255,0.7)
          ColoredBox(color: Colors.white.withValues(alpha: 0.7)),

          // Centred brand mark
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Road icon — slides up + fades in
                SvgPicture.asset(
                  'assets/icons/onboarding1-2.svg',
                  width: 32.r,
                  height: 32.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                    ),

                SizedBox(height: 8.h),

                // "On The Way" title — slightly staggered entry
                Text(
                  'On The Way',
                  style: AppTextStyles.onboardingHero.copyWith(
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 650),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      delay: const Duration(milliseconds: 650),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
