import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

enum ButtonVariant { filled, outlined }

class CommonButton extends StatelessWidget {
  final String buttonValue;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool isFullWidth;
  final Color? color;
  final Color? borderColor;
  final Color? foregroundColor;
  final BoxConstraints? selfconstraints;
  final double? radius;
  final bool isLoading;
  final Widget? child;
  final ButtonVariant variant;
  final double borderWidth;
  final bool pill;
  final double? elevation;
  final double? fontSize;
  final double? iconSize;
  final BorderRadiusGeometry? borderRadius;

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
    this.borderColor,
    this.foregroundColor,
    this.selfconstraints,
    this.radius,
    this.isLoading = false,
    this.child,
    this.variant = ButtonVariant.filled,
    this.borderWidth = 1,
    this.pill = false,
    this.elevation,
    this.fontSize,
    this.iconSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final primary = color ?? AllColors.buttonColor;
    final isOutlined = variant == ButtonVariant.outlined;

    final bg = isOutlined
        ? (backgroundColor ?? Colors.white)
        : (backgroundColor ?? primary);

    final borderCol = borderColor ?? primary;
    final fg = foregroundColor ?? (isOutlined ? borderCol : Colors.white);

    final r = pill ? (radius ?? 28) : (radius ?? 10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(r),
        onTap: isLoading ? null : onTap,
        child: Container(
          width: isFullWidth ? double.infinity : null,
          constraints: selfconstraints ?? const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: borderRadius ?? BorderRadius.circular(r),
            border: Border.all(
              color: borderCol,
              width: isOutlined ? borderWidth : 0,
            ),
            boxShadow: (elevation != null && !isOutlined)
                ? [
                    BoxShadow(
                      blurRadius: elevation!,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                      color: Colors.black.withValues(alpha: 0.12),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          Icon(icon, size: iconSize ?? 18, color: fg),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          buttonValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              textStyle ??
                              TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: fontSize ?? 14,
                                color: fg,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
