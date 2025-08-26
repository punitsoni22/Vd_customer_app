import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class AddSubtButton extends StatelessWidget {
  final BoxConstraints? selfconstraints;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? bordercolor;
  final Color? iconColor;

  const AddSubtButton({
    super.key,
    this.selfconstraints,
    this.padding,
    this.radius,
    this.bordercolor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(5),
      constraints: selfconstraints ?? const BoxConstraints(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 10),
        border: Border.all(color: bordercolor ?? AllColors.buttonColor),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.remove, color: iconColor ?? AllColors.olivegreenColor),
          SizedBox(width: 5),
          Text('3', style: TextStyle(color: AllColors.olivegreenColor)),
          SizedBox(width: 5),
          Icon(Icons.add, color: iconColor ?? AllColors.olivegreenColor),
        ],
      ),
    );
  }
}
