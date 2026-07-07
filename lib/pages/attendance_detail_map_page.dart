import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/attendance_record.dart';
import '../components/geofence_map_marker.dart';
import '../utils/app_colors.dart';
import '../l10n/app_localizations.dart';

class AttendanceDetailMapPage extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String title;
  final AttendanceRecord? record;

  const AttendanceDetailMapPage({
    super.key,
    this.latitude,
    this.longitude,
    this.title = 'Lokasi Absensi',
    this.record,
  });

  @override
  State<AttendanceDetailMapPage> createState() => _AttendanceDetailMapPageState();
}

class _AttendanceDetailMapPageState extends State<AttendanceDetailMapPage> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final record = widget.record;
    final checkInLat = record?.checkInLatitude ?? widget.latitude;
    final checkInLng = record?.checkInLongitude ?? widget.longitude;
    final checkOutLat = record?.checkOutLatitude;
    final checkOutLng = record?.checkOutLongitude;

    final hasCheckIn = checkInLat != null && checkInLng != null;
    final hasCheckOut = checkOutLat != null && checkOutLng != null;

    if (!hasCheckIn && !hasCheckOut) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(child: Text(l10n.errCoordsNotAvailable)),
      );
    }

    final targetLat = checkInLat ?? checkOutLat!;
    final targetLng = checkInLng ?? checkOutLng!;
    final initialTarget = LatLng(targetLat, targetLng);

    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    if (hasCheckIn) {
      markers.add(
        Marker(
          markerId: const MarkerId('checkInMarker'),
          position: LatLng(checkInLat, checkInLng),
          infoWindow: InfoWindow(
            title: l10n.checkInPointInfo(record?.checkInTime ?? "-", record?.checkInAddress ?? "$checkInLat, $checkInLng"),
            snippet: record?.checkInAddress ?? '$checkInLat, $checkInLng',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    if (hasCheckOut) {
      markers.add(
        Marker(
          markerId: const MarkerId('checkOutMarker'),
          position: LatLng(checkOutLat, checkOutLng),
          infoWindow: InfoWindow(
            title: l10n.checkOutPointInfo(record?.checkOutTime ?? "-", record?.checkOutAddress ?? "$checkOutLat, $checkOutLng"),
            snippet: record?.checkOutAddress ?? '$checkOutLat, $checkOutLng',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (hasCheckIn && hasCheckOut) {
      polylines.add(
        GeofenceMapHelper.buildRoutePolyline(
          polylineId: 'routeCheckInToOut',
          points: [
            LatLng(checkInLat, checkInLng),
            LatLng(checkOutLat, checkOutLng),
          ],
          color: AppColors.primary,
          width: 5,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initialTarget, zoom: 16),
            markers: markers,
            polylines: polylines,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              if (hasCheckIn && hasCheckOut) {
                _animateToBounds(
                  LatLng(checkInLat, checkInLng),
                  LatLng(checkOutLat, checkOutLng),
                );
              }
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pointInfoTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    if (hasCheckIn) ...[
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.checkInPointInfo(record?.checkInTime ?? "-", record?.checkInAddress ?? "$checkInLat, $checkInLng"),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (hasCheckOut) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.checkOutPointInfo(record?.checkOutTime ?? "-", record?.checkOutAddress ?? "$checkOutLat, $checkOutLng"),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _animateToBounds(LatLng p1, LatLng p2) {
    if (_mapController == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        p1.latitude < p2.latitude ? p1.latitude : p2.latitude,
        p1.longitude < p2.longitude ? p1.longitude : p2.longitude,
      ),
      northeast: LatLng(
        p1.latitude > p2.latitude ? p1.latitude : p2.latitude,
        p1.longitude > p2.longitude ? p1.longitude : p2.longitude,
      ),
    );
    try {
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (_) {}
  }
}
