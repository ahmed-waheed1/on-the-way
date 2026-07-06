import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/report_accident/presentation/providers/accident_report_provider.dart';

const _kPlaceholderColor = Color(0xFFB1B6B6);
const _kAddPhotoBg = Color(0xCCB1B6B6);
const _kContactIconBg = Color(0xFF9FD3EB);

class DescribeAccidentScreen extends HookConsumerWidget {
  const DescribeAccidentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(accidentReportProvider.notifier);
    final descriptionController = useTextEditingController(
      text: ref.read(accidentReportProvider).description,
    );
    final phoneController = useTextEditingController(
      text: ref.read(accidentReportProvider).phoneNumber,
    );
    final pickedImages = useState<List<XFile>>([]);
    final hasDescription = useState(descriptionController.text.trim().isNotEmpty);
    final hasPhone = useState(phoneController.text.trim().isNotEmpty);

    useEffect(() {
      void l() => hasDescription.value = descriptionController.text.trim().isNotEmpty;
      descriptionController.addListener(l);
      return () => descriptionController.removeListener(l);
    }, [descriptionController]);

    useEffect(() {
      void l() => hasPhone.value = phoneController.text.trim().isNotEmpty;
      phoneController.addListener(l);
      return () => phoneController.removeListener(l);
    }, [phoneController]);

    Future<void> pickImage() async {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        pickedImages.value = [...pickedImages.value, file];
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Report Accident'),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            const Center(child: _StepDots(total: 4, current: 1)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // ── Subtitle ──────────────────────────────────────────────
                    Center(
                      child: Text(
                        'Please describe what happened and add a photo if possible.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: AppTypography.regular,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.titleText,
                          height: 20 / 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // ── Description ───────────────────────────────────────────
                    const _Label('Describe the Accident', color: Colors.black),
                    SizedBox(height: 8.h),
                    _DescriptionField(controller: descriptionController),
                    SizedBox(height: 24.h),

                    // ── Upload photo ──────────────────────────────────────────
                    _UploadPhotoBox(
                      imageCount: pickedImages.value.length,
                      onPickImage: pickImage,
                    ),
                    SizedBox(height: 28.h),

                    // ── Contact method ────────────────────────────────────────
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
                    SizedBox(height: 16.h),

                    // ── Phone number ──────────────────────────────────────────
                    const _Label('Phone Number', color: AppColors.titleText),
                    SizedBox(height: 12.h),
                    _PhoneField(controller: phoneController),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 24.h),
              child: Column(
                children: [
                  _NextButton(
                    enabled: hasDescription.value && hasPhone.value,
                    onTap: () {
                      notifier.setDescription(descriptionController.text.trim());
                      notifier.setPhoneNumber(phoneController.text.trim());
                      notifier.setImageCount(pickedImages.value.length);
                      context.push(AppRoutes.reviewAccident);
                    },
                  ),
                  SizedBox(height: 12.h),
                  _CancelButton(
                    onTap: () {
                      notifier.reset();
                      context.go(AppRoutes.home);
                    },
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

// ── Field label ─────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.regular,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: color,
        height: 20 / 16,
      ),
    );
  }
}

// ── Description textarea ────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: AppColors.primary,
        style: TextStyle(
          fontFamily: AppTypography.robotoFlex,
          fontVariations: AppTypography.regular,
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: AppColors.titleText,
          height: 20 / 16,
        ),
        decoration: InputDecoration(
          hintText: 'Please provide as much details as possible....',
          hintStyle: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.regular,
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            color: _kPlaceholderColor,
            height: 20 / 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12.r),
        ),
      ),
    );
  }
}

// ── Upload photo box ────────────────────────────────────────────────────────────

class _UploadPhotoBox extends StatelessWidget {
  const _UploadPhotoBox({required this.imageCount, required this.onPickImage});

  final int imageCount;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: Colors.black,
          radius: 12.r,
          strokeWidth: 1.2,
        ),
        child: Container(
          width: double.infinity,
          height: 236.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                offset: Offset(4, 4),
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 32.r, color: AppColors.titleText),
              SizedBox(height: 18.h),
              Text(
                'Upload Photo',
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.bold,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: AppColors.titleText,
                  height: 20 / 16,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                imageCount == 0
                    ? 'Tap here to add a photo (Optional)'
                    : '$imageCount photo${imageCount == 1 ? '' : 's'} added',
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.medium,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: _kPlaceholderColor,
                  height: 20 / 14,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: 100.w,
                height: 37.h,
                decoration: BoxDecoration(
                  color: _kAddPhotoBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Add Photo',
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.bold,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: AppColors.titleText,
                    height: 20 / 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dashed border painter ───────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  static const double dashLength = 8;
  static const double gapLength = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth || old.radius != radius;
}

// ── Phone field ─────────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_outlined, size: 24.r, color: _kPlaceholderColor),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.primary,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.regular,
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                color: AppColors.titleText,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Enter your number',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: _kPlaceholderColor,
                ),
              ),
            ),
          ),
        ],
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

// ── Cancel button ───────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});
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
