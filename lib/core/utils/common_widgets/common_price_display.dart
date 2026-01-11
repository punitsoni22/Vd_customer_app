import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/colors.dart';

class CommonPriceDisplay extends StatelessWidget {
  final String price;
  final String? originalPrice;
  final TextStyle? priceStyle;
  final TextStyle? originalPriceStyle;
  final String currencySymbol;
  final MainAxisAlignment mainAxisAlignment;

  const CommonPriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.priceStyle,
    this.originalPriceStyle,
    this.currencySymbol = '₹',
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final hasOriginalPrice = originalPrice != null &&
        originalPrice!.isNotEmpty &&
        originalPrice != 'null' &&
        originalPrice != '0';
    
    // Default styles
    final defaultPriceStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    final defaultOriginalPriceStyle = TextStyle(
      fontSize: 12.sp,
      decoration: TextDecoration.lineThrough,
      color: Colors.grey,
      fontWeight: FontWeight.w400,
    );

    final finalPriceStyle = priceStyle ?? defaultPriceStyle;
    final finalOriginalPriceStyle = originalPriceStyle ?? defaultOriginalPriceStyle;

    // Parse price to remove decimals if needed (optional, keeping it simple as string for now)
    // Assuming inputs are strings like "100" or "100.00"

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasOriginalPrice) ...[
          Text(
            '$currencySymbol$originalPrice',
            style: finalOriginalPriceStyle,
          ),
          SizedBox(width: 6.w),
        ],
        Text(
          '$currencySymbol$price',
          style: finalPriceStyle,
        ),
      ],
    );
  }
}
