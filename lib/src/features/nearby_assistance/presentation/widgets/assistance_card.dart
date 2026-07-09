import 'package:flutter/material.dart';

import '../../../../shared/widgets/nearby_card.dart';
import '../../domain/entities/assistance_request.dart';

/// Thin wrapper that feeds an [AssistanceRequest] into the shared [NearbyCard].
class AssistanceCard extends StatelessWidget {
  const AssistanceCard({
    super.key,
    required this.request,
    required this.onViewDetails,
    required this.onOfferHelp,
    this.isOffering = false,
  });

  final AssistanceRequest request;
  final VoidCallback onViewDetails;
  final VoidCallback onOfferHelp;
  final bool isOffering;

  @override
  Widget build(BuildContext context) {
    return NearbyCard(
      title: request.name,
      subtitle: '${request.distanceKm.toStringAsFixed(1)} km away',
      badgeLabel: request.type.label,
      badgeBg: request.type.badgeBg,
      badgeTextColor: request.type.badgeTextColor,
      onViewDetails: onViewDetails,
      onOfferHelp: onOfferHelp,
      isActionBusy: isOffering,
    );
  }
}
