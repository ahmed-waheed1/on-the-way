import '../imports/core_imports.dart';
import 'package:dio/dio.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;
  static late final Client appwriteClient;
  static late final Account appwriteAccount;
  static late final Storage appwriteStorage;

  static String get avatarBucketId =>
      dotenv.get('APPWRITE_AVATAR_BUCKET_ID', fallback: '');

  static String get baseUrl => _getBaseUrl();

  static Future<void> init() async {
    appwriteClient = Client()
      ..setEndpoint(dotenv.get('APPWRITE_ENDPOINT', fallback: 'https://cloud.appwrite.io/v1'))
      ..setProject(dotenv.get('APPWRITE_PROJECT_ID', fallback: 'your-project-id'))
      ..setSelfSigned(status: true);
    appwriteAccount = Account(appwriteClient);
    appwriteStorage = Storage(appwriteClient);
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.info('🌐 [DIO] REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info('✅ [DIO] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.error('❌ [DIO] ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );

  }

  static String _getBaseUrl() {
    return dotenv.get('API_BASE_URL', fallback: 'https://api.example.com');
  }
}
