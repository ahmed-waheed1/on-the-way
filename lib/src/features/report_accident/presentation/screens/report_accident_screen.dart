import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/nearby_accidents/domain/entities/accident_report.dart';
import 'package:on_the_way/src/features/report_accident/presentation/providers/accident_report_provider.dart';

const _kFieldBg = Color(0xFFD9D9D9);
const _kPlaceholderColor = Color(0xFF909A90);

class ReportAccidentScreen extends HookConsumerWidget {
  const ReportAccidentScreen({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(accidentReportProvider);
    final notifier = ref.read(accidentReportProvider.notifier);
    final isFetchingLocation = useState(false);

    Future<void> pickType() async {
      final selected = await _showTypeSheet(context, draft.type);
      if (selected != null) notifier.setType(selected);
    }

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: draft.date ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: context.theme.copyWith(
            colorScheme: context.theme.colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) notifier.setDate(picked);
    }

    Future<void> fetchLocation() async {
      if (isFetchingLocation.value) return;
      isFetchingLocation.value = true;
      final result = await LocationService.instance.resolveLocation();
      isFetchingLocation.value = false;
      if (!context.mounted) return;
      result.fold(
        (failure) => showToast(context, message: failure.message, status: 'error'),
        (loc) => notifier.setLocation(
          loc.address,
          latitude: loc.position.latitude,
          longitude: loc.position.longitude,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Report Accident'),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            const Center(child: _StepDots(total: 4, current: 0)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 21.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 42.h),

                    // ── Accident Type ─────────────────────────────────────────
                    const _FieldLabel('Accident Type'),
                    SizedBox(height: 8.h),
                    _SelectField(
                      value: draft.type?.label,
                      placeholder: 'Select type',
                      trailing: Icon(Icons.arrow_drop_down,
                          size: 24.r, color: _kPlaceholderColor),
                      onTap: pickType,
                    ),
                    SizedBox(height: 52.h),

                    // ── Date ──────────────────────────────────────────────────
                    const _FieldLabel('Date'),
                    SizedBox(height: 8.h),
                    _SelectField(
                      value: draft.date == null ? null : _formatDate(draft.date!),
                      placeholder: 'Select date',
                      trailing: Icon(Icons.calendar_today_outlined,
                          size: 20.r, color: _kPlaceholderColor),
                      onTap: pickDate,
                    ),
                    SizedBox(height: 52.h),

                    // ── Location ──────────────────────────────────────────────
                    const _FieldLabel('Location'),
                    SizedBox(height: 8.h),
                    _SelectField(
                      value: draft.location.isEmpty ? null : draft.location,
                      placeholder: 'Tap to get your location',
                      trailing: isFetchingLocation.value
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(Icons.my_location_outlined,
                              size: 22.r, color: _kPlaceholderColor),
                      onTap: isFetchingLocation.value ? null : fetchLocation,
                    ),
                  ],
                ),
              ),
            ),

            // ── Next ──────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 24.h),
              child: _NextButton(
                enabled: draft.isStepOneComplete,
                onTap: () => context.push(AppRoutes.describeAccident),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Accident type bottom sheet ──────────────────────────────────────────────────

Future<AccidentType?> _showTypeSheet(BuildContext context, AccidentType? current) {
  return showModalBottomSheet<AccidentType>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Accident Type',
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.bold,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: AppColors.titleText,
              ),
            ),
            SizedBox(height: 8.h),
            ...AccidentType.values.map(
              (type) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  type.label,
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations:
                        type == current ? AppTypography.bold : AppTypography.regular,
                    fontSize: 16.sp,
                    color: type == current ? AppColors.primary : AppColors.titleText,
                  ),
                ),
                trailing: type == current
                    ? Icon(Icons.check, size: 20.r, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(type),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    ),
  );
}

// ── Field label ─────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: AppColors.titleText,
        height: 20 / 16,
      ),
    );
  }
}

// ── Select field (grey box) ─────────────────────────────────────────────────────

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.value,
    required this.placeholder,
    required this.trailing,
    required this.onTap,
  });

  final String? value;
  final String placeholder;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == null || value!.isEmpty;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: _kFieldBg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isPlaceholder ? placeholder : value!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: isPlaceholder ? _kPlaceholderColor : AppColors.titleText,
                  height: 20 / 12,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            trailing,
          ],
        ),
      ),
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

// ── Next button ─────────────────────────────────────────────────────────────────

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
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12.r),
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
