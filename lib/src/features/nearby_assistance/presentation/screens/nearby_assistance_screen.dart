import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:on_the_way/src/services/location_service.dart';
import '../../../../shared/app_assets.dart';
import '../../../../shared/widgets/nearby_empty_state.dart';
import '../../../../shared/widgets/nearby_no_match_state.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/entities/assistance_request.dart';
import '../../data/feed_service.dart';
import '../widgets/assistance_card.dart';
import '../widgets/nearby_filter_row.dart';
import 'package:on_the_way/src/features/account/presentation/widgets/edit_field_sheet.dart';
import 'package:on_the_way/src/features/need_help/data/assistance_service.dart';
import 'package:on_the_way/src/features/request_history/domain/entities/request_history_item.dart';
import 'package:on_the_way/src/routing/app_routes.dart';
import 'package:on_the_way/src/shared/helpers/show_toast.dart';

const _kBg = Color(0xFFF5F6F8);
const _kPrimaryBlue = Color(0xFF025D8C);
const _kTitleText = Color(0xFF222222);

const _kFilters = ['ALL', 'Type', 'Time', 'Location'];

class NearbyAssistanceScreen extends HookWidget {
  const NearbyAssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Filter state ──────────────────────────────────────────────────────────
    final selectedTypes = useState<Set<AssistanceType>>({});
    final sortAscending = useState(true);   // true = nearest first
    final maxDistanceKm = useState<double?>(null); // null = any

