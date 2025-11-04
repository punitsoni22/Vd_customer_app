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
    return Container(
      width: 100.w,
      padding: padding ?? EdgeInsets.all(2.r),
      constraints: selfconstraints ?? const BoxConstraints(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 10.r),
        border: Border.all(color: bordercolor ?? AllColors.buttonColor),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onSubtract,
            child: Icon(Icons.remove, color: Colors.blue),
          ),
          SizedBox(width: 5.w),
          Text('$quantity', style: TextStyle(color: Colors.black)),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: onAdd,
            child: Icon(Icons.add, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
