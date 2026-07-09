import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../routing/app_routes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../providers/help_request_provider.dart';

const _kStepTextColor = Color(0xFF6B7280);
const _kPlaceholderColor = Color(0xFFB1B6B6);
const _kLocationTextColor = Color(0xFF909A90);
const _kLocationFieldBg = Color(0xFFD9D9D9);
const _kProgressTrack = Color(0xFFD9D9D9);
const _kAddPhotoBg = Color(0xCCB1B6B6);

class DescribeIssueScreen extends HookConsumerWidget {
  const DescribeIssueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final hasText = useState(false);
    final pickedImages = useState<List<XFile>>([]);
    final locationText = useState<String>('');
    final latitude = useState<double?>(null);
    final longitude = useState<double?>(null);
    final isFetchingLocation = useState(false);

    useEffect(() {
      void listener() => hasText.value = controller.text.trim().isNotEmpty;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    Future<void> fetchLocation() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      isFetchingLocation.value = true;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.street, p.locality, p.administrativeArea]
              .where((e) => e != null && e!.isNotEmpty)
              .map((e) => e!)
              .toList();
          locationText.value =
              parts.isNotEmpty ? parts.join(', ') : '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        } else {
          locationText.value =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch location')),
          );
        }
      } finally {
        isFetchingLocation.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _Header(),
            SizedBox(height: 8.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 21.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    Text(
                      'Describe Your Issue',
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.bold,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: AppColors.titleText,
                      ),
                    ),
                    SizedBox(height: 44.h),
                    Text(
                      'Short Description',
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.regular,
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _DescriptionField(controller: controller),
                    SizedBox(height: 16.h),
                    _UploadPhotoBox(
                      images: pickedImages.value,
                      onPickImage: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          pickedImages.value = [...pickedImages.value, file];
                        }
                      },
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      'Confirm Your Location',
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.bold,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Location',
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.regular,
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: AppColors.titleText,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _LocationField(
                      location: locationText.value,
                      isLoading: isFetchingLocation.value,
                      onTap: fetchLocation,
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(21.w, 0, 21.w, 28.h),
              child: Column(
                children: [
                  _NextButton(
                    enabled: hasText.value,
                    onTap: () {
                      final notifier =
                          ref.read(helpRequestProvider.notifier);
                      notifier.setDescription(controller.text.trim());
                      notifier.setLocation(
                        locationText.value,
                        latitude: latitude.value,
                        longitude: longitude.value,
                      );
                      notifier.setImageCount(pickedImages.value.length);
                      if (pickedImages.value.isNotEmpty) {
                        notifier.setImage(File(pickedImages.value.first.path));
                      }
                      context.push(AppRoutes.reviewRequest);
                    },
                  ),
                  SizedBox(height: 12.h),
                  _BackButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header: back arrow + progress ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.arrow_back,
              size: 22.r,
              color: AppColors.titleText,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Step 2 of 4',
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: _kStepTextColor,
            ),
          ),
          SizedBox(height: 6.h),
          const _ProgressBar(progress: 0.5),
          SizedBox(height: 14.h),
          const Center(child: _StepDots(total: 4, current: 1)),
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

// ── Description textarea ───────────────────────────────────────────────────────

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
        style: TextStyle(
          fontFamily: AppTypography.robotoFlex,
          fontVariations: AppTypography.regular,
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: AppColors.titleText,
          height: 20 / 16,
        ),
        decoration: InputDecoration(
          hintText:
              'Ex: Flat tire on the main road and\nthere is and issue with engine ......',
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

// ── Upload photo box ───────────────────────────────────────────────────────────

class _UploadPhotoBox extends StatelessWidget {
  const _UploadPhotoBox({
    required this.images,
    required this.onPickImage,
  });

  final List<XFile> images;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
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
            Icon(
              Icons.add_a_photo_outlined,
              size: 32.r,
              color: AppColors.titleText,
            ),
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
              'Tap here to add a photo (Optional)',
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
            GestureDetector(
              onTap: onPickImage,
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed border painter ──────────────────────────────────────────────────────

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
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius;
}

// ── Location field ────────────────────────────────────────────────────────────

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.location,
    required this.isLoading,
    required this.onTap,
  });

  final String location;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: _kLocationFieldBg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                location.isEmpty ? 'Tap to get your location' : location,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: location.isEmpty
                      ? _kPlaceholderColor
                      : _kLocationTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            isLoading
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    Icons.location_on_outlined,
                    size: 22.r,
                    color: location.isEmpty
                        ? _kPlaceholderColor
                        : AppColors.primary,
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
        width: double.infinity,
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

// ── Back button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
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
          'Back',
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
