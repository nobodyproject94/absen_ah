import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/app_colors.dart';

class GeofenceMapHelper {
  /// Membangun overlay lingkaran geofence dengan warna dinamis (Hijau = Dalam Radius, Merah = Di Luar Radius)
  static Circle buildGeofenceCircle({
    required String circleId,
    required LatLng center,
    required double radius,
    required bool isWithinRadius,
  }) {
    final color = isWithinRadius ? AppColors.success : AppColors.danger;
    return Circle(
      circleId: CircleId(circleId),
      center: center,
      radius: radius,
      fillColor: color.withValues(alpha: 0.15),
      strokeColor: color,
      strokeWidth: 2,
    );
  }

  /// Membangun garis Polyline yang menghubungkan dua titik atau lebih (misal posisi peserta ke kantor PPKD)
  static Polyline buildRoutePolyline({
    required String polylineId,
    required List<LatLng> points,
    Color color = AppColors.primary,
    int width = 4,
    bool isDotted = false,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      patterns: isDotted ? [PatternItem.dot, PatternItem.gap(10)] : const [],
      geodesic: true,
    );
  }
}
