import 'package:dio/dio.dart';
import 'package:absen_ah/services/token_services.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://appabsensi.mobileprojp.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  // 1️⃣ Auth interceptor PERTAMA: inject Bearer Token sebelum request dikirim.
  //    Harus di posisi pertama agar token sudah ada saat LogInterceptor mencatat.
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

  // 2️⃣ LogInterceptor KEDUA: mencatat request + response SETELAH token di-inject.
  //    requestHeader: true  → tampilkan Authorization header di log
  //    requestBody:  true   → tampilkan body JSON yang dikirim
  //    responseBody: true   → tampilkan body JSON yang diterima dari server
  dio.interceptors.add(
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
    ),
  );

  return dio;
}
