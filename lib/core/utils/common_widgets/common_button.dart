import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class CommonButton extends StatelessWidget {
  final String buttonValue;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool isFullWidth;
  final Color? color;
  final BoxConstraints? selfconstraints;
  final double? radius;
  final bool isLoading;
  final Widget? child;

  const CommonButton({
    super.key,
    required this.buttonValue,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.textStyle,
    this.icon,
    this.isFullWidth = false,
    this.color,
    this.selfconstraints,
    this.radius,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(radius ?? 10),
      onTap: isLoading ? null : onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        constraints: selfconstraints ?? const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          border: Border.all(color: color ?? AllColors.buttonColor),
          color: backgroundColor ?? AllColors.buttonColor,
          borderRadius: BorderRadius.circular(radius ?? 10),
        ),
        alignment: Alignment.center,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : child ??
                  Row(
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
