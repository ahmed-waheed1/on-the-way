import 'dart:io';
import 'package:dio/dio.dart';

import 'package:on_the_way/src/core/network/api_client.dart';
import 'package:on_the_way/src/core/network/api_endpoints.dart';
import 'package:on_the_way/src/utils/typedefs.dart';

/// Calls the `/api/incidents/*` endpoints.
class IncidentService {
  IncidentService._();
  static final IncidentService instance = IncidentService._();

  final ApiClient _api = ApiClient.instance;

  /// POST /api/incidents/report (multipart).
  FutureEither<void> report({
    required int type,
    required double latitude,
    required double longitude,
    String? locationName,
    String? description,
    String? phoneNumber,
    File? image,
  }) async {
    final form = FormData.fromMap({
      'type': type.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (locationName != null && locationName.isNotEmpty) 'locationName': locationName,
      if (description != null && description.isNotEmpty) 'description': description,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
    });
    return _api.post<void>(ApiEndpoints.reportIncident, data: form);
  }

  /// GET /api/incidents/{id}.
  FutureEither<dynamic> getById(String id) => _api.get<dynamic>(ApiEndpoints.incidentById(id));

  /// POST /api/incidents/vote.
  FutureEither<void> vote({required String incidentId, required bool isUpvote}) {
    return _api.post<void>(ApiEndpoints.voteIncident, data: {
      'incidentId': incidentId,
      'isUpvote': isUpvote,
    });
  }
}