    // ── Live feed state ───────────────────────────────────────────────────────
    final requests = useState<List<AssistanceRequest>>(const <AssistanceRequest>[]);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);
    final offeringId = useState<String?>(null);
    final openingId = useState<String?>(null);

    Future<void> openDetails(AssistanceRequest req) async {
      if (openingId.value != null) return;
      openingId.value = req.id;
      final res = await AssistanceService.instance.getById(req.id);
      openingId.value = null;
      if (!context.mounted) return;
      res.fold(
        (f) => showToast(context, message: f.message, status: 'error'),
        (data) {
          if (data is! Map) return;
          final detail = RequestHistoryItem.fromAssistanceDetail(
            data.cast<String, dynamic>(),
          );
          context.push(AppRoutes.requestDetails, extra: detail);
        },
      );
    }

    Future<void> offerHelp(AssistanceRequest req) async {
      if (offeringId.value != null) return;
      final message = await showEditFieldSheet(
        context,
        title: 'Offer Help',
        currentValue: '',
        hint: 'Add a short message for the requester…',
        maxLines: 3,
      );
      if (message == null) return; // cancelled
      offeringId.value = req.id;
      final res = await FeedService.instance
          .offerHelp(assistanceId: req.id, message: message);
      offeringId.value = null;
      if (!context.mounted) return;
      res.fold(
        (f) => showToast(context, message: f.message, status: 'error'),
        (_) => showToast(context,
            message: 'Help offered — the requester has been notified.',
            status: 'success'),
      );
    }

    Future<void> load() async {
      isLoading.value = true;
      errorMessage.value = null;
      final locResult = await LocationService.instance.resolveLocation();
      await locResult.fold(
        (f) async {
          isLoading.value = false;
          errorMessage.value = f.message;
        },
        (loc) async {
          final res = await FeedService.instance.nearbyAssistance(
            lat: loc.position.latitude,
            lon: loc.position.longitude,
          );
          isLoading.value = false;
          res.fold(
            (f) => errorMessage.value = f.message,
            (data) {
              final list = (data is List) ? data : const <dynamic>[];
              requests.value = list
                  .whereType<Map<String, dynamic>>()
                  .map(AssistanceRequest.fromFeedJson)
                  .toList();
            },
          );
        },
      );
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    // ── Derived: which chips show as active ───────────────────────────────────
    final activeChips = useMemoized(() {
      final active = <String>{};
      if (selectedTypes.value.isEmpty &&
          sortAscending.value &&
          maxDistanceKm.value == null) {
        active.add('ALL');
      }
      if (selectedTypes.value.isNotEmpty) active.add('Type');
      if (!sortAscending.value) active.add('Time');
      if (maxDistanceKm.value != null) active.add('Location');
      return active;
    }, [selectedTypes.value, sortAscending.value, maxDistanceKm.value]);

    // ── Derived: filtered + sorted list ──────────────────────────────────────
    final filtered = useMemoized(() {
      var result = requests.value.toList();

      if (selectedTypes.value.isNotEmpty) {
        result =
            result.where((r) => selectedTypes.value.contains(r.type)).toList();
      }
      if (maxDistanceKm.value != null) {
        result =
            result.where((r) => r.distanceKm <= maxDistanceKm.value!).toList();
      }
      result.sort((a, b) => sortAscending.value
          ? a.distanceKm.compareTo(b.distanceKm)
          : b.distanceKm.compareTo(a.distanceKm));

      return result;
    }, [requests.value, selectedTypes.value, sortAscending.value, maxDistanceKm.value]);

    // ── Bottom-sheet helpers ──────────────────────────────────────────────────
    void openTypeSheet() async {
      final result = await _showTypeSheet(context, selectedTypes.value);
      if (result != null) selectedTypes.value = result;
    }

    void openTimeSheet() async {
      final result = await _showTimeSheet(context, sortAscending.value);
      if (result != null) sortAscending.value = result;
    }

    void openLocationSheet() async {
      final result = await _showLocationSheet(context, maxDistanceKm.value);
      if (result != null) maxDistanceKm.value = result.value;
    }

    void openAllFilters() async {
      final result = await _showAllFiltersSheet(
        context,
        selectedTypes: selectedTypes.value,
        sortAscending: sortAscending.value,
        maxDistanceKm: maxDistanceKm.value,
      );
      if (result != null) {
        selectedTypes.value = result.types;
        sortAscending.value = result.sortAscending;
        maxDistanceKm.value = result.maxDistanceKm;
      }
    }

    void onChipTap(String chip) {
      switch (chip) {
        case 'ALL':
          selectedTypes.value = {};
          sortAscending.value = true;
          maxDistanceKm.value = null;
        case 'Type':
          openTypeSheet();
        case 'Time':
          openTimeSheet();
        case 'Location':
          openLocationSheet();
      }
    }

    // ── UI ────────────────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 18.h),
          child: Column(
            children: [
              _TopBar(onFilterTap: openAllFilters),
              SizedBox(height: 36.h),
              Align(
                alignment: Alignment.centerLeft,
                child: NearbyFilterRow(
                  filters: _kFilters,
                  activeFilters: activeChips,
                  onChipTap: onChipTap,
                ),
              ),
              SizedBox(height: 36.h),
              Expanded(
                child: isLoading.value
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : errorMessage.value != null
                        ? _FeedError(message: errorMessage.value!, onRetry: load)
                        : requests.value.isEmpty
                            ? const NearbyEmptyState()
                            : filtered.isEmpty
                                ? const NearbyNoMatchState()
                                : RefreshIndicator(
                                    onRefresh: load,
                                    color: AppColors.primary,
                                    child: ListView.separated(
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) => SizedBox(height: 15.h),
                                      itemBuilder: (context, index) {
                                        final req = filtered[index];
                                        return AssistanceCard(
                                          request: req,
                                          onViewDetails: () => openDetails(req),
                                          onOfferHelp: () => offerHelp(req),
                                          isOffering: offeringId.value == req.id,
                                        );
                                      },
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

// ── Feed error state ─────────────────────────────────────────────────────────

class _FeedError extends StatelessWidget {
  const _FeedError({required this.message, required this.onRetry});

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

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onFilterTap});

  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: SvgPicture.asset(
            AppAssets.arrowBack,
            width: 16.r,
            height: 16.r,
          ),
        ),
        Text(
          'Nearby Assistance',
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.bold,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: _kTitleText,
            height: 20 / 16,
          ),
        ),
        GestureDetector(
          onTap: onFilterTap,
          child: Image.asset(
            AppAssets.settingNearbyAssistance,
            width: 24.r,
            height: 24.r,
          ),
        ),
      ],
    );
  }
}


// ── Bottom sheets ─────────────────────────────────────────────────────────────

Future<Set<AssistanceType>?> _showTypeSheet(
  BuildContext context,
  Set<AssistanceType> current,
) {
  return showModalBottomSheet<Set<AssistanceType>>(
    context: context,
    backgroundColor: AppColors.screenBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _TypeFilterSheet(current: current),
  );
}

