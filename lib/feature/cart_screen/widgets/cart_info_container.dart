import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class CustomInfoContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final CrossAxisAlignment? crossAxisAlignment;
  final double? iconSize;
  final double? borderRadius;
  final Color? textColor;

  const CustomInfoContainer({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.crossAxisAlignment,
    this.iconSize,
    this.borderRadius,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? AllColors.buttonColor),
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize ?? 20.r,
            color: iconColor ?? AllColors.buttonColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: textColor ?? const Color(0xFF565D65),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
