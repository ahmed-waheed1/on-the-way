import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Mirrors the backend `AssistanceType` enum (0=CarBreakdown, 1=FlatTire,
/// 2=MedicalHelp, 3=Weather), plus an `other` fallback for unknown values.
enum AssistanceType {
  carBreakdown,
  flatTire,
  medicalHelp,
  weather,
  other;

  String get label => switch (this) {
        AssistanceType.carBreakdown => 'Car Breakdown',
        AssistanceType.flatTire => 'Flat Tire',
        AssistanceType.medicalHelp => 'Medical Help',
        AssistanceType.weather => 'Weather',
        AssistanceType.other => 'Other',
      };

  /// Resolves a backend enum name (e.g. "CarBreakdown") or int to a type.
  static AssistanceType fromApi(dynamic value) {
    if (value is int && value >= 0 && value < 4) {
      return AssistanceType.values[value];
    }
    final s = (value?.toString() ?? '').toLowerCase().replaceAll(RegExp(r'[\s_]'), '');
    return switch (s) {
      'carbreakdown' || 'breakdown' => AssistanceType.carBreakdown,
      'flattire' => AssistanceType.flatTire,
      'medicalhelp' || 'medical' => AssistanceType.medicalHelp,
      'weather' => AssistanceType.weather,
      _ => AssistanceType.other,
    };
  }

  Color get badgeBg => switch (this) {
        AssistanceType.carBreakdown => AppColors.breakdownBadgeBg,
        AssistanceType.flatTire => AppColors.flatTireBadgeBg,
        AssistanceType.medicalHelp => AppColors.medicalBadgeBg,
        AssistanceType.weather => AppColors.weatherBadgeBg,
        AssistanceType.other => AppColors.otherBadgeBg,
      };

  Color get badgeTextColor => switch (this) {
        AssistanceType.carBreakdown => AppColors.breakdownBadgeText,
        AssistanceType.flatTire => AppColors.flatTireBadgeText,
        AssistanceType.medicalHelp => AppColors.medicalBadgeText,
        AssistanceType.weather => AppColors.weatherBadgeText,
        AssistanceType.other => AppColors.otherBadgeText,
      };
}

class AssistanceRequest extends Equatable {
  const AssistanceRequest({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.type,
  });

  final String id;
  final String name;
  final double distanceKm;
  final AssistanceType type;

  /// A feed item from GET /api/feed/assistance
  /// `{ id, locationName, type, distanceKm, createdAt, status }`.
  factory AssistanceRequest.fromFeedJson(Map<String, dynamic> json) {
    return AssistanceRequest(
      id: json['id']?.toString() ?? '',
      name: json['locationName']?.toString() ?? 'Unknown location',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      type: AssistanceType.fromApi(json['type']),
    );
  }

  @override
  List<Object?> get props => [id, name, distanceKm, type];
}
