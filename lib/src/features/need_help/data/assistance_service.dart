import 'dart:io';
import 'package:dio/dio.dart';

import 'package:on_the_way/src/core/network/api_client.dart';
import 'package:on_the_way/src/core/network/api_endpoints.dart';
import 'package:on_the_way/src/utils/typedefs.dart';

/// Calls the `/api/assistance/*` endpoints.
class AssistanceService {
  AssistanceService._();
  static final AssistanceService instance = AssistanceService._();

  final ApiClient _api = ApiClient.instance;

  /// POST /api/assistance/request (multipart).
  FutureEither<void> request({
    required int type,
    required double latitude,
    required double longitude,
    String? description,
    String? address,
    String? contactNumber,
    File? image,
  }) async {
    final form = FormData.fromMap({
      'type': type.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (description != null && description.isNotEmpty) 'description': description,
      if (address != null && address.isNotEmpty) 'address': address,
      if (contactNumber != null && contactNumber.isNotEmpty) 'contactNumber': contactNumber,
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
    });
    return _api.post<void>(ApiEndpoints.requestAssistance, data: form);
  }

  /// GET /api/assistance/{id}.
  FutureEither<dynamic> getById(String id) =>
      _api.get<dynamic>(ApiEndpoints.assistanceById(id));
}