Future<bool?> _showTimeSheet(BuildContext context, bool current) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.screenBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _TimeFilterSheet(sortAscending: current),
  );
}

Future<_DistanceResult?> _showLocationSheet(BuildContext context, double? current) {
  return showModalBottomSheet<_DistanceResult>(
    context: context,
    backgroundColor: AppColors.screenBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _LocationFilterSheet(current: current),
  );
}

Future<_FilterResult?> _showAllFiltersSheet(
  BuildContext context, {
  required Set<AssistanceType> selectedTypes,
  required bool sortAscending,
  required double? maxDistanceKm,
}) {
  return showModalBottomSheet<_FilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.screenBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _AllFiltersSheet(
      selectedTypes: selectedTypes,
      sortAscending: sortAscending,
      maxDistanceKm: maxDistanceKm,
    ),
  );
}

// ── _DistanceResult ───────────────────────────────────────────────────────────

class _DistanceResult {
  const _DistanceResult(this.value);
  final double? value;
}

// ── _FilterResult ─────────────────────────────────────────────────────────────

class _FilterResult {
  const _FilterResult({
    required this.types,
    required this.sortAscending,
    required this.maxDistanceKm,
  });

  final Set<AssistanceType> types;
  final bool sortAscending;
  final double? maxDistanceKm;
}

// ── Type filter sheet ─────────────────────────────────────────────────────────

class _TypeFilterSheet extends HookWidget {
  const _TypeFilterSheet({required this.current});

  final Set<AssistanceType> current;

  @override
  Widget build(BuildContext context) {
    final selected = useState<Set<AssistanceType>>(Set.from(current));

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          SizedBox(height: 12.h),
          const _SheetTitle('Filter by Type'),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: AssistanceType.values.map((type) {
              final isOn = selected.value.contains(type);
              return FilterChip(
                label: Text(
                  type.label,
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: isOn ? AppTypography.semiBold : AppTypography.regular,
                    fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12.sp,
                    color: isOn ? Colors.white : AppColors.titleText,
                  ),
                ),
                selected: isOn,
                showCheckmark: false,
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary,
                side: BorderSide(
                  color: isOn ? AppColors.primary : const Color(0xFFE0E0E0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                onSelected: (_) {
                  final next = Set<AssistanceType>.from(selected.value);
                  isOn ? next.remove(type) : next.add(type);
                  selected.value = next;
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          _SheetActions(
            onClear: () => Navigator.pop(context, <AssistanceType>{}),
            onApply: () => Navigator.pop(context, selected.value),
          ),
        ],
      ),
    );
  }
}

// ── Time sort sheet ───────────────────────────────────────────────────────────

class _TimeFilterSheet extends HookWidget {
  const _TimeFilterSheet({required this.sortAscending});

  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    final ascending = useState(sortAscending);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          SizedBox(height: 12.h),
          const _SheetTitle('Sort by Distance'),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (final option in [
                (label: 'Nearest first', value: true),
                (label: 'Furthest first', value: false),
              ])
                _buildChoiceChip(
                  label: option.label,
                  isOn: ascending.value == option.value,
                  onTap: () => ascending.value = option.value,
                ),
            ],
          ),
          SizedBox(height: 24.h),
          _SheetActions(
            onClear: () => Navigator.pop(context, true),
            onApply: () => Navigator.pop(context, ascending.value),
          ),
        ],
      ),
    );
  }
}

// ── Location filter sheet ─────────────────────────────────────────────────────

class _LocationFilterSheet extends HookWidget {
  const _LocationFilterSheet({required this.current});

  final double? current;

  static const _options = <String, double?>{
    'Any': null,
    '< 1 km': 1.0,
    '< 3 km': 3.0,
    '< 5 km': 5.0,
  };

  @override
  Widget build(BuildContext context) {
    final selected = useState<double?>(current);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          SizedBox(height: 12.h),
          const _SheetTitle('Filter by Distance'),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _options.entries.map((e) {
              final isOn = selected.value == e.value;
              return _buildChoiceChip(
                label: e.key,
                isOn: isOn,
                onTap: () => selected.value = e.value,
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          _SheetActions(
            onClear: () => Navigator.pop(context, const _DistanceResult(null)),
            onApply: () => Navigator.pop(context, _DistanceResult(selected.value)),
          ),
        ],
      ),
    );
  }
}

