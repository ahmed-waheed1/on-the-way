import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../app_assets.dart';

/// Generic card shared by Nearby Assistance and Nearby Accidents screens.
///
/// Each feature wraps this with its own entity-specific widget so the
/// domain layer stays independent of the shared UI.
class NearbyCard extends StatelessWidget {
  const NearbyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.onViewDetails,
    required this.onOfferHelp,
    this.actionLabel = 'Offer Help',
    this.isActionBusy = false,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeTextColor;
  final VoidCallback onViewDetails;
  final VoidCallback onOfferHelp;
  final String actionLabel;
  final bool isActionBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // ── Row 1: avatar + title/subtitle + badge ────────────────────────
          Row(
            children: [
              _Avatar(),
              SizedBox(width: 8.w),
              Expanded(
                child: _TitleSubtitle(title: title, subtitle: subtitle),
              ),
              SizedBox(width: 8.w),
              _Badge(
                label: badgeLabel,
                bg: badgeBg,
                textColor: badgeTextColor,
              ),
            ],
          ),
          SizedBox(height: 28.h),
          // ── Row 2: action buttons ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  label: 'View Details',
                  bg: AppColors.viewDetailsBg,
                  textColor: AppColors.viewDetailsText,
                  onTap: onViewDetails,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _CardButton(
                  label: actionLabel,
                  bg: AppColors.offerHelpBg,
                  textColor: AppColors.offerHelpText,
                  isBusy: isActionBusy,
                  onTap: isActionBusy ? () {} : onOfferHelp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: AppColors.avatarBackground,
        borderRadius: BorderRadius.circular(19.r),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppAssets.manIcon,
          width: 24.r,
          height: 24.r,
        ),
      ),
    );
  }
}

class _TitleSubtitle extends StatelessWidget {
  const _TitleSubtitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.bold,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            color: AppColors.nameText,
            height: 20 / 14,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.regular,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: AppColors.distanceText,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.bg,
    required this.textColor,
  });

  final String label;
  final Color bg;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23.h,
      constraints: BoxConstraints(minWidth: 56.w, maxWidth: 130.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.bold,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            color: textColor,
            height: 20 / 12,
          ),
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.bg,
    required this.textColor,
    required this.onTap,
    this.isBusy = false,
  });

  final String label;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 39.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: isBusy
              ? SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
                )
              : Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: textColor,
              height: 20 / 14,
            ),
          ),
        ),
      ),
    );
  }
}
