import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

enum AssistanceType {
  breakdown,
  weather,
  flatTire,
  accident,
  fuel,
  other;

  String get label => switch (this) {
        AssistanceType.breakdown => 'Breakdown',
        AssistanceType.weather => 'Weather',
        AssistanceType.flatTire => 'Flat Tire',
        AssistanceType.accident => 'Accident',
        AssistanceType.fuel => 'Fuel',
        AssistanceType.other => 'Other',
      };

  Color get badgeBg => switch (this) {
        AssistanceType.breakdown => AppColors.breakdownBadgeBg,
        AssistanceType.weather => AppColors.weatherBadgeBg,
        AssistanceType.flatTire => AppColors.flatTireBadgeBg,
        AssistanceType.accident => AppColors.assistanceAccidentBadgeBg,
        AssistanceType.fuel => AppColors.fuelBadgeBg,
        AssistanceType.other => AppColors.otherBadgeBg,
      };

  Color get badgeTextColor => switch (this) {
        AssistanceType.breakdown => AppColors.breakdownBadgeText,
        AssistanceType.weather => AppColors.weatherBadgeText,
        AssistanceType.flatTire => AppColors.flatTireBadgeText,
        AssistanceType.accident => AppColors.assistanceAccidentBadgeText,
        AssistanceType.fuel => AppColors.fuelBadgeText,
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

  @override
  List<Object?> get props => [id, name, distanceKm, type];
}
