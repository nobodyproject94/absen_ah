import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ntp/ntp.dart';
import 'dio_client.dart';

class TimeService {
  static final Dio _dio = createDioClient();

  /// Ambil waktu server resmi dari header HTTP Date atau fallback ke NTP
  /// Mengembalikan [TimeSyncResult] berisi waktu server dan selisih ms terhadap perangkat
  static Future<TimeSyncResult> fetchServerTime() async {
    final deviceNow = DateTime.now();
    try {
      // 1. Coba ambil dari HTTP header respons API (misal GET /api/absen/stats)
      final response = await _dio.get('/api/absen/stats');
      final dateHeader = response.headers.value('date');
      if (dateHeader != null && dateHeader.isNotEmpty) {
        final serverTime = HttpDate.parse(dateHeader).toLocal();
        final offsetMs = serverTime.difference(deviceNow).inMilliseconds;
        return TimeSyncResult(serverTime: serverTime, clientOffsetMs: offsetMs, source: 'HTTP Header');
      }
    } on DioException catch (e) {
      final dateHeader = e.response?.headers.value('date');
      if (dateHeader != null && dateHeader.isNotEmpty) {
        try {
          final serverTime = HttpDate.parse(dateHeader).toLocal();
          final offsetMs = serverTime.difference(deviceNow).inMilliseconds;
          return TimeSyncResult(serverTime: serverTime, clientOffsetMs: offsetMs, source: 'HTTP Header');
        } catch (_) {}
      }
      debugPrint('Gagal ambil waktu dari HTTP header DioException: ${e.message}. Mencoba NTP...');
    } catch (e) {
      debugPrint('Gagal ambil waktu dari HTTP header: $e. Mencoba NTP fallback...');
    }

    try {
      // 2. Fallback ke NTP server authority (pool.ntp.org)
      final offsetInt = await NTP.getNtpOffset(localTime: deviceNow);
      final ntpTime = deviceNow.add(Duration(milliseconds: offsetInt));
      return TimeSyncResult(serverTime: ntpTime, clientOffsetMs: offsetInt, source: 'NTP Authority');
    } catch (e) {
      debugPrint('NTP sync gagal: $e. Menggunakan waktu perangkat sebagai fallback.');
    }

    // 3. Ultimate fallback ke device time jika offline total
    return TimeSyncResult(serverTime: deviceNow, clientOffsetMs: 0, source: 'Device Time (Offline)');
  }
}

class TimeSyncResult {
  final DateTime serverTime;
  final int clientOffsetMs;
  final String source;

  const TimeSyncResult({
    required this.serverTime,
    required this.clientOffsetMs,
    required this.source,
  });
}
