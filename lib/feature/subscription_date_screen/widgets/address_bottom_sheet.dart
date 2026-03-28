import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

import '../../shared/map_picker.dart';

class AddressBottomSheet extends StatefulWidget {
  final List<AddressModel>? addresses;
  final String? selectedId;
  final Function(String)? onSelected;
  final AddressModel? editAddress;

  const AddressBottomSheet({
    super.key,
    this.addresses,
    this.selectedId,
    this.onSelected,
    this.editAddress,
  });

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

  AddressModel? _editingAddress;
  bool _isDefault = false;
  LatLng? _pickedLatLng;
  bool _isSubmitting = false;
  bool _hasPickedLocation = false;
  bool _showAddForm = false;

  String get _googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();

    final initial = widget.editAddress;
    if (initial != null) {
      final lat = initial.latitudeDouble;
      final lng = initial.longitudeDouble;
      _editingAddress = initial;
      _showAddForm = true;
      _fullAddress.text = initial.fullAddress;
      _city.text = initial.city;
      _state.text = initial.state;
      _country.text = initial.country;
      _postalCode.text = initial.postalCode;
      _isDefault = initial.isDefault;
      if (lat != null && lng != null) {
        _pickedLatLng = LatLng(lat, lng);
        _hasPickedLocation = true;
      } else {
        _pickedLatLng = null;
        _hasPickedLocation = false;
      }
    }
  }

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
      final key = _googleApiKey;
      if (key.isEmpty) {
        MySnackBar.showSnackBar(context, 'Google Maps API key is not set');
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=$key',
      );
      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        MySnackBar.showSnackBar(context, 'Failed to fetch address info');
        return;
      }

      final Map<String, dynamic> data = json.decode(resp.body);
      if (data['status'] != 'OK' || (data['results'] as List).isEmpty) {
        MySnackBar.showSnackBar(context, 'No address found: ${data['status']}');
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
        } catch (_) {
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
        _hasPickedLocation = true;
      });
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      MySnackBar.showSnackBar(context, 'Error fetching address info');
    }
  }

  Future<void> _submit() async {
    if (!_hasPickedLocation || _pickedLatLng == null) {
      MySnackBar.showSnackBar(
        context,
        'Please pick a location on the map first',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final payload = {
      "data": {
        "id": _editingAddress?.id ?? 0,
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
        MySnackBar.showSnackBar(context, resp['message'] ?? 'Address added');

        final returnedId = resp['data']?['id'];
        final effectiveId = returnedId != null
            ? returnedId.toString()
            : _editingAddress?.id.toString();
        if (widget.onSelected != null && effectiveId != null) {
          widget.onSelected!(effectiveId);
        }
        Navigator.of(context).pop(true);
      }
    } else {
      MySnackBar.showSnackBar(
        context,
        resp['message'] ?? 'Failed to add address',
      );
    }
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h, top: 10.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AllColors.buttonColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AllColors.olivegreenColor;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            child: _showAddForm
                ? _buildAddAddressForm(primary)
                : _buildAddressList(primary),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressList(Color primary) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Address',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AllColors.buttonColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Address list
          if (widget.addresses != null && widget.addresses!.isNotEmpty)
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.addresses!.length,
                itemBuilder: (context, index) {
                  final address = widget.addresses![index];
                  final isSelected = widget.selectedId == address.id.toString();

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected ? primary : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        if (widget.onSelected != null) {
                          widget.onSelected!(address.id.toString());
                        }
                        Navigator.of(context).pop(true);
                      },
                      leading: Icon(
                        Icons.location_on,
                        color: isSelected ? primary : Colors.grey.shade600,
                      ),
                      title: Text(
                        address.fullAddress,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${address.city}, ${address.state}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Padding(
                              padding: EdgeInsets.only(right: 4.w),
                              child: Icon(Icons.check_circle, color: primary),
                            ),
                          IconButton(
                            onPressed: () {
                              final lat = address.latitudeDouble;
                              final lng = address.longitudeDouble;
                              setState(() {
                                _editingAddress = address;
                                _showAddForm = true;
                                _fullAddress.text = address.fullAddress;
                                _city.text = address.city;
                                _state.text = address.state;
                                _country.text = address.country;
                                _postalCode.text = address.postalCode;
                                _isDefault = address.isDefault;
                                if (lat != null && lng != null) {
                                  _pickedLatLng = LatLng(lat, lng);
                                  _hasPickedLocation = true;
                                } else {
                                  _pickedLatLng = null;
                                  _hasPickedLocation = false;
                                }
                              });
                            },
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  'No addresses found',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),

          SizedBox(height: 16.h),

          // Add new address button
          CommonButton(
            onTap: () {
              setState(() {
                _editingAddress = null;
                _showAddForm = true;
                _isDefault = false;
                _pickedLatLng = null;
                _hasPickedLocation = false;
                _fullAddress.clear();
                _city.clear();
                _state.clear();
                _country.clear();
                _postalCode.clear();
              });
            },
            buttonValue: '+ Add New Address',
            color: primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddAddressForm(Color primary) {
    final openedForEditOnly =
        widget.editAddress != null && widget.addresses == null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────── Drag handle + header ──────────
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (openedForEditOnly) {
                        Navigator.of(context).pop(false);
                        return;
                      }
                      setState(() {
                        _editingAddress = null;
                        _showAddForm = false;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: 20.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _editingAddress == null
                          ? 'Add New Address'
                          : 'Edit Address',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AllColors.buttonColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // ────────── Map/location status ──────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                margin: EdgeInsets.only(bottom: 12.h, top: 4.h),
                decoration: BoxDecoration(
                  color: _hasPickedLocation
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: _hasPickedLocation
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasPickedLocation
                          ? Icons.check_circle_rounded
                          : Icons.location_on_rounded,
                      color: _hasPickedLocation
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasPickedLocation
                                ? 'Location selected'
                                : 'Pick a location to auto-fill address',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: _hasPickedLocation
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                          if (_hasPickedLocation && _pickedLatLng != null) ...[
                            SizedBox(height: 2.h),
                            Text(
                              'Lat: ${_pickedLatLng!.latitude.toStringAsFixed(4)}, '
                              'Lng: ${_pickedLatLng!.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CommonButton(
                      buttonValue: _hasPickedLocation
                          ? 'Change'
                          : 'Pick on Map',
                      isFullWidth: false,
                      selfconstraints: BoxConstraints(
                        maxWidth: 110.w,
                        minHeight: 36.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
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
                          ? primary
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
              ),

              // ────────── Address fields card ──────────
              Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("Full Address"),
                    CommonTextField(
                      controller: _fullAddress,
                      label: "Full Address",
                      enabled: _hasPickedLocation,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Required" : null,
                      radius: 10,
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 10.w,
                      ),
                    ),

                    _fieldLabel("City"),
                    CommonTextField(
                      controller: _city,
                      label: "City",
                      enabled: _hasPickedLocation,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Required" : null,
                      radius: 10,
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 10.w,
                      ),
                    ),

                    _fieldLabel("State"),
                    CommonTextField(
                      controller: _state,
                      label: "State",
                      enabled: _hasPickedLocation,
                      radius: 10,
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 10.w,
                      ),
                    ),

                    _fieldLabel("Country"),
                    CommonTextField(
                      controller: _country,
                      label: "Country",
                      enabled: _hasPickedLocation,
                      radius: 10,
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 10.w,
                      ),
                    ),

                    _fieldLabel("Pin Code"),
                    CommonTextField(
                      controller: _postalCode,
                      label: "Pin Code",
                      enabled: _hasPickedLocation,
                      keyboardType: TextInputType.number,
                      radius: 10,
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 10.w,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 5.w,
                      ),
                      buttonValue: 'Cancel',
                      isFullWidth: true,
                      backgroundColor: Colors.grey.shade200,
                      textStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                      radius: 10.r,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CommonButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 5.w,
                      ),
                      buttonValue: 'Save Address',
                      isFullWidth: true,
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
                  ),
                ],
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
