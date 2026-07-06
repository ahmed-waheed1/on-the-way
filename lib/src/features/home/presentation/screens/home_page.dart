import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/presentation/providers/session_provider.dart';

const _kSubtitleGray = Color(0xFFB1B6B6);
const _kCardShadow = [
  BoxShadow(
    color: Color(0x40000000),
    blurRadius: 4,
    offset: Offset(0, 4),
  ),
];

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sessionProvider); // keep session live for future user-aware widgets

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _EditFab(onTap: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const _BottomNavBar(currentIndex: 0),
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
                ),
                SizedBox(height: 24.h),

                // ── Map card ──────────────────────────────────────────────────
                const _MapCard(),
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
                    ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isPrimary ? null : _kCardShadow,
        ),
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
    );
  }
}

// ── Floating action button ────────────────────────────────────────────────────

class _EditFab extends StatelessWidget {
  const _EditFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54.r,
        height: 54.r,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.edit_outlined, size: 24.r, color: Colors.white),
      ),
    );
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            isActive: currentIndex == 0,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.report_problem_outlined,
            label: 'Accident',
            isActive: currentIndex == 1,
            onTap: () => context.push(AppRoutes.nearbyAccidents),
          ),
          _NavItem(
            icon: Icons.handyman_outlined,
            label: 'Assistance',
            isActive: currentIndex == 2,
            onTap: () => context.push(AppRoutes.nearbyAssistance),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            isActive: currentIndex == 3,
            onTap: () => context.push(AppRoutes.myAccount),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : _kSubtitleGray;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32.r, color: color),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: color,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}
