import 'package:flutter/material.dart';

/// Font family name and variable-font axis presets for Roboto Flex.
///
/// Roboto Flex is a variable font — use [FontVariation] to control axes
/// precisely instead of relying solely on [FontWeight].
///
/// Usage:
/// ```dart
/// TextStyle(
///   fontFamily: AppTypography.robotoFlex,
///   fontVariations: AppTypography.extraBold,
///   fontWeight: FontWeight.w800, // kept for accessibility / fallback
/// )
/// ```
abstract final class AppTypography {
  AppTypography._();

  /// Font family name — must match the `family` key in pubspec.yaml.
  static const String robotoFlex = 'RobotoFlex';

  // ── Weight axis presets (wght: 100–1000) ──────────────────────────────────

  static const List<FontVariation> thin       = [FontVariation('wght', 100)];
  static const List<FontVariation> extraLight = [FontVariation('wght', 200)];
  static const List<FontVariation> light      = [FontVariation('wght', 300)];
  static const List<FontVariation> regular    = [FontVariation('wght', 400)];
  static const List<FontVariation> medium     = [FontVariation('wght', 500)];
  static const List<FontVariation> semiBold   = [FontVariation('wght', 600)];
  static const List<FontVariation> bold       = [FontVariation('wght', 700)];
  static const List<FontVariation> extraBold  = [FontVariation('wght', 800)];
  static const List<FontVariation> black      = [FontVariation('wght', 900)];

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns a single [FontVariation] for the `wght` axis.
  static List<FontVariation> weight(double w) => [FontVariation('wght', w)];

  /// Returns variations for weight + width (`wdth`) axes combined.
  static List<FontVariation> weightWidth(double w, double wdth) => [
        FontVariation('wght', w),
        FontVariation('wdth', wdth),
      ];
}
