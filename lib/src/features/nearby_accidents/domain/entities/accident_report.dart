import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Mirrors the backend `IncidentType` enum (order = wire value 0-4):
/// 0=Collision, 1=RoadClosure, 2=Obstacle, 3=SevereWeather, 4=VehicleBreakdown.
/// The enum index is sent to the API, so the order must not change.
enum AccidentType {
  collision,
  roadClosure,
  obstacle,
  severeWeather,
  vehicleBreakdown;

  String get label => switch (this) {
        AccidentType.collision => 'Collision',
        AccidentType.roadClosure => 'Road Closure',
        AccidentType.obstacle => 'Obstacle',
        AccidentType.severeWeather => 'Severe Weather',
        AccidentType.vehicleBreakdown => 'Vehicle Breakdown',
      };

  /// The backend's PascalCase enum name (used to match feed/history `type`).
  String get apiName => switch (this) {
        AccidentType.collision => 'Collision',
        AccidentType.roadClosure => 'RoadClosure',
        AccidentType.obstacle => 'Obstacle',
        AccidentType.severeWeather => 'SevereWeather',
        AccidentType.vehicleBreakdown => 'VehicleBreakdown',
      };

  /// Resolves a backend enum name (or int string) to an [AccidentType].
  static AccidentType fromApi(dynamic value) {
    if (value is int && value >= 0 && value < AccidentType.values.length) {
      return AccidentType.values[value];
    }
    final s = value?.toString() ?? '';
    return AccidentType.values.firstWhere(
      (t) => t.apiName.toLowerCase() == s.toLowerCase(),
      orElse: () => AccidentType.collision,
    );
  }

  Color get badgeBg => switch (this) {
        AccidentType.collision => AppColors.crashBadgeBg,
        AccidentType.roadClosure => AppColors.roadblockBadgeBg,
        AccidentType.obstacle => AppColors.otherBadgeBg,
        AccidentType.severeWeather => AppColors.floodBadgeBg,
        AccidentType.vehicleBreakdown => AppColors.fireBadgeBg,
      };

  Color get badgeTextColor => switch (this) {
        AccidentType.collision => AppColors.crashBadgeText,
        AccidentType.roadClosure => AppColors.roadblockBadgeText,
        AccidentType.obstacle => AppColors.otherBadgeText,
        AccidentType.severeWeather => AppColors.floodBadgeText,
        AccidentType.vehicleBreakdown => AppColors.fireBadgeText,
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

  /// A feed item from GET /api/feed/incidents
  /// `{ id, locationName, type, distanceKm, createdAt, status }`.
  factory AccidentReport.fromFeedJson(Map<String, dynamic> json) {
    return AccidentReport(
      id: json['id']?.toString() ?? '',
      name: json['locationName']?.toString() ?? 'Unknown location',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      type: AccidentType.fromApi(json['type']),
    );
  }

  @override
  List<Object?> get props => [id, name, distanceKm, type];
}
