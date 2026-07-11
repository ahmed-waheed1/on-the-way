import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/request_history/domain/entities/request_history_item.dart';
import 'package:on_the_way/src/features/request_history/presentation/widgets/request_history_card.dart';
import 'package:on_the_way/src/features/request_history/data/history_service.dart';
import 'package:on_the_way/src/features/report_accident/data/incident_service.dart';
import 'package:on_the_way/src/features/need_help/data/assistance_service.dart';

/// The signed-in user's own requests (GET /api/history), with pull-to-refresh
/// and a tap-through to the full detail (photo, contact, etc.).
class MyRequestsScreen extends HookWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);
    final items =
        useState<List<RequestHistoryItem>>(const <RequestHistoryItem>[]);
    final openingId = useState<String?>(null);

    Future<void> load() async {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await HistoryService.instance.getHistory();
      isLoading.value = false;
      result.fold(
        (f) => errorMessage.value = f.message,
        (data) {
          items.value = extractJsonList(data)
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
              ? RequestHistoryItem.fromIncidentDetail(
                  data.cast<String, dynamic>())
              : RequestHistoryItem.fromAssistanceDetail(
                  data.cast<String, dynamic>());
          context.push(AppRoutes.requestDetails, extra: detail);
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'My Requests'),
      body: SafeArea(
        child: switch ((isLoading.value, errorMessage.value)) {
          (true, _) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          (false, final String msg) => _ErrorState(message: msg, onRetry: load),
          _ => items.value.isEmpty
              ? RefreshIndicator(
                  onRefresh: load,
                  color: AppColors.primary,
                  child: ListView(
                    children: [SizedBox(height: 120.h), const _EmptyState()],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(10.w, 16.h, 10.w, 24.h),
                    itemCount: items.value.length,
                    separatorBuilder: (_, __) => SizedBox(height: 24.h),
                    itemBuilder: (_, index) => RequestHistoryCard(
                      item: items.value[index],
                      onViewDetails: () => openDetails(items.value[index]),
                    ),
                  ),
                ),
        },
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 44.r, color: AppColors.distanceText),
            SizedBox(height: 12.h),
            Text(
              "You haven't made any requests yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.regular,
                fontSize: 14.sp,
                color: AppColors.distanceText,
                height: 20 / 14,
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
            Icon(Icons.error_outline,
                size: 40.r, color: AppColors.distanceText),
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
