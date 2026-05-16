import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class NearbyNoMatchState extends StatelessWidget {
  const NearbyNoMatchState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 272.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 53.r,
              height: 53.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(26.5.r),
              ),
              padding: EdgeInsets.all(14.r),
              child: Icon(
                Icons.search_off_rounded,
                size: 24.r,
                color: AppColors.distanceText,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'No Results Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.bold,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: Colors.black,
                height: 20 / 16,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters to find what you\'re looking for.',
              textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
