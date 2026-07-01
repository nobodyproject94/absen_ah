import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AttendanceDetailMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String title;

  const AttendanceDetailMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.title = 'Lokasi Absensi',
  });

  @override
  Widget build(BuildContext context) {
    final target = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: target, zoom: 17),
        markers: {
          Marker(
            markerId: const MarkerId('attendance_location'),
            position: target,
            infoWindow: InfoWindow(title: title, snippet: '$latitude, $longitude'),
          ),
        },
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
