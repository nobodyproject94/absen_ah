import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/attendance_record.dart';
import '../services/dio_client.dart';
import '../services/location_service.dart';
import '../utils/helpers.dart';

class AttendanceProvider extends ChangeNotifier {
  final Dio _dio = createDioClient();

  bool _isLoading = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  bool _isSubmittingIzin = false;
  String? _error;
  List<AttendanceRecord> _records = [];
  AttendanceRecord? _todayRecord;
  Position? _lastPosition;

  // Stats from server
  int _totalAbsen = 0;
  int _totalMasuk = 0;
  int _totalIzin = 0;
  bool _sudahAbsenHariIni = false;

  bool get isLoading => _isLoading;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
  bool get isSubmittingIzin => _isSubmittingIzin;
  String? get error => _error;
  List<AttendanceRecord> get records => _records;
  Position? get lastPosition => _lastPosition;
  int get totalAbsen => _totalAbsen;
  int get totalMasuk => _totalMasuk;
  int get totalIzin => _totalIzin;
  bool get sudahAbsenHariIni => _sudahAbsenHariIni;

  AttendanceRecord? get todayRecord {
    if (_todayRecord != null) return _todayRecord;
    final now = DateTime.now();
    final todayKey = '${now.year}-${_dd(now.month)}-${_dd(now.day)}';
    for (final r in _records) {
      if (r.date == todayKey) return r;
    }
    return null;
  }

  String _dd(int value) => value.toString().padLeft(2, '0');

  /// Fetch attendance history from server
  Future<void> fetchHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/absen/history');
      _records = parseAttendanceList(response.data);
    } catch (e) {
      _error = 'Gagal memuat riwayat: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch today's attendance status
  Future<void> fetchTodayAbsen() async {
    try {
      final now = DateTime.now();
      final today = '${now.year}-${_dd(now.month)}-${_dd(now.day)}';
      final response = await _dio.get('/api/absen/today', queryParameters: {'attendance_date': today});
      final data = response.data;
      if (data is Map && data['data'] != null) {
        _todayRecord = AttendanceRecord.fromJson(Map<String, dynamic>.from(data['data']));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching today absen: $e');
    }
  }

  /// Fetch attendance stats from server
  Future<void> fetchStats() async {
    try {
      final response = await _dio.get('/api/absen/stats');
      final data = response.data;
      if (data is Map && data['data'] != null) {
        final stats = data['data'];
        _totalAbsen = stats['total_absen'] ?? 0;
        _totalMasuk = stats['total_masuk'] ?? 0;
        _totalIzin = stats['total_izin'] ?? 0;
        _sudahAbsenHariIni = stats['sudah_absen_hari_ini'] ?? false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  /// Get address from coordinates using geocoding
  Future<String> _getAddressFromCoords(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return '$lat, $lng';
  }

  /// Submit check-in or check-out
  Future<String?> submitAttendance({required bool isCheckIn, Position? position}) async {
    if (isCheckIn) {
      _isCheckingIn = true;
    } else {
      _isCheckingOut = true;
    }
    notifyListeners();

    try {
      // Use provided position from the map, otherwise fallback to fetching
      final finalPosition = position ?? await LocationService.getCurrentPosition();
      _lastPosition = finalPosition;

      final now = DateTime.now();
      final dateStr = '${now.year}-${_dd(now.month)}-${_dd(now.day)}';
      final timeStr = '${_dd(now.hour)}:${_dd(now.minute)}';
      final address = await _getAddressFromCoords(finalPosition.latitude, finalPosition.longitude);

      Map<String, dynamic> body;
      String endpoint;

      if (isCheckIn) {
        endpoint = '/api/absen/check-in';
        body = {
          'attendance_date': dateStr,
          'check_in': timeStr,
          'check_in_lat': finalPosition.latitude,
          'check_in_lng': finalPosition.longitude,
          'check_in_address': address,
          'status': 'masuk',
        };
      } else {
        endpoint = '/api/absen/check-out';
        body = {
          'attendance_date': dateStr,
          'check_out': timeStr,
          'check_out_lat': finalPosition.latitude,
          'check_out_lng': finalPosition.longitude,
          'check_out_address': address,
        };
      }

      final response = await _dio.post(endpoint, data: body);

      // Refresh data after successful submit
      await Future.wait([fetchHistory(), fetchTodayAbsen(), fetchStats()]);

      return extractApiMessage(
        response.data,
        isCheckIn ? 'Absen masuk berhasil.' : 'Absen pulang berhasil.',
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409) {
        throw Exception(extractApiMessage(e.response?.data, 'Anda sudah absen hari ini.'));
      }
      if (status == 404) {
        throw Exception(extractApiMessage(e.response?.data, isCheckIn ? 'Gagal check-in.' : 'Anda belum melakukan absen masuk hari ini.'));
      }
      throw Exception(extractApiMessage(e.response?.data, 'Gagal melakukan absensi.'));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isCheckingIn = false;
      _isCheckingOut = false;
      notifyListeners();
    }
  }

  /// Submit izin/permit
  Future<String?> submitIzin({required String date, required String alasan}) async {
    _isSubmittingIzin = true;
    notifyListeners();

    try {
      final response = await _dio.post('/api/izin', data: {
        'date': date,
        'alasan_izin': alasan,
      });

      await Future.wait([fetchHistory(), fetchStats()]);

      return extractApiMessage(response.data, 'Izin berhasil diajukan.');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409) {
        throw Exception(extractApiMessage(e.response?.data, 'Anda sudah mengajukan izin pada tanggal ini.'));
      }
      throw Exception(extractApiMessage(e.response?.data, 'Gagal mengajukan izin.'));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isSubmittingIzin = false;
      notifyListeners();
    }
  }

  /// Delete attendance record
  Future<String?> deleteAttendance(int id) async {
    try {
      final response = await _dio.delete('/api/absen/$id');
      await Future.wait([fetchHistory(), fetchStats()]);
      return extractApiMessage(response.data, 'Data absen berhasil dihapus.');
    } on DioException catch (e) {
      throw Exception(extractApiMessage(e.response?.data, 'Gagal menghapus data absen.'));
    }
  }

  /// Fetch history with date range filter
  Future<List<AttendanceRecord>> fetchHistoryByRange(String start, String end) async {
    try {
      final response = await _dio.get('/api/absen/history', queryParameters: {
        'start': start,
        'end': end,
      });
      return parseAttendanceList(response.data);
    } catch (e) {
      throw Exception('Gagal memuat riwayat: ${e.toString()}');
    }
  }

  /// Parse attendance list from API response
  static List<AttendanceRecord> parseAttendanceList(dynamic payload) {
    dynamic raw = payload;
    if (payload is Map) {
      raw = payload['data'] ?? payload['absen'] ?? payload['history'] ?? payload['data_absen'];
    }
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => AttendanceRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }
}
