import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/helpers/show_toast.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../data/assistance_service.dart';
import '../providers/help_request_provider.dart';

const _kStepTextColor = Color(0xFF6B7280);
const _kProgressTrack = Color(0xFFD9D9D9);
const _kIconBoxBg = Color(0xFF9FD3EB);
const _kEditColor = Color(0xFF185AC2);
const _kValueColor = Color(0xFFB1B6B6);
const _kDescriptionTextColor = Color(0xFF6B7280);

// Map image from Figma — replace with a real map widget in production
const _kMapImageUrl =
    'https://www.figma.com/api/mcp/asset/fa112750-fd3b-413a-a2df-c7bf44f42e79';

class ReviewRequestScreen extends HookConsumerWidget {
  const ReviewRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helpRequest = ref.watch(helpRequestProvider);
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final isSubmitting = useState(false);

    Future<void> submit() async {
      if (isSubmitting.value) return;
      if (helpRequest.helpType == null) return;
      if (helpRequest.latitude == null || helpRequest.longitude == null) {
        showToast(context,
            message: 'Please set your location before sending the request.',
            status: 'error');
        return;
      }
      if (helpRequest.image == null) {
        showToast(context,
            message: 'A photo is required — go back and add one.',
            status: 'error');
        return;
      }
      isSubmitting.value = true;
      final result = await AssistanceService.instance.request(
        type: helpRequest.helpType!.index,
        latitude: helpRequest.latitude!,
        longitude: helpRequest.longitude!,
        description: helpRequest.description,
        address: helpRequest.location,
        contactNumber: user?.phone,
        image: helpRequest.image,
      );
      isSubmitting.value = false;
      if (!context.mounted) return;
      result.fold(
        (f) => showToast(context, message: f.message, status: 'error'),
        (_) => context.push(AppRoutes.requestSent),
      );
    }

    final issueType = helpRequest.helpType?.title ?? '-';
    final descSummary = helpRequest.imageCount > 0
        ? '${helpRequest.imageCount} photo attached'
        : 'No photos';
    final descText = helpRequest.description;
    final address =
        helpRequest.location.isEmpty ? '-' : helpRequest.location;
    final contact = (user != null && user.isNotEmpty)
        ? (user.phone ?? user.email)
        : '-';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    const _SectionTitle('Issue Details'),
                    SizedBox(height: 16.h),
                    _DetailRow(
                      icon: Icons.report_problem_outlined,
                      label: 'Issue Type',
                      value: issueType,
                      onEdit: () {
                        context.pop(); // Step 3 → Step 2
                        context.pop(); // Step 2 → Step 1
                      },
                    ),
                    SizedBox(height: 16.h),
                    _DetailRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: descSummary,
                      onEdit: () => context.pop(),
                    ),
                    if (descText.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.only(left: 47.w),
                        child: Text(
                          descText,
                          style: TextStyle(
                            fontFamily: AppTypography.robotoFlex,
                            fontVariations: AppTypography.medium,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: _kDescriptionTextColor,
                            height: 20 / 12,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                    SizedBox(height: 16.h),
                    const _SectionTitle('Location'),
                    SizedBox(height: 16.h),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: address,
                      onEdit: () => context.pop(),
                    ),
                    SizedBox(height: 20.h),
                    const _MapImage(),
                    SizedBox(height: 16.h),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact Number',
                      value: contact,
                      onEdit: () {},
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
              child: Column(
                children: [
                  _ConfirmButton(
                    label: isSubmitting.value ? 'Sending…' : 'Confirm',
                    onTap: submit,
                  ),
                  SizedBox(height: 12.h),
                  _CancelButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header: back arrow + centered title + step progress ───────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.arrow_back,
                    size: 22.r,
                    color: AppColors.titleText,
                  ),
                ),
              ),
              Text(
                'Review Request',
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.bold,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: AppColors.titleText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Step 3 of 4',
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: _kStepTextColor,
            ),
          ),
          SizedBox(height: 6.h),
          const _ProgressBar(progress: 0.75),
          SizedBox(height: 14.h),
          const Center(child: _StepDots(total: 4, current: 2)),
        ],
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 6.h,
        child: Stack(
          children: [
            Container(color: _kProgressTrack),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
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
            color: isActive ? AppColors.primary : _kProgressTrack,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.bold,
        fontWeight: FontWeight.w700,
        fontSize: 20.sp,
        color: AppColors.titleText,
        height: 1,
      ),
    );
  }
}

// ── Detail row (icon box + label/value + edit link) ───────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 35.r,
          height: 35.r,
          decoration: BoxDecoration(
            color: _kIconBoxBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 22.r, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: _kValueColor,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Edit',
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.medium,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              color: _kEditColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Map image ─────────────────────────────────────────────────────────────────

class _MapImage extends StatelessWidget {
  const _MapImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(4, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: _kMapImageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: _kProgressTrack),
          errorWidget: (_, __, ___) => Container(color: _kProgressTrack),
        ),
      ),
    );
  }
}

// ── Confirm button ────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onTap, this.label = 'Confirm'});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 57.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
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

// ── Cancel button ─────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 57.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'Cancel',
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.black,
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            color: AppColors.primary,
            height: 20 / 16,
          ),
        ),
      ),
    );
  }
}
