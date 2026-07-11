import 'package:on_the_way/src/core/network/api_client.dart';
import 'package:on_the_way/src/core/network/api_endpoints.dart';
import 'package:on_the_way/src/utils/typedefs.dart';

/// Calls the `/api/feed/*` endpoints (nearby lists + help-offer lifecycle).
///
/// The GET endpoints return `data` payloads whose exact shape is not documented
/// in the OpenAPI spec, so callers receive the raw decoded `data` and should map
/// it defensively.
class FeedService {
  FeedService._();
  static final FeedService instance = FeedService._();

  final ApiClient _api = ApiClient.instance;

  /// GET /api/feed/incidents?lat&lon[&type&time&loc]
  FutureEither<dynamic> nearbyIncidents({
    required double lat,
    required double lon,
    String? type,
    String? time,
    String? loc,
  }) {
    return _api.get<dynamic>(ApiEndpoints.feedIncidents, query: {
      'lat': lat,
      'lon': lon,
      if (type != null) 'type': type,
      if (time != null) 'time': time,
      if (loc != null) 'loc': loc,
    });
  }

  /// GET /api/feed/assistance?lat&lon[&type&time&loc]
  FutureEither<dynamic> nearbyAssistance({
    required double lat,
    required double lon,
    String? type,
    String? time,
    String? loc,
  }) {
    return _api.get<dynamic>(ApiEndpoints.feedAssistance, query: {
      'lat': lat,
      'lon': lon,
      if (type != null) 'type': type,
      if (time != null) 'time': time,
      if (loc != null) 'loc': loc,
    });
  }

  /// POST /api/feed/assistance/{id}/offer-help
  FutureEither<void> offerHelp(
      {required String assistanceId, required String message}) {
    return _api.post<void>(ApiEndpoints.offerHelp(assistanceId),
        data: {'message': message});
  }

  /// POST /api/feed/offers/{offerId}/respond
  FutureEither<void> respondToOffer(
      {required String offerId, required bool isAccepted}) {
    return _api.post<void>(ApiEndpoints.respondToOffer(offerId),
        data: {'isAccepted': isAccepted});
  }

  /// POST /api/feed/assistance/{id}/complete
  FutureEither<void> completeAssistance({required String assistanceId}) {
    return _api.post<void>(ApiEndpoints.completeAssistance(assistanceId));
  }
}
