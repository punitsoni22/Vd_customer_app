import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';

class AddSubtButton extends StatelessWidget {
  final BoxConstraints? selfconstraints;
  final EdgeInsetsGeometry? padding;
  const AddSubtButton({super.key, this.selfconstraints, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(5),
      constraints: selfconstraints ?? const BoxConstraints(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AllColors.buttonColor),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.remove, color: AllColors.olivegreenColor),
          SizedBox(width: 5),
          Text('3', style: TextStyle(color: AllColors.olivegreenColor)),
          SizedBox(width: 5),
          Icon(Icons.add, color: AllColors.olivegreenColor),
        ],
      ),
    );
  }
}
