import 'dart:math';

import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/report_accident/presentation/providers/accident_report_provider.dart';

const _kLabelColor = Color(0xFF6B7280);
const _kStatusOpen = Color(0xFFFF305D);
const _kContactIconBg = Color(0xFF9FD3EB);
const _kHPadding = 25.0;

class ReviewAccidentScreen extends HookConsumerWidget {
  const ReviewAccidentScreen({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDateTime(DateTime d) {
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}, $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(accidentReportProvider);
    final notifier = ref.read(accidentReportProvider.notifier);

    // A stable, human-readable request id for this review session.
    final requestId = useMemoized(() {
      final r = Random();
      return '${r.nextInt(900) + 100}-${r.nextInt(900) + 100}';
    });

    void finish({required String message, required String status}) {
      showToast(context, message: message, status: status);
      notifier.reset();
      context.go(AppRoutes.home);
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const AppTopBar(title: 'Request Details', isTransparent: false),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            const Center(child: _StepDots(total: 4, current: 2)),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Illustration ──────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          height: 205.h,
                          width: double.infinity,
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Image.asset(
                            AppAssets.accidentIllustration,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // ── Request ID + Status ───────────────────────────────────
                    _WhiteBand(
                      child: Column(
                        children: [
                          _SpaceBetweenRow(
                            label: 'Request ID',
                            value: requestId,
                            valueColor: AppColors.titleText,
                          ),
                          SizedBox(height: 7.h),
                          const _SpaceBetweenRow(
                            label: 'Status',
                            value: 'Open',
                            valueColor: _kStatusOpen,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 13.h),

                    // ── Request details ───────────────────────────────────────
                    _WhiteBand(
                      verticalPadding: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(
                            label: 'Incident Type',
                            value: draft.type?.label ?? '—',
                          ),
                          SizedBox(height: 28.h),
                          _DetailRow(
                            label: 'Date',
                            value: draft.date == null
                                ? '—'
                                : _formatDateTime(draft.date!),
                          ),
                          SizedBox(height: 28.h),
                          _DetailRow(
                            label: 'Description',
                            value: draft.description.isEmpty ? '—' : draft.description,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Contact method ────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _kHPadding.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Method',
                            style: TextStyle(
                              fontFamily: AppTypography.robotoFlex,
                              fontVariations: AppTypography.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.sp,
                              color: AppColors.titleText,
                              height: 20 / 16,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Container(
                                width: 35.r,
                                height: 35.r,
                                padding: EdgeInsets.all(5.r),
                                decoration: BoxDecoration(
                                  color: _kContactIconBg,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(Icons.phone_outlined,
                                    size: 24.r, color: AppColors.primary),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Contact Via Phone',
                                style: TextStyle(
                                  fontFamily: AppTypography.robotoFlex,
                                  fontVariations: AppTypography.regular,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: AppColors.titleText,
                                  height: 20 / 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Phone number',
                                style: TextStyle(
                                  fontFamily: AppTypography.robotoFlex,
                                  fontVariations: AppTypography.regular,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: _kLabelColor,
                                  height: 20 / 16,
                                ),
                              ),
                              Text(
                                draft.phoneNumber.isEmpty ? '—' : draft.phoneNumber,
                                style: TextStyle(
                                  fontFamily: AppTypography.robotoFlex,
                                  fontVariations: AppTypography.regular,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: AppColors.titleText,
                                  height: 20 / 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // ── Confirm / Cancel ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 24.h),
              child: Column(
                children: [
                  _PrimaryButton(
                    label: 'Confirm',
                    onTap: () => context.push(AppRoutes.accidentSent),
                  ),
                  SizedBox(height: 12.h),
                  _OutlineButton(
                    label: 'Cancel',
                    onTap: () => finish(
                      message: 'Report cancelled',
                      status: 'info',
                    ),
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

// ── White full-width band ───────────────────────────────────────────────────────

class _WhiteBand extends StatelessWidget {
  const _WhiteBand({required this.child, this.verticalPadding = 16});

  final Widget child;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: _kHPadding.w,
        vertical: verticalPadding.h,
      ),
      child: child,
    );
  }
}

// ── Space-between row (label / value at edges) ──────────────────────────────────

class _SpaceBetweenRow extends StatelessWidget {
  const _SpaceBetweenRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.bold,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            color: _kLabelColor,
            height: 20 / 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.bold,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            color: valueColor,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

// ── Detail row (fixed-width label + value column) ───────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: _kLabelColor,
              height: 20 / 16,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: AppColors.titleText,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step dots ───────────────────────────────────────────────────────────────────

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

// ── Primary button ──────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12.r),
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

// ── Outline button ──────────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
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
            color: AppColors.primary,
            height: 20 / 16,
          ),
        ),
      ),
    );
  }
}
