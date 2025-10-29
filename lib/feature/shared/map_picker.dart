import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Map picker that requests runtime location permission and initializes
// the map to the device's current position when available.

class MapPickerPage extends StatefulWidget {
  final LatLng? initialPosition;
  const MapPickerPage({super.key, this.initialPosition});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _picked;
  final Completer<GoogleMapController> _controller = Completer();
  bool _hasLocationPermission = false;
  @override
  void initState() {
    super.initState();
    _picked = widget.initialPosition ?? const LatLng(23.0300, 72.5800);
    // determine and request permission, then get current location
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final r = await Geolocator.requestPermission();
        if (r == LocationPermission.denied ||
            r == LocationPermission.deniedForever) {
          // no permission, keep default or provided initial position
          if (mounted) setState(() => _hasLocationPermission = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // permission permanently denied, open app settings maybe
        if (mounted) setState(() => _hasLocationPermission = false);
        return;
      }

      // permission granted (or was already)
      if (mounted) setState(() => _hasLocationPermission = true);

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latlng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() => _picked = latlng);
        // animate camera if map already created
        if (_controller.isCompleted) {
          final ctrl = await _controller.future;
          await ctrl.animateCamera(CameraUpdate.newLatLngZoom(_picked, 16));
        }
      }
    } catch (e) {
      // ignore but keep default
      debugPrint('MapPicker: location init error: $e');
    }
  }

  void _onTap(LatLng pos) {
    setState(() {
      _picked = pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_picked);
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _picked, zoom: 14),
            onTap: _onTap,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
            markers: {
              Marker(markerId: const MarkerId('picked'), position: _picked),
            },
            myLocationButtonEnabled: _hasLocationPermission,
            myLocationEnabled: _hasLocationPermission,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Lat: ${_picked.latitude.toStringAsFixed(6)}, Lng: ${_picked.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_picked),
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
