import '../utils/app_constants.dart';

class AttendanceRecord {
  final int? id;
  final String? date;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? status;
  final String? alasanIzin;
  final DateTime? serverTimestamp;
  final DateTime? deviceTimestamp;
  final int? clientOffsetMs;
  final bool? timeAnomaly;
  final double? accuracyMeters;
  final double? distanceToOfficeM;
  final bool? isLate;
  final Map<String, dynamic> raw;

  const AttendanceRecord({
    this.id,
    this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkInAddress,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
    this.serverTimestamp,
    this.deviceTimestamp,
    this.clientOffsetMs,
    this.timeAnomaly,
    this.accuracyMeters,
    this.distanceToOfficeM,
    this.isLate,
    required this.raw,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    String? asString(dynamic value) => value?.toString();

    DateTime? asDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    final checkInTimeVal = asString(json['check_in_time'] ?? json['jam_masuk'] ?? json['check_in'] ?? json['time_in']);
    final clientOffsetVal = asInt(json['client_offset_ms'] ?? json['offset_ms']);

    bool? parsedIsLate;
    if (json['is_late'] != null) {
      parsedIsLate = json['is_late'] == true || json['is_late'] == 1 || json['is_late'] == 'true';
    } else if (checkInTimeVal != null && checkInTimeVal.isNotEmpty) {
      parsedIsLate = checkInTimeVal.compareTo(AppConstants.checkInDeadline) > 0;
    }

    bool? parsedTimeAnomaly;
    if (json['time_anomaly'] != null) {
      parsedTimeAnomaly = json['time_anomaly'] == true || json['time_anomaly'] == 1 || json['time_anomaly'] == 'true';
    } else if (clientOffsetVal != null) {
      parsedTimeAnomaly = clientOffsetVal.abs() > AppConstants.timeAnomalyThresholdMs;
    }

    return AttendanceRecord(
      id: asInt(json['id']),
      date: asString(json['attendance_date'] ?? json['tanggal'] ?? json['date'] ?? json['created_at']),
      checkInTime: checkInTimeVal,
      checkOutTime: asString(json['check_out_time'] ?? json['jam_keluar'] ?? json['check_out'] ?? json['time_out']),
      checkInLatitude: asDouble(json['check_in_lat'] ?? json['check_in_latitude'] ?? json['latitude'] ?? json['lat']),
      checkInLongitude: asDouble(json['check_in_lng'] ?? json['check_in_longitude'] ?? json['longitude'] ?? json['lng']),
      checkOutLatitude: asDouble(json['check_out_lat'] ?? json['check_out_latitude']),
      checkOutLongitude: asDouble(json['check_out_lng'] ?? json['check_out_longitude']),
      checkInAddress: asString(json['check_in_address']),
      checkOutAddress: asString(json['check_out_address']),
      status: asString(json['status']),
      alasanIzin: asString(json['alasan_izin']),
      serverTimestamp: asDateTime(json['server_timestamp'] ?? json['created_at']),
      deviceTimestamp: asDateTime(json['device_timestamp']),
      clientOffsetMs: clientOffsetVal,
      timeAnomaly: parsedTimeAnomaly,
      accuracyMeters: asDouble(json['accuracy_meters'] ?? json['accuracy']),
      distanceToOfficeM: asDouble(json['distance_to_office_m'] ?? json['distance']),
      isLate: parsedIsLate,
      raw: json,
    );
  }

  AttendanceRecord copyWith({
    int? id,
    String? date,
    String? checkInTime,
    String? checkOutTime,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? checkInAddress,
    String? checkOutAddress,
    String? status,
    String? alasanIzin,
    DateTime? serverTimestamp,
    DateTime? deviceTimestamp,
    int? clientOffsetMs,
    bool? timeAnomaly,
    double? accuracyMeters,
    double? distanceToOfficeM,
    bool? isLate,
    Map<String, dynamic>? raw,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      checkInAddress: checkInAddress ?? this.checkInAddress,
      checkOutAddress: checkOutAddress ?? this.checkOutAddress,
      status: status ?? this.status,
      alasanIzin: alasanIzin ?? this.alasanIzin,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
      deviceTimestamp: deviceTimestamp ?? this.deviceTimestamp,
      clientOffsetMs: clientOffsetMs ?? this.clientOffsetMs,
      timeAnomaly: timeAnomaly ?? this.timeAnomaly,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      distanceToOfficeM: distanceToOfficeM ?? this.distanceToOfficeM,
      isLate: isLate ?? this.isLate,
      raw: raw ?? this.raw,
    );
  }

  bool get hasCheckedIn => checkInTime != null && checkInTime!.isNotEmpty;
  bool get hasCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;
  bool get isIzin => status == 'izin';
  bool get isMasuk => status == 'masuk';

  double? get displayLatitude => checkInLatitude ?? checkOutLatitude;
  double? get displayLongitude => checkInLongitude ?? checkOutLongitude;

  String get displayAddress {
    if (checkInAddress != null && checkInAddress!.isNotEmpty) return checkInAddress!;
    if (checkOutAddress != null && checkOutAddress!.isNotEmpty) return checkOutAddress!;
    return 'Lokasi tidak tersedia';
  }
}
