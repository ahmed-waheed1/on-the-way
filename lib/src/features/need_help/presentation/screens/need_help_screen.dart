import 'package:flutter/material.dart';

import '../../../../imports/packages_imports.dart';
import '../../../../routing/app_routes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/entities/help_type.dart';
import '../providers/help_request_provider.dart';

const _kCardSelectedBg = Color(0xFFDCE7FF);
const _kSubtitleColor = Color(0xFF6B7280);
const _kIconUnselectedColor = Color(0xFF374151);

class NeedHelpScreen extends HookConsumerWidget {
  const NeedHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState<HelpType?>(null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 28.h),

              // ── Brand ────────────────────────────────────────────────────────
              Center(
                child: Text(
                  'On The Way',
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.extraBold,
                    fontWeight: FontWeight.w800,
                    fontSize: 32.sp,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // ── Question ──────────────────────────────────────────────────────
              Text(
                'What kind of help do you need?',
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.bold,
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                  color: AppColors.titleText,
                ),
              ),
              SizedBox(height: 16.h),

              // ── Step dots ─────────────────────────────────────────────────────
              const Center(child: _StepDots(total: 4, current: 0)),
              SizedBox(height: 20.h),

              // ── Help type grid ────────────────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 10.w) / 2;
                    final cardHeight = (constraints.maxHeight - 12.h) / 2;
                    return GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: cardWidth / cardHeight,
                      children: HelpType.values.map((type) {
                        return _HelpCard(
                          type: type,
                          isSelected: selected.value == type,
                          onTap: () => selected.value = type,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),

              // ── Next button ───────────────────────────────────────────────────
              _NextButton(
                enabled: selected.value != null,
                onTap: () {
                  ref
                      .read(helpRequestProvider.notifier)
                      .setHelpType(selected.value!);
                  context.push(AppRoutes.describeIssue);
                },
              ),
              SizedBox(height: 28.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step dots ─────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 18.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

// ── Help card ─────────────────────────────────────────────────────────────────

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final HelpType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _kCardSelectedBg : Colors.white,
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              type.iconPath,
              width: 24.r,
              height: 24.r,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.primary : _kIconUnselectedColor,
                BlendMode.srcIn,
              ),
            ),
            const Spacer(),
            Text(
              type.title,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.semiBold,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: AppColors.titleText,
                height: 20 / 16,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              type.subtitle,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.semiBold,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: _kSubtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Next button ───────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.h,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'Next',
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.black,
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            color: const Color(0xFFEEEEEE),
            height: 20 / 16,
          ),
        ),
      ),
    );
  }
}
