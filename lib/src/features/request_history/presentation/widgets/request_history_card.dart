import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/entities/request_history_item.dart';

/// A single request in the "My Request History" list.
///
/// Shows the request type, date and location alongside a status badge,
/// with a "View Details" action separated by a divider.
class RequestHistoryCard extends StatelessWidget {
  const RequestHistoryCard({
    super.key,
    required this.item,
    required this.onViewDetails,
  });

  final RequestHistoryItem item;
  final VoidCallback onViewDetails;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _formattedDate =>
      '${item.date.day} ${_months[item.date.month - 1]} ${item.date.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.requestHistoryCardBg,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Row 1: icon + details + status badge ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(icon: item.type.icon),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type.label,
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.regular,
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Colors.black,
                        height: 20 / 16,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formattedDate,
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.regular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: AppColors.titleText,
                        height: 20 / 12,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.regular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Colors.black,
                        height: 20 / 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(status: item.status),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Divider ───────────────────────────────────────────────────────
          const Divider(
              height: 1, thickness: 1, color: AppColors.requestCardDivider),
          SizedBox(height: 16.h),

          // ── View details ──────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewDetails,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Center(
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: AppTypography.bold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: AppColors.viewDetailsLinkText,
                      height: 20 / 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.r,
      height: 35.r,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, size: 24.r, color: AppColors.primary),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: status.badgeBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          status.label,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.bold,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            color: status.badgeTextColor,
            height: 20 / 12,
          ),
        ),
      ),
    );
  }
}
