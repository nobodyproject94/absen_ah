import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../components/primary_button.dart';
import '../providers/attendance_provider.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class AttendanceSubmitMapPage extends StatefulWidget {
  final bool isCheckIn;

  const AttendanceSubmitMapPage({super.key, required this.isCheckIn});

  @override
  State<AttendanceSubmitMapPage> createState() => _AttendanceSubmitMapPageState();
}

class _AttendanceSubmitMapPageState extends State<AttendanceSubmitMapPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  double _distanceInMeters = 0.0;
  String _locationError = '';

  final LatLng _officeLocation = const LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude);

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _officeLocation.latitude,
        _officeLocation.longitude,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _distanceInMeters = distance;
        _isLoadingLocation = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString().replaceAll('Exception: ', '');
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) return;
    
    final provider = context.read<AttendanceProvider>();
    try {
      final message = await provider.submitAttendance(
        isCheckIn: widget.isCheckIn,
        position: _currentPosition,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? (widget.isCheckIn ? 'Absen masuk berhasil.' : 'Absen pulang berhasil.')),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Go back to dashboard after success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final isSubmitting = widget.isCheckIn ? provider.isCheckingIn : provider.isCheckingOut;
    final isWithinRadius = _distanceInMeters <= AppConstants.attendanceRadius;
    final typeStr = widget.isCheckIn ? 'Masuk' : 'Pulang';

    return Scaffold(
      appBar: AppBar(
        title: Text('Absen $typeStr'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _officeLocation,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            circles: {
              Circle(
                circleId: const CircleId('officeRadius'),
                center: _officeLocation,
                radius: AppConstants.attendanceRadius,
                fillColor: AppColors.primary.withValues(alpha: 0.15),
                strokeColor: AppColors.primary,
                strokeWidth: 2,
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('officeLocation'),
                position: _officeLocation,
                infoWindow: const InfoWindow(title: 'Kantor PPKD'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                ),
            },
          ),
          
          if (_isLoadingLocation)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Mendeteksi lokasi Anda...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
          if (_locationError.isNotEmpty)
            Container(
              color: Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off_rounded, size: 64, color: AppColors.danger),
                      const SizedBox(height: 16),
                      Text(
                        _locationError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Coba Lagi',
                        icon: Icons.refresh_rounded,
                        onPressed: () {
                          setState(() {
                            _isLoadingLocation = true;
                            _locationError = '';
                          });
                          _fetchCurrentLocation();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isLoadingLocation && _locationError.isEmpty) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isWithinRadius ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWithinRadius ? Icons.verified_rounded : Icons.gpp_bad_rounded,
                        color: isWithinRadius ? AppColors.success : AppColors.danger,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isWithinRadius ? 'Lokasi Valid' : 'Di Luar Jangkauan',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: isWithinRadius ? AppColors.success : AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jarak Anda: ${_distanceInMeters.toStringAsFixed(0)} meter dari kantor',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: isWithinRadius ? 'Konfirmasi Absen $typeStr' : 'Terlalu Jauh',
                  icon: isWithinRadius ? Icons.check_circle_rounded : Icons.block_rounded,
                  loading: isSubmitting,
                  backgroundColor: isWithinRadius ? AppColors.primary : Colors.grey,
                  onPressed: isWithinRadius && !isSubmitting ? _submitAttendance : null,
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoadingLocation || _locationError.isNotEmpty ? null : FloatingActionButton(
        onPressed: _fetchCurrentLocation,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }
}
