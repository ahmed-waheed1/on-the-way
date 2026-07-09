import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/request_history/domain/entities/request_history_item.dart';
import 'package:on_the_way/src/features/request_history/presentation/widgets/request_history_card.dart';
import 'package:on_the_way/src/features/request_history/data/history_service.dart';
import 'package:on_the_way/src/features/report_accident/data/incident_service.dart';
import 'package:on_the_way/src/features/need_help/data/assistance_service.dart';

enum _DateSort {
  newest('Newest first'),
  oldest('Oldest first');

  const _DateSort(this.label);
  final String label;
}

class RequestHistoryScreen extends HookWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final query = useState('');
    final dateSort = useState(_DateSort.newest);
    final statusFilter = useState<RequestStatus?>(null);

    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);
    final items = useState<List<RequestHistoryItem>>(const <RequestHistoryItem>[]);
    final openingId = useState<String?>(null);

    Future<void> load() async {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await HistoryService.instance.getHistory();
      isLoading.value = false;
      result.fold(
        (f) => errorMessage.value = f.message,
        (data) {
          final list = (data is List) ? data : const <dynamic>[];
          items.value = list
              .whereType<Map<String, dynamic>>()
              .map(RequestHistoryItem.fromHistoryJson)
              .toList();
        },
      );
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    Future<void> openDetails(RequestHistoryItem item) async {
      if (openingId.value != null) return;
      openingId.value = item.id;
      final result = item.type == RequestType.accident
          ? await IncidentService.instance.getById(item.id)
          : await AssistanceService.instance.getById(item.id);
      openingId.value = null;
      if (!context.mounted) return;
      result.fold(
        (f) => showToast(context, message: f.message, status: 'error'),
        (data) {
          if (data is! Map) return;
          final detail = item.type == RequestType.accident
              ? RequestHistoryItem.fromIncidentDetail(data.cast<String, dynamic>())
              : RequestHistoryItem.fromAssistanceDetail(data.cast<String, dynamic>());
          context.push(AppRoutes.requestDetails, extra: detail);
        },
      );
    }

    final filtered = useMemoized(() {
      var result = items.value.toList();

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
    }, [items.value, query.value, dateSort.value, statusFilter.value]);

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
              child: switch ((isLoading.value, errorMessage.value)) {
                (true, _) => Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                (false, final String msg) => _ErrorState(message: msg, onRetry: load),
                _ => filtered.isEmpty
                    ? RefreshIndicator(
                        onRefresh: load,
                        child: ListView(
                          children: [SizedBox(height: 120.h), const NearbyNoMatchState()],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: load,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 16.h),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: 24.h),
                          itemBuilder: (_, index) => RequestHistoryCard(
                            item: filtered[index],
                            onViewDetails: () => openDetails(filtered[index]),
                          ),
                        ),
                      ),
              },
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

// ── Error state ─────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40.r, color: AppColors.distanceText),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.regular,
                fontSize: 14.sp,
                color: AppColors.distanceText,
                height: 20 / 14,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.bold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.primary,
                ),
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
