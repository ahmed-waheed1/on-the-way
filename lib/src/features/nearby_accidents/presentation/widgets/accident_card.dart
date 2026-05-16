import 'package:flutter/material.dart';

import '../../../../shared/widgets/nearby_card.dart';
import '../../domain/entities/accident_report.dart';

/// Thin wrapper that feeds an [AccidentReport] into the shared [NearbyCard].
class AccidentCard extends StatelessWidget {
  const AccidentCard({
    super.key,
    required this.report,
    required this.onViewDetails,
    required this.onOfferHelp,
  });

  final AccidentReport report;
  final VoidCallback onViewDetails;
  final VoidCallback onOfferHelp;

  @override
  Widget build(BuildContext context) {
    return NearbyCard(
      title: report.name,
      subtitle: '${report.distanceKm.toStringAsFixed(1)} km away',
      badgeLabel: report.type.label,
      badgeBg: report.type.badgeBg,
      badgeTextColor: report.type.badgeTextColor,
      onViewDetails: onViewDetails,
      onOfferHelp: onOfferHelp,
    );
  }
}
