import 'package:on_the_way/src/core/network/api_client.dart';
import 'package:on_the_way/src/core/network/api_endpoints.dart';
import 'package:on_the_way/src/utils/typedefs.dart';

/// Calls GET /api/history (the current user's request history).
///
/// The response `data` shape is not documented in the OpenAPI spec, so the raw
/// decoded payload is returned for defensive mapping by the caller.
class HistoryService {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  final ApiClient _api = ApiClient.instance;

  FutureEither<dynamic> getHistory({String? search, String? status, String? sortBy}) {
    return _api.get<dynamic>(ApiEndpoints.history, query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
    });
  }
}
