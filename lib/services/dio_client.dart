import 'package:dio/dio.dart';
import 'package:absen_ah/services/token_services.dart';
import 'package:absen_ah/main.dart'; // import navigatorKey

class DioClient {
  DioClient._();
  static Dio? _instance;

  static Dio getInstance() {
    _instance ??= _createDio();
    return _instance!;
  }

  /// Reset the singleton (useful after logout to clear interceptor state)
  static void reset() {
    _instance?.close();
    _instance = null;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://appabsensi.mobileprojp.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    // 1️⃣ Auth interceptor PERTAMA: inject Bearer Token sebelum request dikirim.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // 2️⃣ LogInterceptor KEDUA
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );

    // 3️⃣ Error interceptor untuk menangani 401 Unauthorized secara global.
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await TokenStorage.clearToken();
            // Redirect ke halaman login menggunakan navigatorKey
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}

// Backward compatible helper
Dio createDioClient() => DioClient.getInstance();
