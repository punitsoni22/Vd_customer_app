import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialPosition;
  const MapPickerPage({super.key, this.initialPosition});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _picked;
  bool _isLoadingLocation = true;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _picked = widget.initialPosition ?? const LatLng(23.0300, 72.5800);
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          // Permission denied, show message and use default location
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission denied. Using default location.',
                ),
                duration: Duration(seconds: 3),
              ),
            );
            setState(() => _isLoadingLocation = false);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission permanently denied. Please enable in settings.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      // Permission granted, get current location
      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Location permission error: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        final newLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          _picked = newLocation;
          _isLoadingLocation = false;
        });

        // Animate map to current location if controller is available
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(newLocation, 16),
          );
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Current location selected'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Get current location error: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get current location. Using default.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Pick Location",
        showBack: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_picked),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: GoogleMap(
        liteModeEnabled: false, // Temporarily disable for testing
        initialCameraPosition: CameraPosition(target: _picked, zoom: 15),
        onTap: (position) {
          setState(() {
            _picked = position;
          });
        },
        onMapCreated: (controller) {
          _mapController = controller;
          // If we already have current location, animate to it
          if (!_isLoadingLocation) {
            controller.animateCamera(CameraUpdate.newLatLngZoom(_picked, 16));
          }
        },
        markers: {
          Marker(
            markerId: const MarkerId('selected'),
            position: _picked,
            infoWindow: const InfoWindow(title: 'Selected Location'),
          ),
        },
        zoomControlsEnabled: false, // Reduce UI complexity
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
        backgroundColor: AllColors.tabBarline,
        foregroundColor: Colors.white,
        child: _isLoadingLocation
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.my_location, size: 28),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoadingLocation)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Getting your location...',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              )
            else
              Text(
                'Lat: ${_picked.latitude.toStringAsFixed(6)}, Lng: ${_picked.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_picked),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColors.tabBarline,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SELECT LOCATION'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
