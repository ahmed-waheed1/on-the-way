import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/app_assets.dart';
import '../../../../shared/widgets/nearby_empty_state.dart';
import '../../../../shared/widgets/nearby_no_match_state.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/entities/accident_report.dart';
import '../widgets/accident_card.dart';
import '../../../../shared/widgets/nearby_filter_row.dart';

const _kFilters = ['ALL', 'Type', 'Time', 'Location'];

final _mockReports = [
  const AccidentReport(
    id: '1',
    name: 'Mobark St',
    distanceKm: 1.5,
    type: AccidentType.crash,
  ),
  const AccidentReport(
    id: '2',
    name: 'El_Shohada',
    distanceKm: 2.7,
    type: AccidentType.medical,
  ),
  const AccidentReport(
    id: '3',
    name: 'Shobra Ms',
    distanceKm: 2.7,
    type: AccidentType.fire,
  ),
  const AccidentReport(
    id: '4',
    name: 'Nasr City',
    distanceKm: 4.1,
    type: AccidentType.roadblock,
  ),
  const AccidentReport(
    id: '5',
    name: 'Maadi Bridge',
    distanceKm: 5.3,
    type: AccidentType.flood,
  ),
];

class NearbyAccidentsScreen extends HookWidget {
  const NearbyAccidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Filter state ──────────────────────────────────────────────────────────
    final selectedTypes = useState<Set<AccidentType>>({});
    final sortAscending = useState(true);
    final maxDistanceKm = useState<double?>(null);

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
      var result = _mockReports.toList();

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
    }, [selectedTypes.value, sortAscending.value, maxDistanceKm.value]);

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
      backgroundColor: AppColors.screenBackground,
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
                child: _mockReports.isEmpty
                    ? const NearbyEmptyState()
                    : filtered.isEmpty
                        ? const NearbyNoMatchState()
                        : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: 15.h),
                        itemBuilder: (context, index) {
                          return AccidentCard(
                            report: filtered[index],
                            onViewDetails: () {},
                            onOfferHelp: () {},
                          );
                        },
                      ),
              ),
            ],
          ),
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
          'Nearby Accidents',
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.bold,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: AppColors.titleText,
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

Future<Set<AccidentType>?> _showTypeSheet(
  BuildContext context,
  Set<AccidentType> current,
) {
  return showModalBottomSheet<Set<AccidentType>>(
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
  required Set<AccidentType> selectedTypes,
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

  final Set<AccidentType> types;
  final bool sortAscending;
  final double? maxDistanceKm;
}

// ── Type filter sheet ─────────────────────────────────────────────────────────

class _TypeFilterSheet extends HookWidget {
  const _TypeFilterSheet({required this.current});

  final Set<AccidentType> current;

  @override
  Widget build(BuildContext context) {
    final selected = useState<Set<AccidentType>>(Set.from(current));

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          SizedBox(height: 12.h),
          _SheetTitle('Filter by Type'),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: AccidentType.values.map((type) {
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
                  final next = Set<AccidentType>.from(selected.value);
                  isOn ? next.remove(type) : next.add(type);
                  selected.value = next;
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          _SheetActions(
            onClear: () => Navigator.pop(context, <AccidentType>{}),
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
          _SheetTitle('Sort by Distance'),
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
          _SheetTitle('Filter by Distance'),
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

  final Set<AccidentType> selectedTypes;
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
    final types = useState<Set<AccidentType>>(Set.from(selectedTypes));
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
                _SheetTitle('All Filters'),
                SizedBox(height: 20.h),

                // Type
                _SectionLabel('Type'),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: AccidentType.values.map((t) {
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
                        final next = Set<AccidentType>.from(types.value);
                        isOn ? next.remove(t) : next.add(t);
                        types.value = next;
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

                // Sort
                _SectionLabel('Sort'),
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
                _SectionLabel('Max Distance'),
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
                _FilterResult(
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
        color: AppColors.titleText,
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
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              clearLabel,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.semiBold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Apply',
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.semiBold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
