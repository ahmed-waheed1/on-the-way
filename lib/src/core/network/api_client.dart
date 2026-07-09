import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:on_the_way/src/config/app_config.dart';
import 'package:on_the_way/src/services/internet_connection_service.dart';
import 'package:on_the_way/src/utils/failure.dart';
import 'package:on_the_way/src/utils/logger.dart';
import 'package:on_the_way/src/utils/typedefs.dart';

/// Thin wrapper over [Dio] that understands the On The Way API response
/// envelope `{ "data": T, "isSuccess": bool, "error": string }` and maps
/// results into [FutureEither], surfacing the API's own error messages.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Dio get _dio => AppConfig.dio;

  FutureEither<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? parse,
  }) =>
      _send(method: 'GET', path: path, query: query, parse: parse);

  FutureEither<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    T Function(dynamic data)? parse,
  }) =>
      _send(method: 'POST', path: path, data: data, query: query, parse: parse);

  FutureEither<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    T Function(dynamic data)? parse,
  }) =>
      _send(method: 'PUT', path: path, data: data, query: query, parse: parse);

  Future<Either<Failure, T>> _send<T>({
    required String method,
    required String path,
    Object? data,
    Map<String, dynamic>? query,
    T Function(dynamic data)? parse,
  }) async {
    final hasNetwork = await InternetConnectionService().hasConnection();
    if (!hasNetwork) {
      return left(const NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      return _mapBody<T>(response.data, parse);
    } on DioException catch (e) {
      return left(_mapDioError(e));
    } catch (e, s) {
      AppLogger.error('Unexpected API error', [e, s]);
      return left(ServerFailure('Something went wrong. Please try again.', error: e));
    }
  }

  Either<Failure, T> _mapBody<T>(dynamic body, T Function(dynamic)? parse) {
    // Enveloped response: { data, isSuccess, error }
    if (body is Map && body.containsKey('isSuccess')) {
      if (body['isSuccess'] == true) {
        final data = body['data'];
        return right(parse != null ? parse(data) : data as T);
      }
      return left(ServerFailure(_extractError(body) ?? 'Request failed.'));
    }
    // Non-enveloped success (some endpoints may return raw payloads).
    return right(parse != null ? parse(body) : body as T);
  }

  /// The API returns `error` as either a string or a `{ "message": "..." }`
  /// object depending on the endpoint — normalize both.
  String? _extractError(Map<dynamic, dynamic> body) {
    final err = body['error'];
    if (err is String && err.isNotEmpty) return err;
    if (err is Map && err['message'] is String && (err['message'] as String).isNotEmpty) {
      return err['message'] as String;
    }
    return null;
  }

  Failure _mapDioError(DioException e) {
    final body = e.response?.data;
    // The API returns the envelope even on 4xx — prefer its error message.
    if (body is Map) {
      final err = _extractError(body);
      if (err != null) return ServerFailure(err, error: e);
    }
    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The server took too long to respond. Please try again.',
      DioExceptionType.connectionError =>
        'Could not reach the server. Please check your connection.',
      _ => e.response?.statusCode == 401
          ? 'Your session has expired. Please sign in again.'
          : 'Something went wrong. Please try again.',
    };
    AppLogger.error('API error [${e.response?.statusCode}] ${e.requestOptions.path}', [e]);
    return ServerFailure(message, error: e);
  }
}
