import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class CommonButton extends StatelessWidget {
  final String buttonValue;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool? isFullWidth;
  final Color? color;
  final BoxConstraints? selfconstraints;
  final double? radius;

  const CommonButton({
    super.key,
    required this.buttonValue,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.textStyle,
    this.icon,
    this.isFullWidth,
    this.color,
    this.selfconstraints,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: isFullWidth == true ? double.infinity : null,

        constraints: selfconstraints ?? const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          border: BoxBorder.all(color: color ?? AllColors.buttonColor),
          color: backgroundColor ?? AllColors.buttonColor,
          borderRadius: BorderRadius.circular(radius ?? 10),
        ),
        alignment: Alignment.center,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              buttonValue,
              style:
                  textStyle ??
                  const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
