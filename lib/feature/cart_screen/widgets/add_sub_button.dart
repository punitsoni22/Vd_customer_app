import 'package:flutter/material.dart';
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
      padding: padding ?? const EdgeInsets.all(5),
      constraints: selfconstraints ?? const BoxConstraints(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 10),
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
          SizedBox(width: 5),
          Text('$quantity', style: TextStyle(color: Colors.black)),
          SizedBox(width: 5),
          GestureDetector(
            onTap: onAdd,
            child: Icon(Icons.add, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
