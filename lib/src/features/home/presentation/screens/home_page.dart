import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/presentation/providers/session_provider.dart';

const _kSubtitleGray = Color(0xFFB1B6B6);
const _kCardShadow = [
  BoxShadow(
    color: Color(0x26000000),
    blurRadius: 10,
    offset: Offset(0, 3),
  ),
];

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(
        sessionProvider); // keep session live for future user-aware widgets

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton:
          _EditFab(onTap: () => context.push(AppRoutes.manageRoads)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),

                // ── Brand title ───────────────────────────────────────────────
                Text(
                  'On The Way',
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.extraBold,
                    fontWeight: FontWeight.w800,
                    fontSize: 32.sp,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                    height: 28 / 32,
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 350)),
                SizedBox(height: 24.h),

                // ── Map card ──────────────────────────────────────────────────
                const _MapCard()
                    .animate()
                    .fadeIn(
                        duration: const Duration(milliseconds: 350),
                        delay: const Duration(milliseconds: 80))
                    .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                SizedBox(height: 32.h),

                // ── Action buttons ────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: [
                      _ActionButton(
                        label: 'Report Accident',
                        icon: Icons.report_problem_outlined,
                        isPrimary: true,
                        onTap: () => context.push(AppRoutes.reportAccident),
                      ),
                      SizedBox(height: 16.h),
                      _ActionButton(
                        label: 'Request Assistance',
                        icon: Icons.handyman_outlined,
                        isPrimary: false,
                        onTap: () => context.push(AppRoutes.needHelp),
                      ),
                      SizedBox(height: 16.h),
                      _ActionButton(
                        label: 'My Request History',
                        icon: Icons.history,
                        isPrimary: false,
                        onTap: () => context.push(AppRoutes.requestHistory),
                      ),
                    ]
                        .animate(interval: const Duration(milliseconds: 70))
                        .fadeIn(
                            duration: const Duration(milliseconds: 300),
                            delay: const Duration(milliseconds: 150))
                        .slideY(begin: 0.06, curve: Curves.easeOutCubic),
                  ),
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Map card ──────────────────────────────────────────────────────────────────

class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _kCardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 135.h,
              width: double.infinity,
              child: Image.asset(
                AppAssets.homeHero,
                fit: BoxFit.cover,
                cacheWidth: 750,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: const Color(0xFFD9D9D9),
                  child: Center(
                    child: Icon(Icons.map_outlined,
                        color: Colors.grey, size: 40.r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 18.w,
                right: 18.w,
                top: 9.h,
                bottom: 12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sheik Zayed Road',
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: AppTypography.bold,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: Colors.black,
                      height: 20 / 16,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Road status: Open',
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: AppTypography.regular,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: _kSubtitleGray,
                      height: 20 / 16,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Weather: Clear',
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: AppTypography.regular,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: _kSubtitleGray,
                      height: 20 / 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? const Color(0xFFEEEEEE) : AppColors.titleText;
    final radius = BorderRadius.circular(12.r);
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : Colors.white,
        borderRadius: radius,
        boxShadow: isPrimary ? null : _kCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24.r, color: color),
              SizedBox(width: 16.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.bold,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: color,
                  height: 20 / 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating action button ────────────────────────────────────────────────────

class _EditFab extends StatelessWidget {
  const _EditFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54.r,
      height: 54.r,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(Icons.edit_outlined, size: 24.r, color: Colors.white),
        ),
      ),
    );
  }
}
