import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vd_customer_app/theme/colors.dart';

class MyTextField extends StatelessWidget {
  final TextInputType? keyboardType;
  final String label;
  final bool? obscureText;
  final TextEditingController? controller;
  final Icon? preFixIcon;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Widget? suFFixIcon;
  final bool? enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool? useFloatingLabel;
  final List<TextInputFormatter>? inputFormatters;

  const MyTextField({
    super.key,
    this.keyboardType,
    required this.label,
    this.obscureText,
    this.controller,
    this.preFixIcon,
    this.errorText,
    this.textInputAction,
    this.suFFixIcon,
    this.enabled,
    this.onChanged,
    this.useFloatingLabel,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText ?? false,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AllColors.textfieldinputColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AllColors.backgroundColor,

            prefixIcon: preFixIcon,
            suffixIcon: suFFixIcon,
            errorText: errorText,
            hintText: label,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AllColors.textfieldhintColor,
            ),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AllColors.textfieldborderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AllColors.textfieldborderColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
