import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shared/map_picker.dart';

class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({super.key});

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullAddress = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _postalCode = TextEditingController();
  bool _isDefault = false;
  LatLng? _pickedLatLng;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullAddress.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a location on map')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "data": {
        "id": 0,
        "fullAddress": _fullAddress.text.trim(),
        "city": _city.text.trim(),
        "state": _state.text.trim(),
        "country": _country.text.trim(),
        "postalCode": _postalCode.text.trim(),
        "isDefault": _isDefault,
        "latitude": _pickedLatLng!.latitude,
        "longitude": _pickedLatLng!.longitude,
      },
    };

    final resp = await Api.post('addEditAddress', payload);

    setState(() => _isSubmitting = false);

    if (resp['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp['message'] ?? 'Address added')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Failed to add address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Address',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fullAddress,
                  decoration: const InputDecoration(labelText: 'Full Address'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: _state,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
                TextFormField(
                  controller: _country,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                TextFormField(
                  controller: _postalCode,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v ?? false),
                    ),
                    const Text('Set as default'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _pickedLatLng == null
                            ? 'No location selected'
                            : 'Lat: ${_pickedLatLng!.latitude.toStringAsFixed(6)}, Lng: ${_pickedLatLng!.longitude.toStringAsFixed(6)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.of(context).push<LatLng?>(
                          MaterialPageRoute(
                            builder: (_) =>
                                MapPickerPage(initialPosition: _pickedLatLng),
                          ),
                        );
                        if (res != null) {
                          setState(() => _pickedLatLng = res);
                        }
                      },
                      child: const Text('Pick on map'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Save Address'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
