import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/checkout_screen/provider/checkout_provider.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class InfoIconButton extends StatelessWidget {
  const InfoIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final cartProvider = context.read<CartProvider>();
        final checkoutProvider = context.read<CheckoutProvider>();

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        await checkoutProvider.fetchCoupons(cartProvider.subtotal);

        // Close loading dialog
        Navigator.of(context).pop();

        final coupons = checkoutProvider.coupons;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          builder: (context) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  SizedBox(height: 10.h),
                  Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Title
                  Text(
                    "Available Coupons",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  const Divider(),

                  // Coupons list or empty state
                  if (coupons.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 64.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "No coupons available",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: coupons.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final coupon = coupons[index];
                          return _buildCouponCard(
                            context,
                            coupon,
                            cartProvider.subtotal,
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
      icon: Icon(Icons.info_outline, color: Colors.grey),
    );
  }

  Widget _buildCouponCard(
    BuildContext context,
    Map<String, dynamic> coupon,
    double subtotal,
  ) {
    final couponCode = coupon['couponCode'] ?? '';
    final couponValue = coupon['couponValue'] ?? '0';
    final couponType = coupon['couponType'] ?? 'PERCENTAGE';
    final maxUsage = coupon['maxUsage'] ?? 0;
    final timesUsed = coupon['timesUsed'] ?? 0;
    final expiryDate = coupon['expiryDate'] ?? '';

    // Calculate discount amount
    double discountAmount = 0.0;
    String discountText = '';

    if (couponType == 'PERCENTAGE') {
      final percentage = double.tryParse(couponValue.toString()) ?? 0.0;
      discountAmount = (subtotal * percentage) / 100;
      discountText = '$couponValue% OFF';
    } else {
      discountAmount = double.tryParse(couponValue.toString()) ?? 0.0;
      discountText = '₹$couponValue OFF';
    }

    // Ensure discount doesn't exceed subtotal
    if (discountAmount > subtotal) {
      discountAmount = subtotal;
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AllColors.iconColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColors.iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with discount and copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AllColors.iconColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  discountText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: couponCode));
                  MySnackBar.showSnackBar(
                    context,
                    "Coupon code copied to clipboard",
                  );
                },
                icon: Icon(Icons.copy, color: AllColors.iconColor, size: 20.sp),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Coupon code
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    couponCode,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Text(
                  'TAP TO COPY',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Savings info
          Row(
            children: [
              Icon(Icons.savings, color: Colors.green, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                'You save ₹${discountAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Usage and expiry info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: $timesUsed/$maxUsage',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              Text(
                'Expires: ${_formatDate(expiryDate)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Apply button
          GestureDetector(
            onTap: () {
              Navigator.pop(context, couponCode);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AllColors.iconColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'Apply Coupon',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final parts = dateString.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; 
      }
      return dateString;
    } catch (e) {
      return 'N/A';
    }
  }
}
