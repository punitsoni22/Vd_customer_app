import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

                fieldLabel("Full Address"),
                CommonTextField(
                  controller: _fullAddress,
                  label: "Full Address",
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
                  radius: 10,
                  padding: EdgeInsets.symmetric(
                    vertical: 9.h,
                    horizontal: 12.w,
                  ),
                ),

                fieldLabel("Postal Code"),
                CommonTextField(
                  controller: _postalCode,
                  label: "Postal Code",
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
                      onChanged: (v) => setState(() => _isDefault = v ?? false),
                      activeColor: AllColors.buttonColor,
                    ),
                    Text('Set as default', style: TextStyle(fontSize: 13.sp)),
                  ],
                ),

                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _pickedLatLng == null
                            ? 'No location selected'
                            : 'Lat: ${_pickedLatLng!.latitude.toStringAsFixed(6)}, Lng: ${_pickedLatLng!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    CommonButton(
                      buttonValue: 'Pick on map',
                      isFullWidth: false,
                      selfconstraints: BoxConstraints(
                        maxWidth: 140.w,
                        minHeight: 40.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 10.w,
                      ),
                      radius: 10.r,
                      backgroundColor: AllColors.tabBarline,
                      textStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      onTap: () async {
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
                  onTap: _isSubmitting ? null : _submit,
                  backgroundColor: AllColors.tabBarline,
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
