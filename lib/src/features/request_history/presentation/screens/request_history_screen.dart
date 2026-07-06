import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/request_history/domain/entities/request_history_item.dart';
import 'package:on_the_way/src/features/request_history/presentation/widgets/request_history_card.dart';

enum _DateSort {
  newest('Newest first'),
  oldest('Oldest first');

  const _DateSort(this.label);
  final String label;
}

final _mockHistory = [
  RequestHistoryItem(
    id: '1',
    type: RequestType.assistance,
    title: 'Flat Tire Assistance',
    incidentType: 'Flat Tire',
    date: DateTime(2023, 10, 24, 10, 45),
    location: 'Sheikh Zayed Road',
    contactNumber: '+201096504533',
    description:
        'My car’s bodywork is damaged on the side and I’m looking for someone who can fix it.',
    status: RequestStatus.completed,
  ),
  RequestHistoryItem(
    id: '2',
    type: RequestType.accident,
    title: 'Accident Report',
    incidentType: 'Crash',
    date: DateTime(2024, 12, 2, 14, 30),
    location: 'Road ElFarag',
    contactNumber: '+201096504533',
    description: 'Two vehicles collided at the intersection, blocking the right lane.',
    status: RequestStatus.cancelled,
  ),
  RequestHistoryItem(
    id: '3',
    type: RequestType.assistance,
    title: 'Fuel Delivery',
    incidentType: 'Out of Fuel',
    date: DateTime(2024, 11, 18, 9, 5),
    location: 'Nasr City',
    contactNumber: '+201112223344',
    description: 'Ran out of fuel on the highway, need a delivery as soon as possible.',
    status: RequestStatus.inProgress,
  ),
  RequestHistoryItem(
    id: '4',
    type: RequestType.assistance,
    title: 'Battery Jump Start',
    incidentType: 'Dead Battery',
    date: DateTime(2024, 10, 5, 18, 20),
    location: 'Maadi Bridge',
    contactNumber: '+201223334455',
    description: 'Car battery is dead and won’t start, need a jump start.',
    status: RequestStatus.pending,
  ),
];

class RequestHistoryScreen extends HookWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final query = useState('');
    final dateSort = useState(_DateSort.newest);
    final statusFilter = useState<RequestStatus?>(null);

    final filtered = useMemoized(() {
      var result = _mockHistory.toList();

      final q = query.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        result = result
            .where((r) =>
                r.type.label.toLowerCase().contains(q) ||
                r.location.toLowerCase().contains(q) ||
                r.status.label.toLowerCase().contains(q))
            .toList();
      }

      if (statusFilter.value != null) {
        result = result.where((r) => r.status == statusFilter.value).toList();
      }

      result.sort((a, b) => dateSort.value == _DateSort.newest
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date));

      return result;
    }, [query.value, dateSort.value, statusFilter.value]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'My Request History'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(21.w, 8.h, 21.w, 0),
              child: Column(
                children: [
                  // ── Search ────────────────────────────────────────────────
                  _SearchField(
                    controller: searchController,
                    onChanged: (v) => query.value = v,
                  ),
                  SizedBox(height: 12.h),

                  // ── Sort / Filter dropdowns ───────────────────────────────
                  Row(
                    children: [
                      _DropdownPill<_DateSort>(
                        label: 'Sort by Date',
                        value: dateSort.value,
                        items: _DateSort.values
                            .map((s) => (value: s, label: s.label))
                            .toList(),
                        onSelected: (v) => dateSort.value = v,
                      ),
                      SizedBox(width: 12.w),
                      _DropdownPill<RequestStatus?>(
                        label: 'Filter by Status',
                        value: statusFilter.value,
                        items: [
                          (value: null, label: 'All'),
                          ...RequestStatus.values
                              .map((s) => (value: s, label: s.label)),
                        ],
                        onSelected: (v) => statusFilter.value = v,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const NearbyNoMatchState()
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 16.h),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 24.h),
                      itemBuilder: (_, index) => RequestHistoryCard(
                        item: filtered[index],
                        onViewDetails: () => context.push(
                          AppRoutes.requestDetails,
                          extra: filtered[index],
                        ),
                      ),
                    ),
            ),

            // ── Back to home ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 8.h, 27.w, 24.h),
              child: AppButton(
                label: 'Back To Home',
                onPressed: () => context.go(AppRoutes.home),
                variant: ButtonVariant.primary,
                height: ButtonSize.large,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search field ───────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

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
          Icon(Icons.search, size: 24.r, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.primary,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.regular,
                fontSize: 12.sp,
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search request',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.regular,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown pill ──────────────────────────────────────────────────────────────

class _DropdownPill<T> extends StatelessWidget {
  const _DropdownPill({
    required this.label,
    required this.value,
    required this.items,
    required this.onSelected,
  });

  final String label;
  final T value;
  final List<({T value, String label})> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      initialValue: value,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      position: PopupMenuPosition.under,
      itemBuilder: (_) => items
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              child: Text(
                item.label,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations:
                      item.value == value ? AppTypography.bold : AppTypography.regular,
                  fontSize: 13.sp,
                  color: item.value == value
                      ? AppColors.primary
                      : AppColors.titleText,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 25.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.dropdownPillBg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.regular,
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: AppColors.titleText,
                height: 20 / 12,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 22.r, color: AppColors.titleText),
          ],
        ),
      ),
    );
  }
}
