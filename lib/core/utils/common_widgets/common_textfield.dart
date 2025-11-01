import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class CommonTextField extends StatelessWidget {
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
  final TextStyle? textStyle;
  final double? width;
  final Color? color;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  const CommonTextField({
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
    this.textStyle,
    this.width,
    this.color,
    this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
        enabled: enabled,
        validator: validator,
        onChanged: onChanged,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style:
            textStyle ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AllColors.textfieldinputColor,
            ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              padding ?? EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          filled: true,
          fillColor: color ?? AllColors.backgroundColor,

          prefixIcon: preFixIcon,
          suffixIcon: suFFixIcon,
          errorText: errorText,
          hintText: label,
          hintStyle:
              textStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? AllColors.textfieldhintColor,
              ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius ?? 10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius ?? 10),
            borderSide: BorderSide(color: AllColors.textfieldborderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius ?? 10),
            borderSide: BorderSide(color: AllColors.textfieldborderColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
