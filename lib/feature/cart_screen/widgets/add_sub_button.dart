import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class AddSubtButton extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final BoxConstraints? selfconstraints;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? bordercolor;
  final Color? iconColor;

  const AddSubtButton({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onSubtract,
    this.selfconstraints,
    this.padding,
    this.radius,
    this.bordercolor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = iconColor ?? AllColors.buttonColor;

    return Container(
      height: 34.h,
      width: 112.w,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 4.w),
      constraints: selfconstraints ?? const BoxConstraints(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 20.r),
        border: Border.all(color: bordercolor ?? primaryColor),
        color: Colors.white,
      ),
      child: Row(
        children: [
          /// MINUS
          _CircleIconButton(
            icon: Icons.remove,
            onTap: onSubtract,
            color: primaryColor,
          ),

          Expanded(
            child: Center(
              child: Text(
                '$quantity',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          /// PLUS
          _CircleIconButton(
            icon: Icons.add,
            onTap: onAdd,
            color: primaryColor,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.08),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: color,
        ),
      ),
    );
  }
}
