import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../components/geofence_map_marker.dart';
import '../components/primary_button.dart';
import '../providers/attendance_provider.dart';
import '../providers/time_provider.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';

class AttendanceSubmitMapPage extends StatefulWidget {
  final bool isCheckIn;

  const AttendanceSubmitMapPage({super.key, required this.isCheckIn});

  @override
  State<AttendanceSubmitMapPage> createState() => _AttendanceSubmitMapPageState();
}

class _AttendanceSubmitMapPageState extends State<AttendanceSubmitMapPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isLoadingLocation = true;
  double _distanceInMeters = 0.0;
  String _locationError = '';
  bool _hasBoundedCamera = false;

  final LatLng _officeLocation = const LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude);

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _startLiveTracking() {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    _positionStream?.cancel();
    _positionStream = LocationService.getLivePositionStream().listen(
      (position) {
        if (!mounted) return;
        _updatePositionAndDistance(position);
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _locationError = e.toString().replaceAll('Exception: ', '');
          _isLoadingLocation = false;
        });
      },
    );
  }

  void _updatePositionAndDistance(Position position) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );

    setState(() {
      _currentPosition = position;
      _distanceInMeters = distance;
      _isLoadingLocation = false;
      _locationError = '';
    });

    if (!_hasBoundedCamera && _mapController != null) {
      _animateCameraToBounds(position);
      _hasBoundedCamera = true;
    }
  }

  void _animateCameraToBounds(Position position) {
    if (_mapController == null) return;
    final userLatLng = LatLng(position.latitude, position.longitude);
    
    // Jika jarak terlalu dekat (< 100m), cukup zoom 17 di tengah
    if (_distanceInMeters < 100) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 17));
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        userLatLng.latitude < _officeLocation.latitude ? userLatLng.latitude : _officeLocation.latitude,
        userLatLng.longitude < _officeLocation.longitude ? userLatLng.longitude : _officeLocation.longitude,
      ),
      northeast: LatLng(
        userLatLng.latitude > _officeLocation.latitude ? userLatLng.latitude : _officeLocation.latitude,
        userLatLng.longitude > _officeLocation.longitude ? userLatLng.longitude : _officeLocation.longitude,
      ),
    );

    try {
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));
    } catch (_) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 16));
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) return;

    final attendanceProvider = context.read<AttendanceProvider>();
    final timeProvider = context.read<TimeProvider>();
    final l10n = AppLocalizations.of(context)!;

    try {
      final message = await attendanceProvider.submitAttendance(
        isCheckIn: widget.isCheckIn,
        position: _currentPosition,
        accuracy: _currentPosition!.accuracy,
        deviceTime: DateTime.now(),
        clientOffsetMs: timeProvider.clientOffsetMs,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? (widget.isCheckIn ? l10n.checkInSuccess : l10n.checkOutSuccess)),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Kembali ke dashboard setelah sukses
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorTranslator.translate(context, e)),
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
    final isAccuracyGood = (_currentPosition?.accuracy ?? 999) <= AppConstants.minGpsAccuracyMeters;
    final canSubmit = isWithinRadius && isAccuracyGood && !isSubmitting;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCheckIn ? l10n.submitMapTitleCheckIn : l10n.submitMapTitleCheckOut),
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
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null && !_hasBoundedCamera) {
                _animateCameraToBounds(_currentPosition!);
                _hasBoundedCamera = true;
              }
            },
            circles: {
              GeofenceMapHelper.buildGeofenceCircle(
                circleId: 'officeGeofence',
                center: _officeLocation,
                radius: AppConstants.attendanceRadius,
                isWithinRadius: isWithinRadius,
              ),
            },
            polylines: {
              if (_currentPosition != null)
                GeofenceMapHelper.buildRoutePolyline(
                  polylineId: 'pathToOffice',
                  points: [
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    _officeLocation,
                  ],
                  color: isWithinRadius ? AppColors.success : AppColors.danger,
                  isDotted: true,
                ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('officeLocation'),
                position: _officeLocation,
                infoWindow: InfoWindow(title: l10n.officeName, snippet: l10n.officeDesc),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  infoWindow: InfoWindow(
                    title: l10n.yourPosition(_distanceInMeters.toStringAsFixed(0)),
                    snippet: l10n.gpsAccuracy(_currentPosition!.accuracy.toStringAsFixed(0)),
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    isWithinRadius ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
                  ),
                ),
            },
          ),

          if (_isLoadingLocation)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.detectingLocation, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        label: l10n.tryAgainButton,
                        icon: Icons.refresh_rounded,
                        onPressed: _startLiveTracking,
                      ),
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
                            isWithinRadius ? l10n.inGeofence : l10n.outGeofence,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isWithinRadius ? AppColors.success : AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.distanceInfo(_distanceInMeters.toStringAsFixed(0), AppConstants.attendanceRadius.toStringAsFixed(0)),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.gpsAccuracy(_currentPosition?.accuracy.toStringAsFixed(0) ?? '-')} ${!isAccuracyGood ? l10n.gpsWeak : l10n.gpsGood}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isAccuracyGood ? Colors.grey : AppColors.danger,
                              fontWeight: !isAccuracyGood ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: !isWithinRadius
                      ? l10n.tooFarButton
                      : (!isAccuracyGood ? l10n.searchingGpsButton : (widget.isCheckIn ? l10n.confirmCheckInButton : l10n.confirmCheckOutButton)),
                  icon: canSubmit ? Icons.check_circle_rounded : Icons.block_rounded,
                  loading: isSubmitting,
                  backgroundColor: canSubmit ? AppColors.primary : Colors.grey,
                  onPressed: canSubmit ? _submitAttendance : null,
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoadingLocation || _locationError.isNotEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (_currentPosition != null) {
                  _animateCameraToBounds(_currentPosition!);
                }
              },
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.my_location_rounded),
            ),
    );
  }
}
