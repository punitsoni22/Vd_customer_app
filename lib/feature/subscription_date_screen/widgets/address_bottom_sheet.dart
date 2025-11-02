import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import '../../shared/map_picker.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

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
  bool _hasPickedLocation = false; // Track if location has been picked
  // NOTE: API key is stored here for the reverse geocoding request.
  // For production keep keys out of source code (use secure storage or env).
  static const String _googleApiKey = 'AIzaSyDS1a7YKzXMn1K8B1G0rtRg8dgISRyAlDo';

  @override
  void dispose() {
    _fullAddress.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocodeAndFill(LatLng pos) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=$_googleApiKey',
      );
      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch address info')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(resp.body);
      if (data['status'] != 'OK' || (data['results'] as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No address found: ${data['status']}')),
        );
        return;
      }

      final first = data['results'][0] as Map<String, dynamic>;
      final formatted = first['formatted_address'] as String?;
      final components = (first['address_components'] as List)
          .cast<Map<String, dynamic>>();

      String? getComp(String type) {
        try {
          final comp = components.firstWhere(
            (c) => (c['types'] as List).contains(type),
          );
          return comp['long_name'] as String?;
        } catch (e) {
          return null;
        }
      }

      final cityVal =
          getComp('locality') ??
          getComp('postal_town') ??
          getComp('sublocality') ??
          getComp('administrative_area_level_2');
      final stateVal = getComp('administrative_area_level_1');
      final countryVal = getComp('country');
      final postalVal = getComp('postal_code');

      setState(() {
        if (formatted != null) _fullAddress.text = formatted;
        if (cityVal != null) _city.text = cityVal;
        if (stateVal != null) _state.text = stateVal;
        if (countryVal != null) _country.text = countryVal;
        if (postalVal != null) _postalCode.text = postalVal;
        _hasPickedLocation = true; // Mark that location has been picked
      });
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get address from location')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_hasPickedLocation || _pickedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a location on the map first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

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

  Widget fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h, top: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AllColors.buttonColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // ✅ bottom sheet white
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Add New Address',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AllColors.buttonColor,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Show message if location not picked yet
                if (!_hasPickedLocation) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.orange, size: 20),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Please pick a location on the map first to enable address fields',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                fieldLabel("Full Address"),
                CommonTextField(
                  controller: _fullAddress,
                  label: "Full Address",
                  enabled: _hasPickedLocation, // Only enable if location picked
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Required" : null,
                  radius: 10,
                  padding: EdgeInsets.symmetric(
                    vertical: 9.h,
                    horizontal: 12.w,
                  ),
                ),

                fieldLabel("City"),
                CommonTextField(
                  controller: _city,
                  label: "City",
                  enabled: _hasPickedLocation, // Only enable if location picked
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Required" : null,
                  radius: 10,
                  padding: EdgeInsets.symmetric(
                    vertical: 9.h,
                    horizontal: 12.w,
                  ),
                ),

                fieldLabel("State"),
                CommonTextField(
                  controller: _state,
                  label: "State",
                  enabled: _hasPickedLocation, // Only enable if location picked
                  radius: 10,
                  padding: EdgeInsets.symmetric(
                    vertical: 9.h,
                    horizontal: 12.w,
                  ),
                ),

                fieldLabel("Country"),
                CommonTextField(
                  controller: _country,
                  label: "Country",
                  enabled: _hasPickedLocation, // Only enable if location picked
                  radius: 10,
                  padding: EdgeInsets.symmetric(
                    vertical: 9.h,
                    horizontal: 12.w,
                  ),
                ),

                fieldLabel("Pin Code"),
                CommonTextField(
                  controller: _postalCode,
                  label: "Pin Code",
                  enabled: _hasPickedLocation, // Only enable if location picked
                  keyboardType: TextInputType.number,
                  radius: 10,
                  padding: EdgeInsets.symmetric(
                    vertical: 9.h,
                    horizontal: 12.w,
                  ),
                ),

                SizedBox(height: 8.h),
                Row(
                  children: [
                    Checkbox(
                      value: _isDefault,
                      onChanged: _hasPickedLocation
                          ? (v) => setState(() => _isDefault = v ?? false)
                          : null, // Disable checkbox if location not picked
                      activeColor: AllColors.buttonColor,
                    ),
                    Text(
                      'Set as default',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _hasPickedLocation
                            ? Colors.black
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasPickedLocation
                                ? '✅ Location Selected'
                                : 'Tap "Pick on Map" to select location',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _hasPickedLocation
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_hasPickedLocation && _pickedLatLng != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Lat: ${_pickedLatLng!.latitude.toStringAsFixed(4)}, Lng: ${_pickedLatLng!.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CommonButton(
                      buttonValue: _hasPickedLocation
                          ? 'Change Location'
                          : 'Pick on Map',
                      isFullWidth: false,
                      selfconstraints: BoxConstraints(
                        maxWidth: 140.w,
                        minHeight: 40.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 7.h,
                        horizontal: 10.w,
                      ),
                      onTap: () async {
                        final result = await Navigator.push<LatLng>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MapPickerPage(initialPosition: _pickedLatLng),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _pickedLatLng = result;
                          });
                          await _reverseGeocodeAndFill(result);
                        }
                      },
                      backgroundColor: _hasPickedLocation
                          ? AllColors.olivegreenColor
                          : AllColors.tabBarline,
                      radius: 8.r,
                      textStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                CommonButton(
                  padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 5.w),
                  buttonValue: 'Save Address',
                  isFullWidth: false,
                  selfconstraints: BoxConstraints(
                    maxWidth: 160.w,
                    minHeight: 40.h,
                  ),
                  isLoading: _isSubmitting,
                  onTap: (!_hasPickedLocation || _isSubmitting)
                      ? null
                      : _submit,
                  backgroundColor: _hasPickedLocation
                      ? AllColors.tabBarline
                      : Colors.grey.shade400,
                  radius: 10.r,
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
