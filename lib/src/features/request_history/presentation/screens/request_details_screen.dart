import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/request_history/domain/entities/request_history_item.dart';

/// The API returns image paths relative to the host (e.g. `/uploads/...`);
/// prepend the API base URL unless it's already absolute.
String _absolutePhotoUrl(String path) {
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl;
  return '$base${path.startsWith('/') ? '' : '/'}$path';
}

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key, required this.item});

  final RequestHistoryItem item;

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

  String get _formattedDateTime {
    final d = item.date;
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}, $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Request Details'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),

                      // ── Header card ───────────────────────────────────────
                      _HeaderCard(item: item),
                      SizedBox(height: 24.h),

                      // ── Request Details section ───────────────────────────
                      const _SectionTitle('Request Details', size: 16),
                      SizedBox(height: 16.h),
                      _DetailRow(
                          label: 'Incident Type', value: item.incidentType),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'Date', value: _formattedDateTime),
                      SizedBox(height: 16.h),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: AppTypography.regular,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.titleText,
                          height: 20 / 16,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: AppTypography.regular,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7280),
                          height: 20 / 14,
                        ),
                      ),

                      // ── Attached photo ────────────────────────────────────
                      if (item.imageUrl.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _AttachedPhoto(url: _absolutePhotoUrl(item.imageUrl)),
                      ],
                      SizedBox(height: 24.h),

                      const Divider(
                          height: 1, thickness: 2, color: Color(0xFFE5E7EB)),
                      SizedBox(height: 24.h),

                      // ── Location section ──────────────────────────────────
                      const _SectionTitle('Location', size: 20),
                      SizedBox(height: 16.h),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        title: 'Address',
                        subtitle: item.location,
                      ),
                      SizedBox(height: 14.h),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Contact Number',
                        subtitle: item.contactNumber,
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom buttons ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 8.h, 27.w, 24.h),
              child: Column(
                children: [
                  AppButton(
                    label: 'Back to History',
                    onPressed: () => context.pop(),
                    variant: ButtonVariant.primary,
                    height: ButtonSize.large,
                    isFullWidth: true,
                  ),
                  SizedBox(height: 16.h),
                  AppButton(
                    label: 'Request Again',
                    onPressed: () => context.go(AppRoutes.needHelp),
                    variant: ButtonVariant.outline,
                    height: ButtonSize.large,
                    isFullWidth: true,
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

// ── Header card ─────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.item});

  final RequestHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            padding: EdgeInsets.all(9.r),
            decoration: BoxDecoration(
              color: AppColors.requestHistoryCardBg,
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Icon(item.type.icon, size: 32.r, color: AppColors.primary),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.displayTitle,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.status.icon,
                        size: 16.r, color: item.status.accentColor),
                    SizedBox(width: 8.w),
                    Text(
                      item.status.label,
                      style: TextStyle(
                        fontFamily: AppTypography.robotoFlex,
                        fontVariations: AppTypography.bold,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        color: item.status.accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Attached photo ──────────────────────────────────────────────────────────────

class _AttachedPhoto extends StatelessWidget {
  const _AttachedPhoto({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 180.h,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 180.h,
          color: const Color(0xFFF3F4F6),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 180.h,
          color: const Color(0xFFF3F4F6),
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined,
              size: 32.r, color: AppColors.distanceText),
        ),
      ),
    );
  }
}

// ── Section title ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.bold,
        fontWeight: FontWeight.w700,
        fontSize: size.sp,
        color: AppColors.titleText,
        height: 20 / size,
      ),
    );
  }
}

// ── Key/value row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.regular,
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            color: AppColors.titleText,
            height: 20 / 16,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Icon + title/subtitle tile ──────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35.r,
          height: 35.r,
          padding: EdgeInsets.all(5.r),
          decoration: BoxDecoration(
            color: AppColors.requestHistoryCardBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 24.r, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: AppColors.distanceText,
                  height: 20 / 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
