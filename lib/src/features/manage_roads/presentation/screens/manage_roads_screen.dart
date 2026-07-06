import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/manage_roads/domain/entities/followed_road.dart';

const _kDeleteColor = Color(0xFFFF305D);

const _mockRoads = [
  FollowedRoad(id: '1', name: 'sheikh Zayed Road'),
  FollowedRoad(id: '2', name: 'Road ElFarag'),
];

class ManageRoadsScreen extends HookWidget {
  const ManageRoadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roads = useState<List<FollowedRoad>>(_mockRoads);

    void deleteRoad(FollowedRoad road) {
      roads.value = roads.value.where((r) => r.id != road.id).toList();
      showToast(context, message: '${road.name} removed', status: 'info');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Manage Roads'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 18.h),

            // ── Illustration ────────────────────────────────────────────────
            Center(
              child: Image.asset(
                AppAssets.manageRoadsIllustration,
                width: 100.r,
                height: 100.r,
              ),
            ),
            SizedBox(height: 32.h),

            // ── Section title ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'My Followed Roads',
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
            SizedBox(height: 24.h),

            // ── List ────────────────────────────────────────────────────────
            Expanded(
              child: roads.value.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 23.w),
                      itemCount: roads.value.length,
                      separatorBuilder: (_, __) => SizedBox(height: 24.h),
                      itemBuilder: (_, index) => _RoadRow(
                        road: roads.value[index],
                        onDelete: () => deleteRoad(roads.value[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Road row ────────────────────────────────────────────────────────────────────

class _RoadRow extends StatelessWidget {
  const _RoadRow({required this.road, required this.onDelete});

  final FollowedRoad road;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5.r),
                child: SvgPicture.asset(
                  AppAssets.roadIcon,
                  width: 14.r,
                  height: 14.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  road.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.regular,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.black,
                    height: 20 / 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onDelete,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Delete',
            style: TextStyle(
              fontFamily: AppTypography.robotoFlex,
              fontVariations: AppTypography.regular,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: _kDeleteColor,
              height: 20 / 16,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Text(
          'You are not following any roads yet.',
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
      ),
    );
  }
}
