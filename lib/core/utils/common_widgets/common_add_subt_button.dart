import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class CommonAddSubtButton extends StatefulWidget {
  final BoxConstraints? selfconstraints;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? bordercolor;
  final Color? iconColor;

  final ValueChanged<int>? onQuantityChanged;

  final int initialQuantity;

  const CommonAddSubtButton({
    super.key,
    this.selfconstraints,
    this.padding,
    this.radius,
    this.bordercolor,
    this.iconColor,
    this.onQuantityChanged,
    this.initialQuantity = 1,
  });

  @override
  State<CommonAddSubtButton> createState() => _CommonAddSubtButtonState();
}

class _CommonAddSubtButtonState extends State<CommonAddSubtButton> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  void _increment() {
    setState(() {
      quantity++;
    });
    widget.onQuantityChanged?.call(quantity);
  }

  void _decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
      widget.onQuantityChanged?.call(quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(5),
      constraints: widget.selfconstraints ?? const BoxConstraints(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius ?? 10),
        border: Border.all(color: widget.bordercolor ?? AllColors.buttonColor),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _decrement,
            child: Icon(
              Icons.remove,
              color: widget.iconColor ?? AllColors.olivegreenColor,
            ),
          ),
          SizedBox(width: 5),
          Text('$quantity', style: TextStyle(color: AllColors.olivegreenColor)),
          SizedBox(width: 5),
          GestureDetector(
            onTap: _increment,
            child: Icon(
              Icons.add,
              color: widget.iconColor ?? AllColors.olivegreenColor,
            ),
          ),
        ],
      ),
    );
  }
}
