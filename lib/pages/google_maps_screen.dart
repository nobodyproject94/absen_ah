import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_colors.dart';
import '../l10n/app_localizations.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String _currentAddress = "";
  bool _isLoadingAddress = true;
  final Set<Marker> _markers = {};
  final LatLng _officeLocation = const LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude);

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    setState(() {
      _isLoadingAddress = true;
    });
    try {
      Position position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
      _updateMarkerAndCamera(position);
      await _getAddressFromLatLng(position);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentAddress = e.toString().replaceAll('Exception: ', '');
        _isLoadingAddress = false;
      });
    }
  }

  void _updateMarkerAndCamera(Position position) {
    final l10n = AppLocalizations.of(context)!;
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: currentLatLng,
            infoWindow: InfoWindow(title: l10n.yourLocation),
          ),
        );
      });
    }

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 15),
      ),
    );
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _currentAddress =
                "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
            _isLoadingAddress = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _openInGoogleMaps() async {
    final l10n = AppLocalizations.of(context)!;
    if (_currentPosition == null) return;

    final double lat = _currentPosition!.latitude;
    final double lng = _currentPosition!.longitude;

    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka Google Maps URL';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errOpenExternalMap(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.googleMapsTitle)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : _officeLocation,
              zoom: 15.0,
            ),
            markers: {
              ..._markers,
              Marker(
                markerId: const MarkerId("officeLocation"),
                position: _officeLocation,
                infoWindow: InfoWindow(title: l10n.officeName, snippet: l10n.officeDesc),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            },
            circles: {
              Circle(
                circleId: const CircleId('officeGeofence'),
                center: _officeLocation,
                radius: AppConstants.attendanceRadius,
                fillColor: AppColors.primary.withValues(alpha: 0.15),
                strokeColor: AppColors.primary,
                strokeWidth: 2,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _updateMarkerAndCamera(_currentPosition!);
              }
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.currentAddressLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoadingAddress ? l10n.searchingLocation : _currentAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openInGoogleMaps,
                      icon: const Icon(Icons.navigation),
                      label: Text(l10n.openInGoogleMaps),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkPermissionsAndGetLocation,
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
