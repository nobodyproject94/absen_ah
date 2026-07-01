class AttendanceRecord {
  final int? id;
  final String? date;
  final String? checkInTime;
  final String? checkOutTime;
  final double? latitude;
  final double? longitude;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final Map<String, dynamic> raw;

  const AttendanceRecord({
    this.id,
    this.date,
    this.checkInTime,
    this.checkOutTime,
    this.latitude,
    this.longitude,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
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
      date: asString(json['tanggal'] ?? json['date'] ?? json['created_at']),
      checkInTime: asString(json['jam_masuk'] ?? json['check_in'] ?? json['check_in_time'] ?? json['time_in']),
      checkOutTime: asString(json['jam_keluar'] ?? json['check_out'] ?? json['check_out_time'] ?? json['time_out']),
      latitude: asDouble(json['latitude'] ?? json['lat']),
      longitude: asDouble(json['longitude'] ?? json['lng'] ?? json['long']),
      checkInLatitude: asDouble(json['check_in_latitude'] ?? json['latitude_masuk'] ?? json['lat_masuk']),
      checkInLongitude: asDouble(json['check_in_longitude'] ?? json['longitude_masuk'] ?? json['lng_masuk'] ?? json['long_masuk']),
      checkOutLatitude: asDouble(json['check_out_latitude'] ?? json['latitude_keluar'] ?? json['lat_keluar']),
      checkOutLongitude: asDouble(json['check_out_longitude'] ?? json['longitude_keluar'] ?? json['lng_keluar'] ?? json['long_keluar']),
      raw: json,
    );
  }

  bool get hasCheckedIn => checkInTime != null && checkInTime!.isNotEmpty;
  bool get hasCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  double? get displayLatitude => checkInLatitude ?? latitude ?? checkOutLatitude;
  double? get displayLongitude => checkInLongitude ?? longitude ?? checkOutLongitude;
}
