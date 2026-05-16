import 'package:flutter/material.dart';

/// Centralized color palette for On The Way.
///
/// All hardcoded [Color] values across the app must live here.
/// Reference via `AppColors.primary`, etc. — never write a raw hex in a widget.
abstract final class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF025D8C);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color screenBackground = Color(0xFFF5F6F8);
  static const Color cardBackground = Colors.white;
  static const Color avatarBackground = Color(0xFFF3F4F6);

  // ── Filter chips ──────────────────────────────────────────────────────────
  static const Color chipActiveBg = primary;
  static const Color chipInactiveBg = Color(0xFFD9D9D9);
  static const Color chipActiveText = Color(0xFFEEEEEE);
  static const Color chipInactiveText = Colors.black;

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color titleText = Color(0xFF222222);
  static const Color nameText = Color(0xFF222222);
  static const Color distanceText = Color(0xFFB1B6B6);
  static const Color viewDetailsText = Color(0xFF273E63);
  static const Color offerHelpText = Color(0xFFEEEEEE);

  // ── Card buttons ──────────────────────────────────────────────────────────
  static const Color viewDetailsBg = Color(0xFFF3F4F6);
  static const Color offerHelpBg = primary;

  // ── Assistance badge colours ───────────────────────────────────────────────
  static const Color breakdownBadgeBg = Color(0xFFD1E8F2);
  static const Color breakdownBadgeText = Color(0xFF025D8C);
  static const Color weatherBadgeBg = Color(0xFF909A90);
  static const Color weatherBadgeText = Color(0xFFEEEEEE);
  static const Color flatTireBadgeBg = Color(0xFFFEF3C7);
  static const Color flatTireBadgeText = Color(0xFF988724);
  static const Color fuelBadgeBg = Color(0xFFFFF3CD);
  static const Color fuelBadgeText = Color(0xFF92400E);
  static const Color assistanceAccidentBadgeBg = Color(0xFFFFE4E6);
  static const Color assistanceAccidentBadgeText = Color(0xFF9B1C1C);
  static const Color otherBadgeBg = Color(0xFFE5E7EB);
  static const Color otherBadgeText = Color(0xFF4B5563);

  // ── Accident badge colours ─────────────────────────────────────────────────
  static const Color crashBadgeBg = Color(0xFFD1E8F2);
  static const Color crashBadgeText = Color(0xFF025D8C);
  static const Color medicalBadgeBg = Color(0xFFA8F2DA);
  static const Color medicalBadgeText = Color(0xFF128652);
  static const Color fireBadgeBg = Color(0xFFFFB8B8);
  static const Color fireBadgeText = Color(0xFFBA0F0F);
  static const Color roadblockBadgeBg = Color(0xFFFEF3C7);
  static const Color roadblockBadgeText = Color(0xFF988724);
  static const Color floodBadgeBg = Color(0xFFDBEAFE);
  static const Color floodBadgeText = Color(0xFF1D4ED8);
}
