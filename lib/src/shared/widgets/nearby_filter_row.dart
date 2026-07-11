import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Horizontal scrollable filter-chip row shared by Nearby Assistance
/// and Nearby Accidents screens.
///
/// [activeFilters] is a [Set] so multiple chips can be highlighted at once.
class NearbyFilterRow extends StatelessWidget {
  const NearbyFilterRow({
    super.key,
    required this.filters,
    required this.activeFilters,
    required this.onChipTap,
  });

  final List<String> filters;
  final Set<String> activeFilters;
  final ValueChanged<String> onChipTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((label) {
          final isActive = activeFilters.contains(label);
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: _FilterChip(
              label: label,
              isActive: isActive,
              onTap: () => onChipTap(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isActive ? 30.h : 28.h,
        constraints: BoxConstraints(minWidth: isActive ? 58.w : 76.w),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18.w : 4.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.chipActiveBg : AppColors.chipInactiveBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: isActive
                  ? AppColors.chipActiveText
                  : AppColors.chipInactiveText,
            ),
          ),
        ),
      ),
    );
  }
}
