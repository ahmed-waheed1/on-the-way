import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

enum AccidentType {
  crash,
  medical,
  fire,
  roadblock,
  flood;

  String get label => switch (this) {
        AccidentType.crash => 'Crash',
        AccidentType.medical => 'Medical',
        AccidentType.fire => 'Fire',
        AccidentType.roadblock => 'Roadblock',
        AccidentType.flood => 'Flood',
      };

  Color get badgeBg => switch (this) {
        AccidentType.crash => AppColors.crashBadgeBg,
        AccidentType.medical => AppColors.medicalBadgeBg,
        AccidentType.fire => AppColors.fireBadgeBg,
        AccidentType.roadblock => AppColors.roadblockBadgeBg,
        AccidentType.flood => AppColors.floodBadgeBg,
      };

  Color get badgeTextColor => switch (this) {
        AccidentType.crash => AppColors.crashBadgeText,
        AccidentType.medical => AppColors.medicalBadgeText,
        AccidentType.fire => AppColors.fireBadgeText,
        AccidentType.roadblock => AppColors.roadblockBadgeText,
        AccidentType.flood => AppColors.floodBadgeText,
      };
}

class AccidentReport extends Equatable {
  const AccidentReport({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.type,
  });

  final String id;
  final String name;
  final double distanceKm;
  final AccidentType type;

  @override
  List<Object?> get props => [id, name, distanceKm, type];
}
