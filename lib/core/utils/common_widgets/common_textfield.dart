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
  final int? maxLines;
  final bool? alignLabelWithHint;

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
    this.maxLines = 1,
    this.alignLabelWithHint,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled ?? true;
    final bool floating = useFloatingLabel == true;

    final baseTextStyle =
        textStyle ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isEnabled
              ? AllColors.textfieldinputColor
              : Colors.grey.shade500,
        );

    final hintTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade500,
    );
    final bgColor = isEnabled
        ? (color ?? Colors.white)
        : Colors.grey.shade100;
    final borderRadius = BorderRadius.circular(radius ?? 10);
    final borderColor = AllColors.textfieldborderColor;

    return SizedBox(
      width: width ?? double.infinity,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
        enabled: isEnabled,
        validator: validator,
        onChanged: onChanged,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: baseTextStyle,
        cursorColor: AllColors.buttonColor,
        maxLines: maxLines,
        decoration: InputDecoration(
          isDense: true,
          alignLabelWithHint: alignLabelWithHint,
          contentPadding:
              padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          filled: true,
          fillColor: bgColor,

          prefixIcon: preFixIcon,
          suffixIcon: suFFixIcon,
          errorText: errorText,
          labelText: floating ? label : null,
          labelStyle: floating ? hintTextStyle.copyWith(fontSize: 14) : null,
          floatingLabelBehavior: floating
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
          hintText: floating ? null : label,
          hintStyle: hintTextStyle,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: AllColors.buttonColor, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(color: Colors.red),
          ),

          errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
        ),
      ),
    );
  }
}