// ── All-filters sheet (triggered by the top-right icon) ───────────────────────

class _AllFiltersSheet extends HookWidget {
  const _AllFiltersSheet({
    required this.selectedTypes,
    required this.sortAscending,
    required this.maxDistanceKm,
  });

  final Set<AssistanceType> selectedTypes;
  final bool sortAscending;
  final double? maxDistanceKm;

  static const _distanceOptions = <String, double?>{
    'Any': null,
    '< 1 km': 1.0,
    '< 3 km': 3.0,
    '< 5 km': 5.0,
  };

  @override
  Widget build(BuildContext context) {
    final types = useState<Set<AssistanceType>>(Set.from(selectedTypes));
    final ascending = useState(sortAscending);
    final distance = useState<double?>(maxDistanceKm);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller,
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              children: [
                _SheetHandle(),
                SizedBox(height: 12.h),
                const _SheetTitle('All Filters'),
                SizedBox(height: 20.h),

                // Type
                const _SectionLabel('Type'),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: AssistanceType.values.map((t) {
                    final isOn = types.value.contains(t);
                    return FilterChip(
                      label: Text(
                        t.label,
                        style: TextStyle(
                          fontFamily: AppTypography.robotoFlex,
                          fontVariations: isOn ? AppTypography.semiBold : AppTypography.regular,
                          fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 12.sp,
                          color: isOn ? Colors.white : AppColors.titleText,
                        ),
                      ),
                      selected: isOn,
                      showCheckmark: false,
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      side: BorderSide(
                        color: isOn ? AppColors.primary : const Color(0xFFE0E0E0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      onSelected: (_) {
                        final next = Set<AssistanceType>.from(types.value);
                        isOn ? next.remove(t) : next.add(t);
                        types.value = next;
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

                // Sort
                const _SectionLabel('Sort'),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    for (final option in [
                      (label: 'Nearest first', value: true),
                      (label: 'Furthest first', value: false),
                    ])
                      _buildChoiceChip(
                        label: option.label,
                        isOn: ascending.value == option.value,
                        onTap: () => ascending.value = option.value,
                      ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Distance
                const _SectionLabel('Max Distance'),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: _distanceOptions.entries.map((e) {
                    final isOn = distance.value == e.value;
                    return _buildChoiceChip(
                      label: e.key,
                      isOn: isOn,
                      onTap: () => distance.value = e.value,
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            child: _SheetActions(
              clearLabel: 'Reset All',
              onClear: () => Navigator.pop(
                context,
                const _FilterResult(
                  types: {},
                  sortAscending: true,
                  maxDistanceKm: null,
                ),
              ),
              onApply: () => Navigator.pop(
                context,
                _FilterResult(
                  types: types.value,
                  sortAscending: ascending.value,
                  maxDistanceKm: distance.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice chip helper ────────────────────────────────────────────────────────

Widget _buildChoiceChip({
  required String label,
  required bool isOn,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isOn ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isOn ? AppColors.primary : const Color(0xFFE0E0E0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.robotoFlex,
          fontVariations: isOn ? AppTypography.semiBold : AppTypography.regular,
          fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
          fontSize: 12.sp,
          color: isOn ? Colors.white : AppColors.titleText,
        ),
      ),
    ),
  );
}

// ── Shared sheet components ───────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.bold,
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
        color: _kTitleText,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.robotoFlex,
        fontVariations: AppTypography.semiBold,
        fontWeight: FontWeight.w600,
        fontSize: 13.sp,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.onClear,
    required this.onApply,
    this.clearLabel = 'Clear',
  });

  final VoidCallback onClear;
  final VoidCallback onApply;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kPrimaryBlue),
              foregroundColor: _kPrimaryBlue,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(clearLabel,
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.semiBold,
                  fontSize: 14.sp,
                )),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Apply',
                style: TextStyle(
                  fontFamily: AppTypography.robotoFlex,
                  fontVariations: AppTypography.semiBold,
                  fontSize: 14.sp,
                )),
          ),
        ),
      ],
    );
  }
}
