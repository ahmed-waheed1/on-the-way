import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:on_the_way/src/routing/app_routes.dart';
import 'package:on_the_way/src/theme/app_colors.dart';
import 'package:on_the_way/src/theme/app_typography.dart';

const _kInactiveGray = Color(0xFFB1B6B6);

/// The app-wide bottom navigation bar shared by the four main tabs
/// (Home, Accident, Assistance, Profile).
///
/// Uses `context.go` so switching tabs replaces the stack instead of piling
/// screens on top of each other, and animates the active tab with a smooth
/// pill highlight.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  static const _tabs = [
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: AppRoutes.home
    ),
    (
      icon: Icons.report_problem_outlined,
      activeIcon: Icons.report_problem,
      label: 'Accident',
      route: AppRoutes.nearbyAccidents
    ),
    (
      icon: Icons.handyman_outlined,
      activeIcon: Icons.handyman,
      label: 'Assistance',
      route: AppRoutes.nearbyAssistance
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: AppRoutes.myAccount
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72.h,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavItem(
                  icon: isActive ? tab.activeIcon : tab.icon,
                  label: tab.label,
                  isActive: isActive,
                  onTap: () {
                    if (!isActive) context.go(tab.route);
                  },
                ),
              );
            }),
          ),
        ),
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
    final color = isActive ? AppColors.primary : _kInactiveGray;
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 46.r,
        highlightShape: BoxShape.circle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16.w : 0,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, size: 26.r, color: color),
            ),
            SizedBox(height: 3.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations:
                    isActive ? AppTypography.semiBold : AppTypography.regular,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12.sp,
                color: color,
                height: 16 / 12,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
