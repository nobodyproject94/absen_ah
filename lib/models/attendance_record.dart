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
    required this.raw,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    String? asString(dynamic value) => value?.toString();

    return AttendanceRecord(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id'] ?? ''}'),
      date: asString(json['attendance_date'] ?? json['tanggal'] ?? json['date'] ?? json['created_at']),
      checkInTime: asString(json['check_in_time'] ?? json['jam_masuk'] ?? json['check_in'] ?? json['time_in']),
      checkOutTime: asString(json['check_out_time'] ?? json['jam_keluar'] ?? json['check_out'] ?? json['time_out']),
      checkInLatitude: asDouble(json['check_in_lat'] ?? json['check_in_latitude'] ?? json['latitude'] ?? json['lat']),
      checkInLongitude: asDouble(json['check_in_lng'] ?? json['check_in_longitude'] ?? json['longitude'] ?? json['lng']),
      checkOutLatitude: asDouble(json['check_out_lat'] ?? json['check_out_latitude']),
      checkOutLongitude: asDouble(json['check_out_lng'] ?? json['check_out_longitude']),
      checkInAddress: asString(json['check_in_address']),
      checkOutAddress: asString(json['check_out_address']),
      status: asString(json['status']),
      alasanIzin: asString(json['alasan_izin']),
      raw: json,
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
