import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_typography.dart';

/// Named, responsive [TextStyle] presets for On The Way.
///
/// All sizes use [ScreenUtil] (`.sp`) so they scale with the device.
/// Always pass [color] at the call site — styles here are color-agnostic
/// unless the color is semantically baked in (e.g. SOS button text).
///
/// Usage:
/// ```dart
/// Text('On The Way', style: AppTextStyles.onboardingHero.copyWith(color: AppColors.primary))
/// Text('SOS', style: AppTextStyles.sosLabel)
/// ```
abstract final class AppTextStyles {
  AppTextStyles._();

  // ── Onboarding ────────────────────────────────────────────────────────────

  /// Large hero title — used for the app branding line on onboarding page 1.
  /// 40 sp · ExtraBold (wght 800) · tracking –0.5
  static TextStyle get onboardingHero => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.extraBold,
        fontWeight: FontWeight.w800,
        fontSize: 40.sp,
        letterSpacing: -0.5,
      );

  /// Supporting subtitle on onboarding screens.
  /// 16 sp · Regular (wght 400) · line-height 1.875
  static TextStyle get onboardingSubtitle => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        height: 1.875,
      );

  // ── SOS Button ────────────────────────────────────────────────────────────

  /// Primary SOS label inside the emergency button.
  /// 36 sp · ExtraBold · tracking 3.6 · always white
  static TextStyle get sosLabel => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.extraBold,
        fontWeight: FontWeight.w800,
        fontSize: 36.sp,
        color: Colors.white,
        letterSpacing: 3.6,
        height: 1.1,
      );

  /// "HOLD TO TRIGGER" hint inside the SOS button.
  /// 10 sp · Regular · tracking 2 · 80 % white
  static TextStyle get sosTriggerHint => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 10.sp,
        color: Colors.white.withValues(alpha: 0.8),
        letterSpacing: 2,
      );

  // ── General Purpose ───────────────────────────────────────────────────────

  /// Extra-large display — splash / hero moments.
  /// 48 sp · ExtraBold
  static TextStyle get displayXl => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.extraBold,
        fontWeight: FontWeight.w800,
        fontSize: 48.sp,
        letterSpacing: -0.5,
      );

  /// Standard page title / screen heading.
  /// 24 sp · Bold
  static TextStyle get pageTitle => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.bold,
        fontWeight: FontWeight.w700,
        fontSize: 24.sp,
        letterSpacing: -0.25,
      );

  /// Section heading inside a scrollable page.
  /// 18 sp · SemiBold
  static TextStyle get sectionHeading => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.semiBold,
        fontWeight: FontWeight.w600,
        fontSize: 18.sp,
      );

  /// Standard body copy.
  /// 14 sp · Regular · line-height 1.5
  static TextStyle get body => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        height: 1.5,
      );

  /// Small caption or metadata text.
  /// 12 sp · Regular
  static TextStyle get caption => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        letterSpacing: 0.4,
      );

  /// Button / control label.
  /// 14 sp · SemiBold · tracking 0.1
  static TextStyle get buttonLabel => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.semiBold,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        letterSpacing: 0.1,
      );

  /// Overline / badge / uppercase tag.
  /// 10 sp · Medium · tracking 1.5 · uppercase handled at call site
  static TextStyle get overline => TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.medium,
        fontWeight: FontWeight.w500,
        fontSize: 10.sp,
        letterSpacing: 1.5,
      );
}
